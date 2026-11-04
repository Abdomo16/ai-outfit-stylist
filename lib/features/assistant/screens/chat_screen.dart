import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/ai_service.dart';
import '../../../data/models/outfit_model.dart';
import '../../../data/repositories/wardrobe_repository_impl.dart';
import '../../../l10n/app_localizations.dart';
import '../chat_cubit.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_outfit_card.dart';

class ChatScreen extends StatelessWidget {
  /// Sent as soon as the screen opens.
  final String? initialMessage;

  /// The look the first message tweaks.
  final OutfitModel? currentOutfit;

  const ChatScreen({super.key, this.initialMessage, this.currentOutfit});

  @override
  Widget build(BuildContext context) {
    final aiService = AIService();
    return BlocProvider(
      create: (_) => ChatCubit(
        WardrobeRepositoryImpl(aiService: aiService),
        aiService,
        currentOutfit: currentOutfit,
      ),
      child: _ChatView(initialMessage: initialMessage),
    );
  }
}

class _ChatView extends StatefulWidget {
  final String? initialMessage;

  const _ChatView({this.initialMessage});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    final first = widget.initialMessage;
    if (first != null && first.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(first));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final message = (text ?? _controller.text).trim();
    if (message.isEmpty || !mounted) return;
    _controller.clear();
    context.read<ChatCubit>().send(
          message,
          locale: Localizations.localeOf(context).languageCode,
        );
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatTitle),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (_, _) => _scrollToEnd(),
                builder: (context, state) {
                  final cubit = context.read<ChatCubit>();
                  if (state.messages.isEmpty && !state.sending) {
                    return _Intro(onPick: _send);
                  }
                  return ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    children: [
                      for (final message in state.messages)
                        ChatBubble(
                          message: message,
                          onOpenOutfit: message.outfit == null
                              ? null
                              : () => openOutfitResult(
                                    context,
                                    message.outfit!,
                                    weather: cubit.weather,
                                    season: cubit.season,
                                  ),
                        ),
                      if (state.sending) const _Typing(),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: BlocBuilder<ChatCubit, ChatState>(
                buildWhen: (a, b) => a.sending != b.sending,
                builder: (context, state) => TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: l10n.chatHint,
                    filled: true,
                    fillColor: colors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: colors.outline),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded),
                      color: AppColors.primary,
                      onPressed: state.sending ? null : _send,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  final ValueChanged<String> onPick;

  const _Intro({required this.onPick});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final examples = [
      l10n.askExampleGym,
      l10n.askExampleDate,
      l10n.askExampleInterview,
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.chatIntro,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final example in examples)
                  ActionChip(
                    label: Text(example),
                    onPressed: () => onPick(example),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(AppLocalizations.of(context).chatThinking),
          ],
        ),
      ),
    );
  }
}
