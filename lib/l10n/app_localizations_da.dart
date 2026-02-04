// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get signInTitle => 'Log ind på Workforce';

  @override
  String get username => 'Brugernavn (Email)';

  @override
  String get password => 'Adgangskode';

  @override
  String get companyId => 'Virksomheds-ID';

  @override
  String get role => 'Rolle';

  @override
  String get workforce => 'Medarbejder';

  @override
  String get admin => 'Administrator';

  @override
  String get language => 'Sprog';

  @override
  String get signIn => 'Log ind';

  @override
  String get forgotPassword => 'Glemt password?';

  @override
  String get resetPasswordHint => 'Indtast din email';

  @override
  String get loginError => 'Ugyldigt login';

  @override
  String get usernameRequired => 'Brugernavn er påkrævet';

  @override
  String get errorInvalidLogin => 'Ugyldigt login';

  @override
  String get errorInvalidEmail => 'Ugyldig e-mailadresse';

  @override
  String get errorTooManyRequests => 'For mange forsøg. Prøv igen senere.';

  @override
  String get errorLoginFailed => 'Login fejlede. Prøv igen.';

  @override
  String get errorUserNotRegistered => 'Brugeren er ikke registreret i systemet';

  @override
  String get errorGeneric => 'Noget gik galt. Prøv igen.';

  @override
  String get emailRequired => 'Email kræves';

  @override
  String get invalidEmail => 'Indtast venligst en gyldig email';

  @override
  String get resetPasswordTitle => 'Nulstil adgangskode';

  @override
  String get resetPasswordSent => 'Hvis email findes, er en reset-link sendt.';

  @override
  String get errorUserNotFound => 'Brugeren blev ikke fundet';

  @override
  String get errorNotAdmin => 'Du har ikke tilladelse til admin-siden. Vælg venligst bruger.';

  @override
  String get passwordRequired => 'Password kræves.';

  @override
  String get companyIdRequired => 'Company ID kræves.';

  @override
  String get errorResetPasswordFailed => 'Kunne ikke sende reset email. Prøv igen.';
}
