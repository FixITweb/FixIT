abstract class AuthEvent {}


class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  LoginEvent(this.username, this.password);
}


class RegisterEvent extends AuthEvent {
  final String username;
  final String password;
  final String role;
  final String phone;
  final double? latitude;
  final double? longitude;

  RegisterEvent(
    this.username,
    this.password,
    this.role,
    this.phone, {
    this.latitude,
    this.longitude,
  });
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  ForgotPasswordEvent(this.email);
}

class LogoutEvent extends AuthEvent {}
