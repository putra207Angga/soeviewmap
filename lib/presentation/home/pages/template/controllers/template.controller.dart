part of '../../main.pages.dart';

class CustomTemplate {
  final String id;
  final String name;
  final String triggerType; // 'Lokasi' or 'Kata Kunci'
  final String triggerValue;
  final String templateText;

  CustomTemplate({
    required this.id,
    required this.name,
    required this.triggerType,
    required this.triggerValue,
    required this.templateText,
  });

  CustomTemplate copyWith({
    String? name,
    String? triggerType,
    String? triggerValue,
    String? templateText,
  }) {
    return CustomTemplate(
      id: id,
      name: name ?? this.name,
      triggerType: triggerType ?? this.triggerType,
      triggerValue: triggerValue ?? this.triggerValue,
      templateText: templateText ?? this.templateText,
    );
  }
}

class TemplateController extends GetxController {
  // Bot connection and configurations
  final botActiveStatus = true.obs;
  final botStatusMessage = 'Menghubungkan ke bot...'.obs;
  final lastCheckedTime = '-'.obs;
  final totalAutoRepliedCount = 0.obs;

  // Star templates configuration
  final starTemplates = <int, String>{}.obs;

  // Custom templates configuration (by Location / Keyword)
  final customTemplates = <CustomTemplate>[].obs;

  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBost();
    fetchTemplates();
  }

  Future<void> fetchBost() async {
    try {
      final response = await BotDao.use.getStatus();
      if (response.statusCode == 200 && response.body != null) {
        final bot = response.body!;
        botActiveStatus.value = bot.botStatus.toUpperCase() == "ACTIVE";
        botStatusMessage.value = bot.errorMessage.isNotEmpty 
            ? bot.errorMessage 
            : "Semua sistem berjalan normal.";
        
        final time = bot.lastCheckedAt;
        lastCheckedTime.value = "${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} "
            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
        
        totalAutoRepliedCount.value = bot.totalAutoReplied;
      } else {
        botActiveStatus.value = false;
        botStatusMessage.value = "Gagal memuat status bot dari server.";
      }
    } catch (e) {
      print('TemplateController fetchBost error: $e');
      botActiveStatus.value = false;
      botStatusMessage.value = "Error koneksi: $e";
    }
  }

  Future<void> fetchTemplates() async {
    isLoading.value = true;
    try {
      final response = await TemplateDao.use.getTemplates();
      if (response.statusCode == 200 && response.body != null) {
        final List<dom.ReviewTemplateModel> apiTemplates = response.body!.items;
        final map = <int, String>{};
        for (var item in apiTemplates) {
          map[item.rating] = item.templateText;
        }
        starTemplates.assignAll(map);
      } else {
        _loadDefaultTemplates();
      }
    } catch (e) {
      print('TemplateController fetchTemplates error: $e');
      _loadDefaultTemplates();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadDefaultTemplates() {
    starTemplates.assignAll({
      5: 'Terima kasih atas penilaian bintang 5 Anda! Kami sangat senang mengetahui bahwa Anda puas dengan pelayanan di RSUD Soebandi. Semoga lekas sembuh dan sehat selalu.',
      4: 'Terima kasih atas penilaian dan masukan Anda. Kami akan terus berusaha meningkatkan kualitas pelayanan kami agar bisa memberikan pengalaman yang lebih baik lagi bagi pasien.',
      3: 'Terima kasih atas ulasan Anda. Kami menyadari masih ada ruang untuk perbaikan. Masukan Anda sangat berharga bagi kami untuk mengevaluasi dan meningkatkan standar pelayanan rumah sakit.',
      2: 'Kami memohon maaf atas ketidaknyamanan yang Anda alami selama mendapatkan pelayanan di RSUD Soebandi. Keluhan Anda telah kami catat dan akan segera ditindaklanjuti oleh unit terkait.',
      1: 'Kami sangat menyesal atas pengalaman buruk yang Anda dapatkan. Hal ini tidak mencerminkan standar pelayanan kami. Mohon kesediaannya untuk menghubungi Customer Care kami di nomor 0811-XXXX-XXXX agar kami dapat menginvestigasi masalah ini lebih lanjut.',
    });

    customTemplates.assignAll([
      CustomTemplate(
        id: 'ct_1',
        name: 'Auto-Reply IGD RSUD Soebandi',
        triggerType: 'Lokasi',
        triggerValue: 'Instalasi Gawat Darurat (IGD)',
        templateText:
            'Halo {reviewerName}, terima kasih atas ulasan Anda mengenai pelayanan IGD RSUD Soebandi. Penanganan medis darurat yang responsif adalah prioritas kami. Semoga lekas sembuh.',
      ),
      CustomTemplate(
        id: 'ct_2',
        name: 'Penanganan Komplain Antrean',
        triggerType: 'Kata Kunci',
        triggerValue: 'antri',
        templateText:
            'Halo {reviewerName}, mohon maaf atas ketidaknyamanan terkait waktu antrean di {locationName}. Kami terus melakukan perbaikan alur antrean loket dan pendaftaran online.',
      ),
    ]);
  }

  Future<void> updateTemplate(int rating, String text) async {
    isLoading.value = true;
    try {
      final exists =
          starTemplates.containsKey(rating) &&
          starTemplates[rating] != null &&
          starTemplates[rating]!.isNotEmpty;
      final response = exists
          ? await TemplateDao.use.updateTemplate(
              rating: rating,
              templateText: text,
            )
          : await TemplateDao.use.saveTemplate(
              rating: rating,
              templateText: text,
            );
      if (response.statusCode == 200 || response.statusCode == 201) {
        starTemplates[rating] = text;
        starTemplates.refresh();
        Get.snackbar(
          'Sukses',
          exists
              ? 'Template balasan berhasil diperbarui di server.'
              : 'Template balasan baru berhasil dibuat di server.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal menyimpan template: ${response.statusText}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade900,
          icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      print('TemplateController updateTemplate error: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menyimpan template: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addCustomTemplate(CustomTemplate template) {
    customTemplates.add(template);
  }

  void removeCustomTemplate(String id) {
    customTemplates.removeWhere((t) => t.id == id);
  }

  void updateCustomTemplate(CustomTemplate template) {
    final idx = customTemplates.indexWhere((t) => t.id == template.id);
    if (idx != -1) {
      customTemplates[idx] = template;
    }
  }

  void toggleBotStatus() {
    botActiveStatus.value = !botActiveStatus.value;
  }

  void resetTemplates() {
    fetchTemplates();
  }

  Future<void> deleteTemplate(int rating) async {
    isLoading.value = true;
    try {
      final response = await TemplateDao.use.deleteTemplate(rating: rating);
      if (response.statusCode == 200) {
        starTemplates.remove(rating);
        starTemplates.refresh();
        Get.snackbar(
          'Sukses',
          'Template bintang $rating berhasil dihapus.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade900,
          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        Get.snackbar(
          'Gagal',
          'Gagal menghapus template: ${response.statusText}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade900,
          icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      print('TemplateController deleteTemplate error: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menghapus template: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
