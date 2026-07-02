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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 950;

            if (isWide) {
              // Desktop Viewport Layout
              final isTallEnough = constraints.maxHeight > 750;

              Widget content = Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const LogBotFiltersPanel(),
                    const SizedBox(height: 16),
                    const LogBotMetricsPanel(),
                    const SizedBox(height: 16),
                    isTallEnough
                        ? const Expanded(child: LogBotConsolePanel())
                        : const SizedBox(
                            height: 480,
                            child: LogBotConsolePanel(),
                          ),
                  ],
                ),
              );

              if (!isTallEnough) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: content,
                );
              }
              return content;
            } else {
              // Mobile/Tablet Scrollable Column Layout with Pull-to-Refresh
              return RefreshIndicator(
                onRefresh: () => controller.refreshData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const LogBotFiltersPanel(),
                        const SizedBox(height: 16),
                        const LogBotMetricsPanel(),
                        const SizedBox(height: 16),
                        const SizedBox(
                          height: 520,
                          child: LogBotConsolePanel(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
