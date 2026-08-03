import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soeviewmap/domain/main.domains.dart';
import 'package:soeviewmap/infrastructure/main.infrastructures.dart';

class HomeController extends GetxController {
  final selectedNavIndex = NavMenu.dashboard.obs;
  final userProfile = Rxn<UserProfile>();
  final isLoadingProfile = false.obs;

  // Notifications State
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoadingNotifications = false.obs;
  Timer? _pollingTimer;

  // Settings State
  final isFilterProfanity = true.obs;
  final isDarkMode = false.obs;
  final notificationLimit = 50.obs;
  final selectedLanguage = 'id_ID'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();

    fetchUserProfile().then((_) {
      if (userProfile.value != null) {
        fetchNotifications();
        fetchUnreadCount();
        startPolling();
      }
    });
  }

  void loadSettings() {
    isFilterProfanity.value = SecureStorageServices.to.readBool(
      'settings_filter_profanity',
      defaultValue: true,
    );
    isDarkMode.value = SecureStorageServices.to.readBool(
      'settings_dark_mode',
      defaultValue: false,
    );
    notificationLimit.value =
        int.tryParse(
          SecureStorageServices.to.read('settings_notification_limit') ?? '50',
        ) ??
        50;
    selectedLanguage.value =
        SecureStorageServices.to.read('settings_app_language') ?? 'id_ID';
  }

  Future<void> fetchUserProfile() async {
    isLoadingProfile.value = true;
    print('HomeController: Starting fetchUserProfile...');
    try {
      final response = await AuthDao.use.getProfile();
      print(
        'HomeController: Profile loaded successfully: ${response.request!.headers}',
      );
      if (response.statusCode == 200 && response.body != null) {
        userProfile.value = response.body;
        print(
          'HomeController: Profile loaded successfully: ${userProfile.value?.name}',
        );
      }
    } catch (e) {
      print('HomeController: Exception in fetchUserProfile: $e');
    } finally {
      isLoadingProfile.value = false;
      print(
        'HomeController: fetchUserProfile finished. isLoadingProfile: ${isLoadingProfile.value}',
      );
    }
  }

  Future<void> fetchNotifications() async {
    isLoadingNotifications.value = true;
    try {
      final response = await NotificationDao.use.getNotifications(
        limit: notificationLimit.value,
      );
      if (response.statusCode == 200 && response.body != null) {
        notifications.value = response.body!.items;
      }
    } catch (e) {
      print('HomeController: fetchNotifications exception: $e');
    } finally {
      isLoadingNotifications.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await NotificationDao.use.getUnreadCount();
      if (response.statusCode == 200 && response.body != null) {
        unreadCount.value = response.body!;
      }
    } catch (e) {
      print('HomeController: fetchUnreadCount exception: $e');
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final response = await NotificationDao.use.markAsRead(notificationId);
      if (response.statusCode == 200 && response.body == true) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final oldNotif = notifications[index];
          notifications[index] = NotificationModel(
            id: oldNotif.id,
            title: oldNotif.title,
            body: oldNotif.body,
            status: oldNotif.status,
            reviewerName: oldNotif.reviewerName,
            rating: oldNotif.rating,
            url: oldNotif.url,
            isRead: true,
            createdAt: oldNotif.createdAt,
          );
          notifications.refresh();
        }
        await fetchUnreadCount();
      }
    } catch (e) {
      print('HomeController: markNotificationAsRead exception: $e');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      final response = await NotificationDao.use.markAllAsRead();
      if (response.statusCode == 200 && response.body == true) {
        for (var i = 0; i < notifications.length; i++) {
          final oldNotif = notifications[i];
          if (!oldNotif.isRead) {
            notifications[i] = NotificationModel(
              id: oldNotif.id,
              title: oldNotif.title,
              body: oldNotif.body,
              status: oldNotif.status,
              reviewerName: oldNotif.reviewerName,
              rating: oldNotif.rating,
              url: oldNotif.url,
              isRead: true,
              createdAt: oldNotif.createdAt,
            );
          }
        }
        notifications.refresh();
        unreadCount.value = 0;
      }
    } catch (e) {
      print('HomeController: markAllNotificationsAsRead exception: $e');
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (userProfile.value != null) {
        fetchNotifications();
        fetchUnreadCount();
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    stopPolling();
    super.onClose();
  }

  Future<String> getVapidPublicKey() async {
    try {
      final response = await NotificationDao.use.getVapidPublicKey();
      if (response.statusCode == 200 && response.body != null) {
        return response.body!;
      }
    } catch (e) {
      print('HomeController: getVapidPublicKey exception: $e');
    }
    return '';
  }

  Future<bool> subscribeDevice(PushSubscriptionCreate subscription) async {
    try {
      final response = await NotificationDao.use.subscribeDevice(subscription);
      if (response.statusCode == 200 && response.body != null) {
        return response.body!;
      }
    } catch (e) {
      print('HomeController: subscribeDevice exception: $e');
    }
    return false;
  }

  Future<bool> unsubscribeDevice(String endpoint) async {
    try {
      final response = await NotificationDao.use.unsubscribeDevice(endpoint);
      if (response.statusCode == 200 && response.body != null) {
        return response.body!;
      }
    } catch (e) {
      print('HomeController: unsubscribeDevice exception: $e');
    }
    return false;
  }

  void saveSettings() {
    SecureStorageServices.to.writeBool(
      'settings_filter_profanity',
      isFilterProfanity.value,
    );
    SecureStorageServices.to.writeBool('settings_dark_mode', isDarkMode.value);
    SecureStorageServices.to.write(
      'settings_notification_limit',
      notificationLimit.value.toString(),
    );
    // Save & apply language change
    TranslationService.changeLanguage(selectedLanguage.value);

    // Apply theme change
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // Refresh notifications with new limit
    fetchNotifications();

    Get.back();
    Get.snackbar(
      'save_settings'.tr,
      'language_changed'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade900,
      icon: const Icon(Icons.check_circle_outline, color: Colors.green),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  String censorText(String text) {
    if (!isFilterProfanity.value) return text;
    final badWords = [
      'anjing',
      'babi',
      'goblok',
      'tolol',
      'bangsat',
      'kontol',
      'memek',
      'peler',
      'ngentot',
      'jembut',
      'pantek',
      'asu',
      'bajingan',
    ];
    String censored = text;
    for (final word in badWords) {
      censored = censored.replaceAll(
        RegExp(RegExp.escape(word), caseSensitive: false),
        '***',
      );
    }
    return censored;
  }

  void toNavigation(int index) {
    final menu = NavMenu.values.firstWhere((e) => e.index == index);
    selectedNavIndex.value = menu;
  }
}
