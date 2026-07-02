part of 'main.components.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = Get.find<HomeController>();

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF13151A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.settings_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Pengaturan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(height: 1, color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade100),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MODERASI KONTEN & FILTER',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => _buildSettingsSwitch(
                        title: 'Sensor Kata Kasar',
                        subtitle: 'Secara otomatis menyensor kata kasar pada ulasan (misal: ***).',
                        value: controller.isFilterProfanity.value,
                        onChanged: (val) {
                          controller.isFilterProfanity.value = val;
                        },
                        isDark: isDark,
                        theme: theme,
                      )),
                      
                      const SizedBox(height: 28),
                      
                      Text(
                        'TAMPILAN & NOTIFIKASI',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() => _buildSettingsSwitch(
                        title: 'Tema Gelap (Dark Mode)',
                        subtitle: 'Ubah tema antarmuka aplikasi menjadi gelap.',
                        value: controller.isDarkMode.value,
                        onChanged: (val) {
                          controller.isDarkMode.value = val;
                        },
                        isDark: isDark,
                        theme: theme,
                      )),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Batas Riwayat Notifikasi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Jumlah notifikasi yang ditarik dari server.',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => DropdownButtonFormField<int>(
                            value: controller.notificationLimit.value,
                            items: const [
                              DropdownMenuItem(value: 20, child: Text('20 Notifikasi')),
                              DropdownMenuItem(value: 50, child: Text('50 Notifikasi')),
                              DropdownMenuItem(value: 100, child: Text('100 Notifikasi')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                controller.notificationLimit.value = val;
                              }
                            },
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? Colors.black.withOpacity(0.15) : Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
                                  width: 0.8,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
                                  width: 0.8,
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                      
                    ],
                  ),
                ),
              ),


              
              Divider(height: 1, color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade100),
              const SizedBox(height: 16),
              
              // Action Buttons
              ElevatedButton(
                onPressed: () => controller.saveSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Simpan Pengaturan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
