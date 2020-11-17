import 'package:email_validator/email_validator.dart';
import 'package:epimetheus/features/auth/ui/widgets/login_form.dart';
import 'package:epimetheus/features/proxy/ui/widgets/actions.dart';
import 'package:epimetheus/logging.dart';
import 'package:epimetheus_nullable/mobx/auth/auth_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iapetus/iapetus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  _LoginPageState createState() => _LoginPageState();

  static PandoraCredentials? _retrieveExistingCredentials(
    BuildContext context,
  ) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is PandoraCredentials?) return arguments;
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  late final existingCredentials = LoginPage._retrieveExistingCredentials(
    context,
  );

  String? email;
  String? password;

  static String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'Email address is required.';
    if (!EmailValidator.validate(email)) return 'Invalid email address.';
  }

  static String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) return 'Password is required.';
  }

  void _login() {
    final formState = _formKey.currentState!;
    if (formState.validate()) {
      formState.save();
      GetIt.instance<AuthStore>().startLogin(
        PandoraCredentials(
          email: email,
          password: password,
          existingAuthToken: existingCredentials?.existingAuthToken,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign in'),
          actions: [
            const ProxyPreferencesAction(),
            if (kDebugMode) buildLogScreenAction(context),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: LoginForm(
            formKey: _formKey,
            initialEmail: existingCredentials?.email,
            initialPassword: existingCredentials?.password,
            saveEmail: (email) => this.email = email,
            savePassword: (password) => this.password = password,
            emailValidator: _validateEmail,
            passwordValidator: _validatePassword,
            onSubmit: _login,
          ),
        ),
      ),
    );
  }
}
