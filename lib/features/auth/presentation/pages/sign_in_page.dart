import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../application/auth_controller.dart';
import '../auth_routes.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_widgets.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            email: _emailController.text,
            password: _passwordController.text,
            rememberMe: _rememberMe,
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(AuthRoutes.home);
    } on AuthFlowException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandHeader(topSpacing: 48, bottomSpacing: 28),
            const AuthFieldLabel('User Email'),
            AuthTextField(
              controller: _emailController,
              hintText: 'Enter your Email',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
            ),
            const SizedBox(height: 20),
            const AuthFieldLabel('Password'),
            AuthTextField(
              controller: _passwordController,
              hintText: 'Enter your Password',
              obscureText: _obscurePassword,
              validator: (value) =>
                  Validators.minLength(value, 8, label: 'Password'),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() => _rememberMe = value ?? false);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Remember me',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF808080),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AuthRoutes.forgotPassword);
                  },
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AuthPrimaryButton(
              label: 'Sign in',
              onPressed: _submit,
              isBusy: _isSubmitting,
            ),
            const SizedBox(height: 28),
            Center(
              child: InlineAuthLink(
                leadingText: 'Don’t have an account?',
                actionText: 'Sign Up Here',
                onTap: () {
                  Navigator.of(context).pushNamed(AuthRoutes.signUp);
                },
              ),
            ),
            const SizedBox(height: 32),
            SocialActionButton(
              icon: Icons.g_mobiledata_rounded,
              iconColor: const Color(0xFFEA4335),
              label: 'Continue with Google',
              onPressed: () {
                _showMessage('Google sign-in is not configured yet.');
              },
            ),
            const SizedBox(height: 12),
            SocialActionButton(
              icon: Icons.facebook_rounded,
              iconColor: const Color(0xFF1877F2),
              label: 'Continue with Facebook',
              onPressed: () {
                _showMessage('Facebook sign-in is not configured yet.');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
