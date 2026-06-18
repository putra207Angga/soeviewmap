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
  final webhookUrl = 'https://api.soebandibot.xyz/v1/google-maps/webhook'.obs;
  final secretToken = 'sb_sec_99182x_gtx_z'.obs;

  // Star templates configuration
  final starTemplates = <int, String>{}.obs;

  // Custom templates configuration (by Location / Keyword)
  final customTemplates = <CustomTemplate>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDefaultTemplates();
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

  void updateTemplate(int rating, String text) {
    starTemplates[rating] = text;
    starTemplates.refresh();
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
    _loadDefaultTemplates();
  }
}
