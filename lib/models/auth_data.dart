class AuthData {
  late final String accessToken;
  final int expiresIn;
  final String refreshToken;
  final String tokenType;
  final String idToken;
  final int notBeforePolicy;
  final String sessionState;
  final String scope;

  AuthData({
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
    required this.tokenType,
    required this.idToken,
    required this.notBeforePolicy,
    required this.sessionState,
    required this.scope,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['access_token'],
      expiresIn: json['expires_in'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      idToken: json['id_token'],
      notBeforePolicy: json['not-before-policy'],
      sessionState: json['session_state'],
      scope: json['scope'],
    );
  }
}
