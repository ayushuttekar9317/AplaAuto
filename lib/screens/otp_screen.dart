import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'profile_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otpCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade300,
        title: const Text("Verify OTP", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter the 6-digit OTP sent to your number",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            OtpTextField(
              numberOfFields: 6,
              borderColor: Colors.deepPurple,
              focusedBorderColor: Colors.deepPurpleAccent,
              showFieldAsBox: true,
              fieldWidth: 45,
              onCodeChanged: (String code) {},
              onSubmit: (String verificationCode) {
                // When user completes typing all 6 digits
                setState(() {
                  otpCode = verificationCode;
                });

                // Simulate OTP verification (for now, just navigate)
                Future.delayed(const Duration(milliseconds: 500), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Didn’t receive the code?",
              style: TextStyle(color: Colors.grey),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("OTP resent!")));
              },
              child: const Text(
                "Resend OTP",
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
