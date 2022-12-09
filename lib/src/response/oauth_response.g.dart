// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_OAuthResponse _$$_OAuthResponseFromJson(Map<String, dynamic> json) =>
    _$_OAuthResponse(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      refreshToken: json['refreshToken'] as String,
      scopes: const ScopeConverter().fromJson(json['scope'] as String),
      createdAt: const DateTimeConverter().fromJson(json['createdAt'] as int),
    );

Map<String, dynamic> _$$_OAuthResponseToJson(_$_OAuthResponse instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'tokenType': instance.tokenType,
      'refreshToken': instance.refreshToken,
      'scope': const ScopeConverter().toJson(instance.scopes),
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
    };
