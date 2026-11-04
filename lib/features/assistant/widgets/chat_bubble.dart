import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../chat_cubit.dart';
import 'chat_outfit_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onOpenOutfit;

  const ChatBubble({super.key, required this.message, this.onOpenOutfit});

  String _text(AppLocalizations l10n) {
    if (message.text.isNotEmpty) return message.text;
    return switch (message.status) {
      ChatStatus.noMatch => l10n.chatNoMatch,
      ChatStatus.emptyWardrobe => l10n.emptyWardrobe,
      ChatStatus.error => l10n.chatError,
      ChatStatus.ok => l10n.chatHereIsLook,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final fromUser = message.fromUser;
    final isError = message.status == ChatStatus.error;
    final radius = BorderRadiusDirectional.only(
      topStart: const Radius.circular(20),
      topEnd: const Radius.circular(20),
      bottomStart: Radius.circular(fromUser ? 20 : 6),
      bottomEnd: Radius.circular(fromUser ? 6 : 20),
    );

    return Align(
      alignment: fromUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: fromUser ? AppColors.heroGradient : null,
            color: fromUser
                ? null
                : isError
                    ? AppColors.error.withValues(alpha: 0.12)
                    : colors.surfaceContainerHighest,
            borderRadius: radius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _text(l10n),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: fromUser ? AppColors.white : colors.onSurface,
                  height: 1.4,
                ),
              ),
              if (message.outfit != null && onOpenOutfit != null) ...[
                const SizedBox(height: 10),
                ChatOutfitCard(outfit: message.outfit!, onOpen: onOpenOutfit!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
