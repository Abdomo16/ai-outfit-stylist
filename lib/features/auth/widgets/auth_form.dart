import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/constants/app_colors.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final Function(String email, String password, String? username) onSubmit;
  final bool isLoading;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  final brightCyan = const Color(0xFF00E5FF);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
        widget.isLogin ? null : _usernameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.isLogin) ...[
            CustomTextField(
              controller: _usernameController,
              label: 'Username',
              hintText: 'name',
              prefixIcon: const Icon(
                Icons.person_outline,
                color: AppColors.textSecondary,
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Username is required';
                return null;
              },
            ),
            const SizedBox(height: 20),
          ],
          CustomTextField(
            controller: _emailController,
            label: 'Email Address',
            hintText: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.textSecondary,
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Email is required';
              if (!val.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hintText: '••••••••',
            isPassword: true,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.textSecondary,
            ),
            suffixIcon: const Icon(
              Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Password is required';
              if (val.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          if (widget.isLogin) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: brightCyan),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'By registering, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service\n',
                      style: TextStyle(
                        color: brightCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: 'and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: brightCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          CustomButton(
            text: widget.isLogin ? 'Login' : 'Register',
            onPressed: _submit,
            isLoading: widget.isLoading,
            hasGlow: true,
            color: AppColors.primary, // 0xFF8A3FFC
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              const Expanded(
                child: Divider(color: AppColors.card, thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR CONTINUE WITH',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: AppColors.card, thickness: 1),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    // using letter G simple proxy for google logo for now
                    child: Text(
                      'G',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.apple, size: 28, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
