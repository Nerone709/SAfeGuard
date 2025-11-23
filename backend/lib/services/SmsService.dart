import 'dart:math';

class SmsService {
  // Genera un codice OTP a 6 cifre
  String generateOtp() {
    final random = Random();
    // Genera un numero tra 100000 e 999999
    return (random.nextInt(900000) + 100000).toString();
  }

  // Simula l'invio dell'SMS
  Future<void> sendOtp(String telefono, String otp) async {
    // In un ambiente reale: userebbe Twilio, MessageBird o un altro provider SMS.
    await Future.delayed(const Duration(seconds: 1));
    print('--------------------------------------------------');
    print('SMS INVIATO a $telefono. Codice OTP: $otp');
    print('--------------------------------------------------');
  }
}