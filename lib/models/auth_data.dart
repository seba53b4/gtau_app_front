class AuthData {
  late final String accessToken;
  late int? expiresIn;
  final String refreshToken;
  late String? tokenType;
  late String? idToken;
  late int? notBeforePolicy;
  late String? sessionState;
  late String? scope;

  AuthData({
    required this.accessToken,
    this.expiresIn,
    required this.refreshToken,
    this.tokenType,
    this.idToken,
    this.notBeforePolicy,
    this.sessionState,
    this.scope,
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
