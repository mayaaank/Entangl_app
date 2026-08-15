import 'package:flutter_test/flutter_test.dart';
import 'package:entangl_app/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('fromJson constructs correct model', () {
      final json = {
        'id': 'user-123',
        'username': 'johndoe',
        'full_name': 'John Doe',
        'bio': 'Hello world',
        'avatar_url': 'https://example.com/avatar.png',
        'created_at': '2026-05-22T20:00:00Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.username, 'johndoe');
      expect(user.fullName, 'John Doe');
      expect(user.bio, 'Hello world');
      expect(user.avatarUrl, 'https://example.com/avatar.png');
      expect(user.createdAt, '2026-05-22T20:00:00Z');
    });

    test('toJson returns correct map', () {
      const user = UserModel(
        id: 'user-123',
        username: 'johndoe',
        fullName: 'John Doe',
        bio: 'Hello world',
        avatarUrl: 'https://example.com/avatar.png',
        createdAt: '2026-05-22T20:00:00Z',
      );

      final json = user.toJson();

      expect(json['id'], 'user-123');
      expect(json['username'], 'johndoe');
      expect(json['full_name'], 'John Doe');
      expect(json['bio'], 'Hello world');
      expect(json['avatar_url'], 'https://example.com/avatar.png');
      expect(json['created_at'], '2026-05-22T20:00:00Z');
    });

    test('copyWith updates fields correctly', () {
      const user = UserModel(
        id: 'user-123',
        username: 'johndoe',
        fullName: 'John Doe',
        createdAt: '2026-05-22T20:00:00Z',
      );

      final updated = user.copyWith(
        username: 'john_doe',
        bio: 'New bio',
      );

      expect(updated.id, 'user-123');
      expect(updated.username, 'john_doe');
      expect(updated.fullName, 'John Doe');
      expect(updated.bio, 'New bio');
      expect(updated.avatarUrl, isNull);
    });

    test('legacy profiles without status are approved', () {
      final user = UserModel.fromJson({
        'id': 'user-123',
        'username': 'johndoe',
        'full_name': 'John Doe',
        'created_at': '2026-05-22T20:00:00Z',
      });
      expect(user.status, 'approved');
      expect(user.isApproved, isTrue);
    });

    test('pending profiles are not approved', () {
      const user = UserModel(
        id: 'u',
        username: 'x',
        fullName: 'X',
        createdAt: '',
        status: 'pending',
      );
      expect(user.isApproved, isFalse);
    });
  });
}
