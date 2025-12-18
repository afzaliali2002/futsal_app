import 'dart:convert';
import 'package:http/http.dart' as http;

class WhatsappOtpService {
  // TODO: Replace with your WPPConnect server URL and session name
  final String _baseUrl = 'http://localhost:21465/api';
  final String _session = 'futsal-app'; // Or your chosen session name

  // TODO: Replace with your secret key if you have one configured on the WPPConnect server
  final String _secretKey = 'YOUR_SECRET_KEY';

  /// Sends an OTP code to the given phone number using your WPPConnect server.
  ///
  /// The [phoneNumber] should be the number with the country code, without '+' or '00'.
  /// Example: '93712345678'
  Future<bool> sendOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    // WPPConnect endpoint for sending a text message
    final String url = '$_baseUrl/$_session/send-text';

    // You can customize your message here
    final String message = 'Your Futsal App verification code is: $otpCode';

    final payload = {
      'phone': phoneNumber,
      'message': message,
      'isGroup': false,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // If you configured a secret key on your server, uncomment and use the correct header.
          // Some setups use 'Authorization': 'Bearer $_secretKey',
          'x-auth-token': _secretKey,
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('WhatsApp OTP sent successfully via WPPConnect.');
        return true;
      } else {
        print('Failed to send WhatsApp OTP via WPPConnect: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('An error occurred while sending WhatsApp OTP via WPPConnect: $e');
      return false;
    }
  }
}
