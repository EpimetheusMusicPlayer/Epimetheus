import 'package:epimetheus/features/auth/ui/widgets/login_form.dart';
import 'package:epimetheus/features/proxy/ui/widgets/actions.dart';
import 'package:epimetheus_nullable/mobx/auth/auth_store.dart';
import 'package:epimetheus_nullable/mobx/auth/login_form_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginFromStore = LoginFormStore();

  void _login(String email, String password) {
    if (loginFromStore.validateAll()) {
      GetIt.instance<AuthStore>().startLogin(email: email, password: password);
    }
  }

  @override
  void initState() {
    super.initState();
    loginFromStore.initValidators();
  }

  @override
  void dispose() {
    loginFromStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign in'),
          actions: const [ProxyPreferencesAction()],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Observer(
            builder: (_) => LoginForm(
              initialEmail: '',
              initialPassword: '',
              onEmailChange: (email) => loginFromStore.email = email,
              onPasswordChange: (password) =>
                  loginFromStore.password = password,
              canLogIn: loginFromStore.canLogIn,
              onSubmit: _login,
              emailErrorMessage: loginFromStore.emailErrorMessage,
              passwordErrorMessage: loginFromStore.passwordErrorMessage,
            ),
          ),
        ),
      ),
    );
  }
}
