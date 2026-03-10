import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/app_colors.dart';
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
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
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
    final bgColor = const Color(0xFF141020);
    final darkPurpleBtn = const Color(0xFF281347);
    final brightPurple = AppColors.primary; // 0xFF8A3FFC
    final brightCyan = const Color(0xFF00E5FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Image Layer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                  stops: const [0.6, 0.8, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: Image.network(
                'https://images.unsplash.com/photo-1549439602-43ebca2327af?q=80&w=1000&auto=format&fit=crop',
                // Using a generic unsplash fashion placeholder until the user updates with their local image.
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // Magic Wand Bubble
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      brightPurple.withOpacity(0.4),
                      brightPurple.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: brightPurple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_fix_high,
                    color: brightPurple,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),

          // Content Layer (Bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'AI Outfit Stylist',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your personal AI fashion assistant for\nthe perfect look',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 48),
                        CustomButton(
                          text: 'Create Account',
                          // Bright purple matching AppColors.primary
                          color: brightPurple,
                          hasGlow: true,
                          onPressed: () =>
                              Navigator.pushNamed(context, RouteNames.register),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Login',
                          color: darkPurpleBtn.withOpacity(0.8),
                          textColor: brightCyan,
                          onPressed: () =>
                              Navigator.pushNamed(context, RouteNames.login),
                        ),

                        const SizedBox(height: 24),
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
