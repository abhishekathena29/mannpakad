import 'package:flutter/material.dart';
import 'package:mannpakad/features/auth/providers/app_auth_provider.dart';
import 'package:mannpakad/features/auth/screens/auth_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppAuthProvider auth) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await auth.signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppAuthScope.of(context);

    return AuthScaffold(
      title: 'Welcome back.',
      subtitle: 'Pick up your ERP work where you left off.',
      leading: IconButton(
        onPressed: () => auth.setView(AuthView.welcome),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      footer: Center(
        child: TextButton(
          onPressed: () => auth.setView(AuthView.signup),
          child: const Text('Need an account? Sign up'),
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
              autofillHints: const [AutofillHints.password],
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your password.';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters.';
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
                child: Text(auth.isSubmitting ? 'Logging in...' : 'Log in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
