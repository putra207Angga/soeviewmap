part of 'main.components.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

              // Settings Sections
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MODERASI AI & BOT',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsSwitch(
                        title: 'Mode AI Konservatif',
                        subtitle: 'Batasi balasan otomatis hanya pada review bintang 4 & 5.',
                        value: true,
                        onChanged: (val) {
                          Get.snackbar(
                            'AI Mode',
                            val ? 'AI hanya membalas rating positif.' : 'AI membalas seluruh rating.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        isDark: isDark,
                        theme: theme,
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsSwitch(
                        title: 'Filter Kata Kasar',
                        subtitle: 'Secara otomatis sembunyikan ulasan yang mengandung kata kasar.',
                        value: true,
                        onChanged: (val) {},
                        isDark: isDark,
                        theme: theme,
                      ),
                      
                      const SizedBox(height: 28),
                      
                      Text(
                        'KEAMANAN & NOTIFIKASI',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsSwitch(
                        title: 'Audit Logs Keamanan',
                        subtitle: 'Simpan riwayat aktivitas admin di database lokal.',
                        value: true,
                        onChanged: (val) {},
                        isDark: isDark,
                        theme: theme,
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsSwitch(
                        title: 'Push WhatsApp Admin',
                        subtitle: 'Kirim notifikasi ke WhatsApp admin jika ada rating 1 masuk.',
                        value: false,
                        onChanged: (val) {
                          Get.snackbar(
                            'Notifikasi WhatsApp',
                            val ? 'WhatsApp Alert aktif.' : 'WhatsApp Alert mati.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        isDark: isDark,
                        theme: theme,
                      ),
                      
                      const SizedBox(height: 28),

                      Text(
                        'CUSTOMER SERVICE HOTLINE',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: '0811-XXXX-XXXX',
                          prefixIcon: const Icon(Icons.phone_rounded, size: 16),
                          filled: true,
                          fillColor: isDark ? Colors.black.withOpacity(0.15) : Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      ),
                    ],
                  ),
                ),
              ),
              
              Divider(height: 1, color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade100),
              const SizedBox(height: 16),
              
              // Action Buttons
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    'Berhasil Disimpan',
                    'Seluruh konfigurasi settings berhasil disimpan.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
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
    return StatefulBuilder(
      builder: (context, setState) {
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
              onChanged: (val) {
                setState(() => value = val);
                onChanged(val);
              },
              activeColor: theme.colorScheme.primary,
            ),
          ],
        );
      },
    );
  }
}
