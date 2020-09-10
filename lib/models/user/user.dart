import 'package:epimetheus/libepimetheus/authentication.dart';
import 'package:flutter/widgets.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {
  User _user;

  User get user => _user;

  void set user(user) {
    _user = user;
    notifyListeners();
  }

  void clear() {
    user = null;
  }

  bool ensureHasUser(BuildContext context) {
    if (_user == null) {
      Navigator.of(context).pushReplacementNamed('/');
      return false;
    } else {
      return true;
    }
  }

  static UserModel of(BuildContext context) => ScopedModel.of<UserModel>(context);
}
