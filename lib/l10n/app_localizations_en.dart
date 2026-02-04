// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signInTitle => 'Sign in to Workforce';

  @override
  String get username => 'Username (Email)';

  @override
  String get password => 'Password';

  @override
  String get companyId => 'Company ID';

  @override
  String get role => 'Role';

  @override
  String get workforce => 'Workforce';

  @override
  String get admin => 'Admin';

  @override
  String get language => 'Language';

  @override
  String get signIn => 'Sign In';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPasswordHint => 'Enter your email';

  @override
  String get loginError => 'Invalid login';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get errorInvalidLogin => 'Invalid email or password';

  @override
  String get errorInvalidEmail => 'Invalid email address';

  @override
  String get errorTooManyRequests => 'Too many attempts. Please try again later.';

  @override
  String get errorLoginFailed => 'Login failed. Please try again.';

  @override
  String get errorUserNotRegistered => 'User is not registered in the system';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordSent => 'If the email exists, a reset link has been sent.';

  @override
  String get errorUserNotFound => 'User not found';

  @override
  String get errorNotAdmin => 'You are not allowed to access the admin page. Please select user.';

  @override
  String get passwordRequired => 'Password is required.';

  @override
  String get companyIdRequired => 'Company is required.';

  @override
  String get errorResetPasswordFailed => 'Could not send reset email. Please try again.';
}
