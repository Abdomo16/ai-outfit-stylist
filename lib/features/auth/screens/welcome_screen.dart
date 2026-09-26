import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../navigation/route_names.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background image with gradient fallback.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.58,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
                    theme.scaffoldBackgroundColor,
                  ],
                  stops: const [0.4, 0.75, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.srcOver,
              child: Image.network(
                'https://images.unsplash.com/photo-1549439602-43ebca2327af?q=80&w=1000&auto=format&fit=crop',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroGradient,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.auto_fix_high,
                        size: 80,
                        color: colors.onPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Decorative glow orb.
          Positioned(
            top: size.height * 0.12,
            right: -40,
            width: 180,
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.35),
                    AppColors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Content.
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.heroGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.auto_fix_high,
                            color: colors.onPrimary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'AI Outfit\nStylist',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: colors.onSurface,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Your personal AI fashion assistant for the perfect look, every single day.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        CustomButton(
                          text: 'Create Account',
                          color: AppColors.primary,
                          textColor: colors.onPrimary,
                          hasGlow: true,
                          onPressed: () =>
                              Navigator.pushNamed(context, RouteNames.register),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        CustomButton(
                          text: 'Login',
                          isOutlined: true,
                          color: AppColors.primary,
                          textColor: colors.onSurface,
                          onPressed: () =>
                              Navigator.pushNamed(context, RouteNames.login),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
