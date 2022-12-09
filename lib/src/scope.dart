// Copyright 2022 Kato Shinya. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided the conditions.

/// OAuth 2.0 scope for `Medium`.
enum Scope {
  /// Grants basic access to a user’s profile (not including their email).
  basicProfile,

  /// Grants the ability to list publications related to the user.
  listPublications,

  /// Grants the ability to publish a post to the user’s profile.
  publishPost,

  /// Grants the ability to upload an image for use within a Medium post.
  uploadImage;

  /// Returns the scope value.
  String get value => name;

  const Scope();

  /// Returns the scope associated with [value],
  /// otherwise [ArgumentError] will be thrown.
  static Scope valueOf(final String value) {
    for (final scope in values) {
      if (scope.value == value) {
        return scope;
      }
    }

    throw ArgumentError('Invalid scope value: $value');
  }
}
