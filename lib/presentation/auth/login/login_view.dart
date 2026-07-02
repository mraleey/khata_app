import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildForm(),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildGoogleButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Image.asset('assets/images/khata_logo.png'),
        ),
        const SizedBox(height: 20),
        const Text(
          'Digital Khata',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Track your cash. Stay in control.',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: controller.emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!GetUtils.isEmail(v.trim())) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          Obx(() => TextFormField(
                controller: controller.passwordCtrl,
                obscureText: !controller.isPasswordVisible.value,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(controller.isPasswordVisible.value
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'Min 6 characters';
                  return null;
                },
              )),
          const SizedBox(height: 8),
          Obx(() => CheckboxListTile(
                value: controller.keepLoggedIn.value,
                onChanged: controller.toggleKeepLoggedIn,
                title: const Text(
                  'Keep me logged in for 30 days',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: AppTheme.primary,
              )),
          const SizedBox(height: 20),
          Obx(() => ElevatedButton(
                onPressed:
                    controller.isLoading.value ? null : controller.signInWithEmail,
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ))
                    : const Text('Sign In'),
              )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Obx(() => OutlinedButton.icon(
          onPressed:
              controller.isLoading.value ? null : controller.signInWithGoogle,
          icon: Image.asset('assets/images/google.png', width: 20, height: 20),
          label: const Text('Continue with Google'),
        ));
  }
}
