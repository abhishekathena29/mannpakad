import 'package:flutter/material.dart';
import 'package:mannpakad/features/auth/providers/app_auth_provider.dart';
import 'package:mannpakad/features/auth/screens/auth_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppAuthProvider auth) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await auth.signUpWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppAuthScope.of(context);

    return AuthScaffold(
      title: 'Create your account.',
      subtitle: 'Sign up first, then we will tailor the app around your needs.',
      leading: IconButton(
        onPressed: () => auth.setView(AuthView.welcome),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      footer: Center(
        child: TextButton(
          onPressed: () => auth.setView(AuthView.login),
          child: const Text('Already have an account? Log in'),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your email.';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Create a password.';
                }
                if (value.length < 6) {
                  return 'Use at least 6 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm password'),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match.';
                }
                return null;
              },
            ),
            if (auth.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                auth.errorMessage!,
                style: const TextStyle(color: Color(0xFFFCA5A5)),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: auth.isSubmitting ? null : () => _submit(auth),
                child: Text(
                  auth.isSubmitting ? 'Creating account...' : 'Create account',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
