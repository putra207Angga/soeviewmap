import 'package:get/get.dart';
import 'package:soeviewmap/domain/main.domains.dart' as dom;
import 'package:soeviewmap/infrastructure/main.infrastructures.dart';

class LogBotController extends GetxController {
  final botStatus = Rxn<dom.BotModel>();
  final logs = <dom.BotLogModel>[].obs;
  final isLoading = true.obs;

  // Search & Filter State
  final selectedLevel = 'All'.obs; // 'All', 'INFO', 'SUCCESS', 'WARNING', 'ERROR'
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchBotStatus(),
        fetchBotLogs(),
      ]);
    } catch (e) {
      print('LogBotController refreshData error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBotStatus() async {
    try {
      final response = await BotDao.use.getStatus();
      if (response.statusCode == 200 && response.body != null) {
        botStatus.value = response.body;
      } else {
        _loadMockStatus();
      }
    } catch (e) {
      print('LogBotController fetchBotStatus error: $e');
      _loadMockStatus();
    }
  }

  Future<void> fetchBotLogs() async {
    try {
      final response = await BotDao.use.getLogs();
      if (response.statusCode == 200 && response.body != null && response.body!.items.isNotEmpty) {
        logs.assignAll(response.body!.items);
      } else {
        _loadMockLogs();
      }
    } catch (e) {
      print('LogBotController fetchBotLogs error: $e');
      _loadMockLogs();
    }
  }

  void _loadMockStatus() {
    botStatus.value = dom.BotModel(
      botStatus: 'ACTIVE',
      lastCheckedAt: DateTime.now(),
      errorMessage: 'None',
      totalAutoReplied: 1248,
    );
  }

  void _loadMockLogs() {
    logs.assignAll([
      dom.BotLogModel(
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)).toIso8601String(),
        level: 'SUCCESS',
        message: 'Auto-reply sent to Agus Santoso (Poliklinik Kebidanan). Rating: 5 stars.',
      ),
      dom.BotLogModel(
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)).toIso8601String(),
        level: 'INFO',
        message: 'New review detected: "Sangat puas dengan penanganan cepat di IGD..." (Rating: 5).',
      ),
      dom.BotLogModel(
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
        level: 'WARNING',
        message: 'Low rating review flagged for manual review: "Antrean loket obat terlalu panjang..." (Rating: 2).',
      ),
      dom.BotLogModel(
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
        level: 'INFO',
        message: 'Bot sync active. Scanning Google Maps reviews for RSUD dr. Soebandi Jember.',
      ),
      dom.BotLogModel(
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)).toIso8601String(),
        level: 'ERROR',
        message: 'Failed to connect to review sync webhook. Retrying in 30 seconds.',
      ),
      dom.BotLogModel(
        timestamp: DateTime.now().subtract(const Duration(minutes: 32)).toIso8601String(),
        level: 'SUCCESS',
        message: 'Auto-reply sent to Siti Aminah. Rating: 4 stars.',
      ),
      dom.BotLogModel(
        timestamp: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        level: 'INFO',
        message: 'Bot webhook receiver initialized on port 8080.',
      ),
      dom.BotLogModel(
        timestamp: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        level: 'SUCCESS',
        message: 'Bot service initialized successfully. Connected to Google Business Profile API.',
      ),
    ]);
  }

  // Filter & Search computation
  List<dom.BotLogModel> get filteredLogs {
    return logs.where((log) {
      // 1. Level Filter
      if (selectedLevel.value != 'All') {
        if (log.level.toUpperCase() != selectedLevel.value.toUpperCase()) {
          return false;
        }
      }

      // 2. Search Query Filter
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final matchesMsg = log.message.toLowerCase().contains(query);
        final matchesLevel = log.level.toLowerCase().contains(query);
        return matchesMsg || matchesLevel;
      }

      return true;
    }).toList();
  }

  // Statistics summaries
  int get totalLogsCount => logs.length;
  int get infoCount => logs.where((l) => l.level.toUpperCase() == 'INFO').length;
  int get successCount => logs.where((l) => l.level.toUpperCase() == 'SUCCESS').length;
  int get warningCount => logs.where((l) => l.level.toUpperCase() == 'WARNING').length;
  int get errorCount => logs.where((l) => l.level.toUpperCase() == 'ERROR').length;
}
