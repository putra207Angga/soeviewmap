import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'components/main.components.dart';
import 'controllers/authentifikasi.controller.dart';

class AuthentifikasiScreen extends GetView<AuthentifikasiController> {
  const AuthentifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D0E12)
          : const Color(0xFFF8FAFC), // Modern off-white slate base
      body: Stack(
        children: [
          // Ambient Glow Element 1 (Top-Right Bloom)
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF818CF8).withOpacity(0.12), // Indigo tint
              ),
            ),
          ),

          // Ambient Glow Element 2 (Bottom-Left Bloom)
          Positioned(
            bottom: -200,
            left: -200,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(
                  0xFF60A5FA,
                ).withOpacity(0.10), // Light blue tint
              ),
            ),
          ),

          // Glassmorphic Backdrop filter to diffuse the ambient glow circles
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox.shrink(),
            ),
          ),

          // Main View Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Obx(() {
                    switch (controller.authMode.value) {
                      case AuthMode.lock:
                        return LockScreenComponent(controller: controller);
                      case AuthMode.login:
                        return LoginFormComponent(controller: controller);
                    }
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
