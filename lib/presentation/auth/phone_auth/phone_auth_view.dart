import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import 'phone_auth_controller.dart';

class PhoneAuthView extends GetView<PhoneAuthController> {
  const PhoneAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Login')),
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Obx(() => controller.isOtpSent.value
              ? _buildOtpSection()
              : _buildPhoneSection()),
        ),
      ),
    );
  }

  Widget _buildPhoneSection() {
    return Form(
      key: controller.phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Enter Phone Number',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll send a 6-digit OTP to verify your number.",
            style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: controller.phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[+\d]'))],
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '+91 98765 43210',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Phone number is required';
              if (v.trim().length < 10) return 'Enter a valid phone number';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Obx(() => CheckboxListTile(
                value: controller.keepLoggedIn.value,
                onChanged: (v) => controller.keepLoggedIn.value = v ?? true,
                title: const Text(
                  'Keep me logged in for 30 days',
                  style:
                      TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: AppTheme.primary,
              )),
          const SizedBox(height: 24),
          Obx(() => ElevatedButton(
                onPressed:
                    controller.isLoading.value ? null : controller.sendOtp,
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Send OTP'),
              )),
        ],
      ),
    );
  }

  Widget _buildOtpSection() {
    return Form(
      key: controller.otpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Verify OTP',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                'Enter the 6-digit code sent to ${controller.phoneCtrl.text}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, height: 1.5),
              )),
          const SizedBox(height: 32),
          TextFormField(
            controller: controller.otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 8),
            decoration: const InputDecoration(
              labelText: 'OTP Code',
              counterText: '',
            ),
            validator: (v) {
              if (v == null || v.length != 6) return 'Enter the 6-digit OTP';
              return null;
            },
          ),
          const SizedBox(height: 24),
          Obx(() => ElevatedButton(
                onPressed:
                    controller.isLoading.value ? null : controller.verifyOtp,
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Verify & Continue'),
              )),
          const SizedBox(height: 16),
          Center(
            child: Obx(() => controller.resendTimer.value > 0
                ? Text(
                    'Resend OTP in ${controller.resendTimer.value}s',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  )
                : TextButton(
                    onPressed: controller.sendOtp,
                    child: const Text('Resend OTP'),
                  )),
          ),
        ],
      ),
    );
  }
}
