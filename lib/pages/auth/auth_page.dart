import 'package:connectivity/connectivity.dart';
import 'package:epimetheus/dialogs/invalid_credentials_dialog.dart';
import 'package:epimetheus/dialogs/invalid_location_dialog.dart';
import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:epimetheus/libepimetheus/exceptions.dart';
import 'package:epimetheus/models/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// TODO NOW CONNECTIVITY AWARENESS

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();

  FlutterSecureStorage storage;

  String _email;
  String _password;
  bool _remember = true;
  bool _usePortaller = false;

  Future<void> writeToSecureStorage() {
    return Future.wait([
      storage.write(key: 'email', value: _email),
      storage.write(key: 'password', value: _password),
    ]);
  }

  bool _closeSigningInDialog = false;

  void signin(bool write) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(_closeSigningInDialog);
          },
          child: AlertDialog(
            content: Row(
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(width: 24),
                Text('Signing in...'),
              ],
            ),
          ),
        );
      },
    );

    User.create(
      _email,
      _password,
      _usePortaller,
    ).then((user) {
      EpimetheusModel.of(context).user = user;
      _closeSigningInDialog = true;
      Navigator.of(context).pop();
      _closeSigningInDialog = false;
      Navigator.of(context).pushReplacementNamed('/station_list');
      if (write) {
        writeToSecureStorage();
      }
    }).catchError(
      (e) {
        _closeSigningInDialog = true;
        Navigator.of(context).pop();
        _closeSigningInDialog = false;
        showDialog(context: context, builder: invalidCredentialsDialog);
      },
      test: (e) => e is InvalidRequestException,
    ).catchError(
      (e) {
        _closeSigningInDialog = true;
        Navigator.of(context).pop();
        _closeSigningInDialog = false;
        showDialog(context: context, builder: invalidLocationDialog);
      },
      test: (e) => e is LocationException,
    );
  }

  @override
  void initState() {
    super.initState();

    storage = FlutterSecureStorage();
    storage.readAll().then((values) {
      if (!values.containsKey('email') || !values.containsKey('password')) return;
      _email = values['email'];
      _password = values['password'];
      signin(false);
    });
  }

  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value.isEmpty) return 'Please enter an email address.';
                      if (!RegExp(
                              r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                          .hasMatch(value)) {
                        return 'Please enter a valid email address.';
                      }
                    },
                    onSaved: (value) {
                      _email = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) return 'Please enter a password.';
                    },
                    onSaved: (value) {
                      _password = value;
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: IgnorePointer(
                      child: Checkbox(
                        value: _remember,
                        onChanged: (value) {
                          setState(() {
                            _remember = value;
                          });
                        },
                      ),
                    ),
                    title: Text('Remember me'),
                    onTap: () {
                      setState(() {
                        _remember = !_remember;
                      });
                    },
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.all(0),
                          leading: IgnorePointer(
                            child: Checkbox(
                              value: _usePortaller,
                              onChanged: (value) {
                                setState(() {
                                  _usePortaller = value;
                                });
                              },
                            ),
                          ),
                          title: Text('Use Portaller'),
                          onTap: () {
                            setState(() {
                              _usePortaller = !_usePortaller;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      StreamBuilder<Object>(
                        stream: Connectivity().onConnectivityChanged,
                        builder: (context, snapshot) {
                          if (snapshot.data != ConnectionState.none) {
                            return RaisedButton(
                              onPressed: () {
                                if (_formKey.currentState.validate()) {
                                  _formKey.currentState.save();
                                  signin(true);
                                }
                              },
                              child: Text('Sign in'),
                            );
                          } else {
                            return RaisedButton(
                              onPressed: null,
                              child: Text('No connection'),
                            );
                          }
                        },
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
