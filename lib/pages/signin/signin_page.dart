import 'package:epimetheus/pages/authentication/authentication_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_autofill/flutter_autofill.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

/// The user inputs their credentials to this page, which then passes them on to [AuthenticationPage].
/// If an email is passed in from the app launching code,it automatically fill that in.

const _emailRegex = r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";

void signOut(BuildContext context) {
  FlutterSecureStorage()..delete(key: 'email')..delete(key: 'password');
  Navigator.pushReplacementNamed(context, '/sign-in');
}

class SignInPage extends StatefulWidget {
  final String email;
  final String password;

  SignInPage({this.email, this.password});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController;
  TextEditingController _passwordController;

  String _email;
  String _password;

  void _signIn() {
    final _formKeyState = _formKey.currentState;
    if (_formKeyState.validate()) {
      _formKeyState.save();
      FlutterAutofill.commit();
      Navigator.pushReplacementNamed(
        context,
        '/auth',
        arguments: AuthenticationPageArguments(
          email: _email,
          password: _password,
        ),
      );
    }
  }

  void _signUp() {
    launch('https://www.pandora.com/account/register');
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: widget.password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String emailValidator(String email) {
      if (email.isEmpty) return 'Please enter an email address.';
      if (!RegExp(_emailRegex).hasMatch(email)) return 'Please enter a valid email address.';
      return null;
    }

    String passwordValidator(String password) {
      if (password.isEmpty) return 'Please enter a password.';
      return null;
    }

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign in'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Form(
            key: _formKey,
            child: Align(
              alignment: const Alignment(0, -0.25),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Row(
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
                  Autofill(
                    autofillHints: const [FlutterAutofill.AUTOFILL_HINT_EMAIL_ADDRESS],
                    autofillType: FlutterAutofill.AUTOFILL_TYPE_TEXT,
                    onAutofilled: (value) {
                      _emailController.text = value;
                    },
                    textController: _emailController,
                    child: TextFormField(
                      controller: _emailController,
                      validator: emailValidator,
                      onSaved: (email) => _email = email,
                      decoration: const InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Email address',
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Autofill(
                    autofillHints: const [FlutterAutofill.AUTOFILL_HINT_PASSWORD],
                    autofillType: FlutterAutofill.AUTOFILL_TYPE_TEXT,
                    onAutofilled: (value) {
                      _passwordController.text = value;
                    },
                    textController: _passwordController,
                    child: TextFormField(
                      controller: _passwordController,
                      validator: passwordValidator,
                      onSaved: (password) => _password = password,
                      decoration: const InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        textColor: Theme.of(context).accentColor,
                        onPressed: _signUp,
                        child: const Text('Sign up'),
                      ),
                      const SizedBox(width: 8),
                      RaisedButton(
                        onPressed: _signIn,
                        child: const Text('Sign in'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
