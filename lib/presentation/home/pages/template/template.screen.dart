part of '../main.pages.dart';

class TemplateScreen extends GetView<TemplateController> {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D0E12)
          : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Page Header Panel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pengaturan Template Balasan Otomatis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Atur pesan balasan berdasarkan rating bintang pelanggan.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _openCreateCustomDialog(context),
                          icon: const Icon(Icons.add_rounded, size: 14),
                          label: const Text(
                            'New Template',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _confirmResetDialog(context),
                          icon: const Icon(Icons.restore_rounded, size: 14),
                          label: const Text(
                            'Reset Default',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Webhook & Secret Token configuration panel
                const BotConfigPanel(),
                const SizedBox(height: 20),

                // 3. Grid/Column of Star Templates
                Text(
                  'TEMPLATE BERDASARKAN BINTANG',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),

                Obx(() {
                  final templates = controller.starTemplates;
                  if (templates.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // Star ratings from 5 down to 1
                  final starsKeys = [5, 4, 3, 2, 1];
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: starsKeys.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final rating = starsKeys[index];
                      final templateText = templates[rating] ?? '';
                      return TemplateCard(
                        rating: rating,
                        templateText: templateText,
                        onEditTap: () =>
                            _openEditDialog(context, rating, templateText),
                        onDeleteTap: () =>
                            _confirmDeleteTemplate(context, rating),
                      );
                    },
                  );
                }),
                
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TEMPLATE KUSTOM (LOKASI / KATA KUNCI)',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openCreateCustomDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 14),
                      label: const Text(
                        'Tambah Kustom',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Obx(() {
                  final customList = controller.customTemplates;
                  if (customList.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withOpacity(0.1) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Text(
                          'Belum ada template kustom. Silakan klik Tambah Kustom atau New Template di bagian atas.',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = customList[index];
                      return _buildCustomTemplateCard(context, item, isDark, theme);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTemplateCard(BuildContext context, CustomTemplate item, bool isDark, ThemeData theme) {
    return GlassContainer(
      glowColor: item.triggerType == 'Lokasi' ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B),
      glowOpacity: 0.01,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.triggerType == 'Lokasi'
                              ? Colors.blue.shade50
                              : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: item.triggerType == 'Lokasi'
                                ? Colors.blue.shade200
                                : Colors.amber.shade200,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.triggerType == 'Lokasi'
                                  ? Icons.location_on_rounded
                                  : Icons.key_rounded,
                              size: 10,
                              color: item.triggerType == 'Lokasi'
                                  ? Colors.blue.shade700
                                  : Colors.amber.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.triggerType.toUpperCase(),
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: item.triggerType == 'Lokasi'
                                    ? Colors.blue.shade700
                                    : Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _openEditCustomDialog(context, item),
                      icon: Icon(Icons.edit_rounded, size: 16, color: theme.colorScheme.primary),
                      tooltip: 'Edit Template',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                    IconButton(
                      onPressed: () => _confirmDeleteCustomTemplate(context, item),
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                      tooltip: 'Hapus Template',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Pemicu: "${item.triggerValue}"',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.1) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200, width: 0.8),
              ),
              child: Text(
                item.templateText,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditDialog(BuildContext context, int rating, String initialText) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return TemplateEditDialog(
          rating: rating,
          initialText: initialText,
          controller: controller,
        );
      },
    );
  }

  void _openCreateCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CustomTemplateEditDialog(
          controller: controller,
        );
      },
    );
  }

  void _openEditCustomDialog(BuildContext context, CustomTemplate item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CustomTemplateEditDialog(
          initialTemplate: item,
          controller: controller,
        );
      },
    );
  }

  void _confirmDeleteCustomTemplate(BuildContext context, CustomTemplate item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E222B) : Colors.white,
          title: const Text(
            'Hapus Template Kustom',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus template kustom "${item.name}"?',
            style: const TextStyle(fontSize: 11, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Batal',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.removeCustomTemplate(item.id);
                Get.back();
                Get.snackbar(
                  'Berhasil Dihapus',
                  'Template kustom telah dihapus.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: isDark ? const Color(0xFF1E222B) : Colors.white.withOpacity(0.95),
                  colorText: isDark ? Colors.white : Colors.black,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Hapus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteTemplate(BuildContext context, int rating) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E222B) : Colors.white,
          title: const Text(
            'Hapus Template Bintang',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus template untuk bintang $rating?',
            style: const TextStyle(fontSize: 11, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Batal',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.deleteTemplate(rating);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Hapus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _confirmResetDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E222B) : Colors.white,
          title: const Text(
            'Reset Template',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menyetel ulang semua template ke teks bawaan RSUD Soebandi?',
            style: TextStyle(fontSize: 11, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Batal',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.resetTemplates();
                Get.back();
                Get.snackbar(
                  'Berhasil Reset',
                  'Semua template telah dikembalikan ke pengaturan awal.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: isDark ? const Color(0xFF1E222B) : Colors.white.withOpacity(0.95),
                  colorText: isDark ? Colors.white : Colors.black,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Reset',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
