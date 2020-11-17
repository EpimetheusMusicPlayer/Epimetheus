// import 'package:mobx/mobx.dart';
//
// part 'login_form_store.g.dart';
//
// class LoginFormStore = _LoginFormStore with _$LoginFormStore;
//
// abstract class _LoginFormStore with Store {
//   ReactionDisposer _emailDisposer;
//   ReactionDisposer _passwordDisposer;
//
//   @observable
//   String email = '';
//
//   @observable
//   String password = '';
//
//   @observable
//   String emailErrorMessage;
//
//   @observable
//   String passwordErrorMessage;
//
//   @computed
//   bool get canLogIn =>
//       emailErrorMessage == null && passwordErrorMessage == null;
//
//   void initValidators() {
//     assert(
//       _emailDisposer == null && _passwordDisposer == null,
//       'Validators already initialized!',
//     );
//     _emailDisposer = reaction((_) => email, validateEmail);
//     _passwordDisposer = reaction((_) => password, validatePassword);
//   }
//
//   void dispose() {
//     _emailDisposer();
//     _passwordDisposer();
//   }
//
//   @action
//   void validateEmail(String email) {
//     if (email.isEmpty) {
//       emailErrorMessage = 'Email address is required.';
//     } else if (!RegExp(
//       r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?",
//     ).hasMatch(email)) {
//       emailErrorMessage = 'Invalid email address.';
//     } else {
//       emailErrorMessage = null;
//     }
//   }
//   //
//   @action
//   void validatePassword(String password) {
//     if (password.isEmpty) {
//       passwordErrorMessage = 'Password is required.';
//     } else {
//       passwordErrorMessage = null;
//     }
//   }
//
//   @action
//   bool validateAll() {
//     validatePassword(password);
//     validateEmail(email);
//     return canLogIn;
//   }
// }
