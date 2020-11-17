import 'package:epimetheus/app_info.dart';
import 'package:flutter/material.dart';

typedef LoginFormSubmitCallback = void Function(String email, String password);

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String? initialEmail;
  final String? initialPassword;
  final ValueChanged<String?> saveEmail;
  final ValueChanged<String?> savePassword;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;
  final VoidCallback onSubmit;

  const LoginForm({
    Key? key,
    required this.formKey,
    required this.initialEmail,
    required this.initialPassword,
    required this.saveEmail,
    required this.savePassword,
    required this.emailValidator,
    required this.passwordValidator,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.25),
      child: SingleChildScrollView(
        child: AutofillGroup(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Hero(
                      tag: 'app_icon',
                      child: Image.asset(
                        'assets/app_icon.png',
                        width: 96,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(appName, textScaleFactor: 2),
                  ],
                ),
                const SizedBox(height: 48),
                TextFormField(
                  initialValue: initialEmail,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.username,
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email address',
                  ),
                  validator: emailValidator,
                  onSaved: saveEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: initialPassword,
                  autofillHints: const [
                    AutofillHints.password,
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: passwordValidator,
                  onSaved: savePassword,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {}, // TODO implement signup
                      child: const Text('Sign up'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        onSubmit();
                      },
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
