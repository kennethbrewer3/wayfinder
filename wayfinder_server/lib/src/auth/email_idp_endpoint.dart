import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Email identity provider endpoints.
///
/// Public self-registration is disabled — TOC admins create accounts.
class EmailIdpEndpoint extends EmailIdpBaseEndpoint {
  @override
  Future<UuidValue> startRegistration(
    Session session, {
    required String email,
  }) {
    throw Exception(
      'Public registration is disabled. Ask a TOC administrator to create '
      'your account.',
    );
  }

  @override
  Future<String> verifyRegistrationCode(
    Session session, {
    required UuidValue accountRequestId,
    required String verificationCode,
  }) {
    throw Exception(
      'Public registration is disabled. Ask a TOC administrator to create '
      'your account.',
    );
  }

  @override
  Future<AuthSuccess> finishRegistration(
    Session session, {
    required String registrationToken,
    required String password,
  }) {
    throw Exception(
      'Public registration is disabled. Ask a TOC administrator to create '
      'your account.',
    );
  }
}
