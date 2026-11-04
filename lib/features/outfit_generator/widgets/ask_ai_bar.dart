import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'occasion_selector.dart';

class AskAiBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final String? selectedOccasion;
  final ValueChanged<String>? onSelectOccasion;

  /// Wording for other uses of the bar; the outfit stylist's when null.
  final String? title;
  final String? subtitle;
  final String? hint;
  final List<String>? examples;

  const AskAiBar({
    super.key,
    required this.onSend,
    this.selectedOccasion,
    this.onSelectOccasion,
    this.title,
    this.subtitle,
    this.hint,
    this.examples,
  });

  @override
  State<AskAiBar> createState() => _AskAiBarState();
}

class _AskAiBarState extends State<AskAiBar> {
  final _controller = TextEditingController();
  final _speech = stt.SpeechToText();
  bool _isListening = false;
  String _dictationPrefix = '';

  @override
  void dispose() {
    if (_speech.isListening) _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final message = (text ?? _controller.text).trim();
    if (message.isEmpty) return;
    _controller.clear();
    FocusScope.of(context).unfocus();
    widget.onSend(message);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    FocusScope.of(context).unfocus();
    _dictationPrefix = _controller.text.trim();
    try {
      final available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        options: [stt.SpeechToText.androidNoBluetooth],
      );
      if (!mounted) return;

      if (!available) {
        var hasPermission = false;
        try {
          hasPermission = await _speech.hasPermission;
        } catch (_) {}
        if (!mounted) return;
        _showMessage(
          hasPermission
              ? AppLocalizations.of(context).voiceUnavailable
              : AppLocalizations.of(context).voicePermissionDenied,
        );
        return;
      }

      final localeId = await _localeId();
      if (!mounted) return;
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: _onSpeechResult,
        listenOptions: stt.SpeechListenOptions(
          localeId: localeId,
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: true,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isListening = false);
      _showMessage(AppLocalizations.of(context).voiceUnavailable);
    }
  }

  Future<String?> _localeId() async {
    try {
      final languageCode = Localizations.localeOf(context).languageCode;
      final locales = await _speech.locales();
      for (final locale in locales) {
        if (locale.localeId.toLowerCase().startsWith('$languageCode-') ||
            locale.localeId.toLowerCase() == languageCode) {
          return locale.localeId;
        }
      }
    } catch (_) {}
    return null;
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;
    final listening = status == stt.SpeechToText.listeningStatus;
    if (_isListening != listening) setState(() => _isListening = listening);
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (!mounted) return;
    setState(() => _isListening = false);
    final l10n = AppLocalizations.of(context);
    final permissionDenied =
        error.errorMsg.contains('permission') ||
        error.errorMsg.contains('denied');
    _showMessage(
      permissionDenied ? l10n.voicePermissionDenied : l10n.voiceUnavailable,
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final recognized = result.recognizedWords.trim();
    final transcript = [
      if (_dictationPrefix.isNotEmpty) _dictationPrefix,
      recognized,
    ].where((part) => part.isNotEmpty).join(' ');
    _controller.value = TextEditingValue(
      text: transcript,
      selection: TextSelection.collapsed(offset: transcript.length),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final examples =
        widget.examples ??
        [l10n.askExampleGym, l10n.askExampleDate, l10n.askExampleInterview];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title ?? l10n.askAiTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle ?? l10n.askAiSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: colors.outline),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: _isListening ? l10n.voiceStop : l10n.voiceStart,
                  onPressed: _toggleListening,
                  color: _isListening ? colors.error : colors.primary,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      _isListening
                          ? Icons.stop_circle_outlined
                          : Icons.mic_none,
                      key: ValueKey(_isListening),
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: widget.hint ?? l10n.askAiHint,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      suffixIcon: IconButton(
                        tooltip: l10n.send,
                        icon: const Icon(Icons.arrow_upward_rounded),
                        color: colors.primary,
                        onPressed: _send,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isListening) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.voiceListening,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final example in examples)
                ActionChip(
                  label: Text(example),
                  onPressed: () => _send(example),
                  backgroundColor: colors.surface,
                  side: BorderSide(color: colors.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                ),
            ],
          ),
          if (widget.onSelectOccasion != null) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: colors.outline.withValues(alpha: 0.7)),
            const SizedBox(height: 14),
            OccasionSelector(
              embedded: true,
              selectedOccasion: widget.selectedOccasion,
              onSelect: widget.onSelectOccasion!,
            ),
          ],
        ],
      ),
    );
  }
}
