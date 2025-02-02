import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:project_raion/service/api_service.dart';

void main() {
  group('ApiService Test', () {
    test('Register User Test with unique email', () async {
      final response = await ApiService.registerUser('gogi15@gmail.com', "testuser", "testpassword");
      expect(response['status'], 'success');
    });

    test('Login User Test and Validate Token Format', () async {
      final loginResult = await ApiService.loginUser("gog1@gmail.com", "gog123");
      expect(loginResult['status'], 'success');
      expect(loginResult['data']['token'], startsWith('Bearer'));
    });

  });
}
