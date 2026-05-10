import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../application/auth_controller.dart';
import '../auth_routes.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_widgets.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          .signUp(
            fullName: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
          );

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AuthRoutes.home, (route) => false);
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
            const BrandHeader(topSpacing: 20, bottomSpacing: 16),
            const AuthTitleBlock(
              title: 'Let’s Get Started!',
              subtitle: 'Create an account',
            ),
            const AuthFieldLabel('User  Name'),
            AuthTextField(
              controller: _nameController,
              hintText: 'Enter your First Name',
              validator: (value) =>
                  Validators.required(value, label: 'Full name'),
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            const SizedBox(height: 18),
            const AuthFieldLabel('Your Email'),
            AuthTextField(
              controller: _emailController,
              hintText: 'Enter your Email',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
            ),
            const SizedBox(height: 18),
            const AuthFieldLabel('Phone Number'),
            AuthTextField(
              controller: _phoneController,
              hintText: 'Enter your phone number',
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  Validators.required(value, label: 'Phone number'),
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            const SizedBox(height: 18),
            const AuthFieldLabel('Password'),
            AuthTextField(
              controller: _passwordController,
              hintText: 'Enter your Password',
              obscureText: _obscurePassword,
              validator: (value) =>
                  Validators.minLength(value, 8, label: 'Password'),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF818181),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const AuthFieldLabel('Confirm Password'),
            AuthTextField(
              controller: _confirmPasswordController,
              hintText: 'Enter Confirm Password',
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                final message = Validators.minLength(
                  value,
                  8,
                  label: 'Confirm password',
                );
                if (message != null) {
                  return message;
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match.';
                }
                return null;
              },
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF818181),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AuthPrimaryButton(
              label: 'Sign up',
              onPressed: _submit,
              isBusy: _isSubmitting,
            ),
            const SizedBox(height: 24),
            Center(
              child: InlineAuthLink(
                leadingText: 'Already have an account?',
                actionText: 'Sign In Here',
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
