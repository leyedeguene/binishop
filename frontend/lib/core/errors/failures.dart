/// BINISHOP — Failure types
library core.errors.failures;

import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

class ValidationFailure extends Failure {
  final Map<String, String>? errors;
  const ValidationFailure({required super.message, this.errors});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}

Failure mapApiResultError(String? error, int? statusCode) {
  if (error == null) return const UnknownFailure(message: 'Erreur inconnue');

  switch (statusCode) {
    case 401:
      return AuthFailure(message: error, statusCode: statusCode);
    case 403:
      return PermissionFailure(message: error);
    case 404:
      return NotFoundFailure(message: error);
    case 422:
      return ValidationFailure(message: error);
    case 500:
      return ServerFailure(message: error, statusCode: statusCode);
    default:
      return ServerFailure(message: error, statusCode: statusCode);
  }
}