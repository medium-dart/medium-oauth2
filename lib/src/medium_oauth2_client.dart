// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

// Dart imports:
import 'dart:convert';
import 'dart:math';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'auth/base_web_auth.dart';
import 'auth/web_auth.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'auth/io_web_auth.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'auth/browser_web_auth.dart';
import 'medium_oauth_exception.dart';
import 'response/authorization_response.dart';
import 'response/oauth_response.dart';
import 'scope.dart';

/// This client authenticates according to `OAuth 2.0`, which
/// is supported by `Medium`.
abstract class MediumOAuth2Client {
  /// Returns the new instance of [MediumOAuth2Client].
  ///
  /// ## Parameters
  ///
  /// - [clientId]: The unique ID of your client application.
  ///
  /// - [clientSecret]: The unique secret ID of your client application.
  ///
  /// - [redirectUri]: Specify the redirect URI of the configured client
  ///                  application.
  ///
  /// - [customUriScheme]: Specify a redirect URI without the `://xxxx` suffix.
  factory MediumOAuth2Client({
    required String clientId,
    required String clientSecret,
    required String redirectUri,
    required String customUriScheme,
  }) =>
      _MediumOAuth2Client(
        clientId: clientId,
        clientSecret: clientSecret,
        redirectUri: redirectUri,
        customUriScheme: customUriScheme,
      );

  /// Performs the authentication process according to `OAuth 2.0` and outputs
  /// the `Medium authentication form`.
  ///
  /// ## Parameters
  ///
  /// - [scopes]: Specify the list of scopes of privileges you want to grant
  ///             to the authenticated access token.
  Future<OAuthResponse> executeAuthCodeFlow({
    required List<Scope> scopes,
  });
}

/// The implementation of [MediumOAuth2Client].
class _MediumOAuth2Client implements MediumOAuth2Client {
  /// Returns the new instance of [_MediumOAuth2Client].
  _MediumOAuth2Client({
    required String clientId,
    required String clientSecret,
    required String redirectUri,
    required String customUriScheme,
  })  : _clientId = clientId,
        _clientSecret = clientSecret,
        _redirectUri = redirectUri,
        _customUriScheme = customUriScheme;

  final String _clientId;
  final String _clientSecret;
  final String _redirectUri;
  final String _customUriScheme;

  final BaseWebAuth _webAuthClient = createWebAuth();

  @override
  Future<OAuthResponse> executeAuthCodeFlow({
    required List<Scope> scopes,
  }) async =>
      await _requestAccessToken(
        code: (await _requestAuthorization(scopes: scopes)).code,
      );

  Future<AuthorizationResponse> _requestAuthorization({
    required List<Scope> scopes,
  }) async {
    final String state = _generateSecureAlphaNumeric(25);

    final redirectedUri = await _webAuthClient.authenticate(
      uri: Uri.https(
        'medium.com',
        '/m/oauth/authorize',
        {
          'client_id': _clientId,
          'scope': scopes.map((scope) => scope.value).join(','),
          'state': state,
          'response_type': 'code',
          'redirect_uri': _redirectUri,
        },
      ),
      callbackUrlScheme: _customUriScheme,
      redirectUrl: _redirectUri,
    );

    final queryParameters = Uri.parse(redirectedUri).queryParameters;

    if (queryParameters.containsKey('error')) {
      throw MediumOAuthException(queryParameters['error_description'] ?? '');
    }

    if (queryParameters['state'] != state) {
      throw const MediumOAuthException(
        'Did not match the expected state value.',
      );
    }

    return AuthorizationResponse(
      code: queryParameters['code']!,
    );
  }

  Future<OAuthResponse> _requestAccessToken({
    required String code,
  }) async {
    final response = await http.post(
      Uri.https('api.medium.com', '/v1/tokens'),
      body: {
        'code': code,
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'grant_type': 'authorization_code',
        'redirect_uri': _redirectUri,
      },
    );

    return OAuthResponse.fromJson(
      jsonDecode(response.body),
    );
  }

  String _generateSecureAlphaNumeric(final int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(255));

    return base64UrlEncode(values);
  }
}
