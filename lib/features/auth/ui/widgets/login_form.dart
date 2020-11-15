import 'package:flutter/material.dart';

typedef LoginFormSubmitCallback = void Function(String email, String password);

class LoginForm extends StatefulWidget {
  final String initialEmail;
  final String initialPassword;
  final ValueChanged<String> onEmailChange;
  final ValueChanged<String> onPasswordChange;
  final bool canLogIn;
  final LoginFormSubmitCallback onSubmit;
  final String? emailErrorMessage;
  final String? passwordErrorMessage;

  const LoginForm({
    Key? key,
    required this.initialEmail,
    required this.initialPassword,
    required this.onEmailChange,
    required this.onPasswordChange,
    required this.canLogIn,
    required this.onSubmit,
    required this.emailErrorMessage,
    required this.passwordErrorMessage,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late final _emailController =
      TextEditingController(text: widget.initialEmail);
  late final _passwordController =
      TextEditingController(text: widget.initialPassword);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.25),
      child: SingleChildScrollView(
        child: AutofillGroup(
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
                  const Text('Epimetheus', textScaleFactor: 2),
                ],
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                onChanged: widget.onEmailChange,
                autofillHints: const [
                  AutofillHints.email,
                  AutofillHints.username,
                ],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Email address',
                  errorText: widget.emailErrorMessage,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                onChanged: widget.onPasswordChange,
                autofillHints: const [
                  AutofillHints.password,
                ],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  errorText: widget.passwordErrorMessage,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  // FlatButton(
                  //   textColor: Theme.of(context)!.accentColor,
                  //   onPressed: null, // TODO implement signup
                  //   child: const Text('Sign up'),
                  // ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Sign up'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: widget.canLogIn
                        ? () {
                            FocusScope.of(context).unfocus();
                            widget.onSubmit(
                              _emailController.text,
                              _passwordController.text,
                            );
                          }
                        : null,
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
