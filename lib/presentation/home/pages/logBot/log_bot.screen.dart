import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/log_bot.controller.dart';
import 'components/main.components.dart';

class LogBotScreen extends GetView<LogBotController> {
  const LogBotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D0E12)
          : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LogBotFiltersPanel(),
                  const SizedBox(height: 10),
                  const LogBotMetricsPanel(),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: context.width > 600 ? 520 : 400,
                    child: const LogBotConsolePanel(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
