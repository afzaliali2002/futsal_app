import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpService {
  // TODO: Replace with your actual API endpoint
  final String _apiUrl = 'https://api.otpservice.com/send'; 
  // TODO: Replace with your actual API key if required
  final String _apiKey = 'YOUR_API_KEY'; 

  Future<bool> sendOtp({
    required String phoneNumber,
    required String otpCode,
    required int validityInMinutes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey', // Or other auth method
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otpCode': otpCode,
          'validity': validityInMinutes,
        }),
      );

      if (response.statusCode == 200) {
        // OTP sent successfully
        print('OTP sent successfully');
        return true;
      } else {
        // Handle error
        print('Failed to send OTP: ${response.body}');
        return false;
      }
    } catch (e) {
      print('An error occurred while sending OTP: $e');
      return false;
    }
  }
}
