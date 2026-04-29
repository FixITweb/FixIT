abstract class AuthEvent {}

// class LoginEvent extends AuthEvent {
//   final String email;
//   final String password;
  
//   LoginEvent(this.email, this.password);
// }

class LoginEvent extends AuthEvent {
  final String username;
  final String password;

  LoginEvent(this.username, this.password);
}

// class RegisterEvent extends AuthEvent {
//   final String name;
//   final String email;
//   final String password;
//   final String role;
  
//   RegisterEvent(this.name, this.email, this.password, this.role);
// }

class RegisterEvent extends AuthEvent {
  final String username;
  final String password;
  final String role;
  final String phone;

  RegisterEvent(this.username, this.password, this.role, this.phone);
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;
  
  ForgotPasswordEvent(this.email);
}

class LogoutEvent extends AuthEvent {}
