abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  
  LoginEvent(this.email, this.password);
}

class RegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  
  RegisterEvent(this.name, this.email, this.password, this.role);
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;
  
  ForgotPasswordEvent(this.email);
}

class LogoutEvent extends AuthEvent {}