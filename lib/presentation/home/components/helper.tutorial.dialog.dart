part of 'main.components.dart';

class HelperTutorialDialog extends StatefulWidget {
  const HelperTutorialDialog({super.key});

  @override
  State<HelperTutorialDialog> createState() => _HelperTutorialDialogState();
}

class _HelperTutorialDialogState extends State<HelperTutorialDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _walkthroughStep = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _walkthroughSteps = [
    {
      'title': '1. Dashboard & Peta Interaktif',
      'subtitle': 'Visualisasi statistik ulasan & lokasi RSUD dr. Soebandi',
      'icon': Icons.space_dashboard_rounded,
      'color': const Color(0xFF6366F1),
      'description':
          'Halaman Dashboard memberikan rangkuman total ulasan, rating rata-rata (4.5★), persentase Positive Vibes, serta peta interaktif unit pelayanan RSUD dr. Soebandi.',
      'tips': [
        'Klik pin departemen pada peta untuk memfilter ulasan area.',
        'Gunakan kartu statistik untuk melihat ulasan yang membutuhkan perhatian.',
      ],
    },
    {
      'title': '2. Daftar Ulasan & Filter Sentimen',
      'subtitle': 'Penyaringan ulasan publik Google Maps',
      'icon': Icons.star_rounded,
      'color': const Color(0xFFF59E0B),
      'description':
          'Daftar Ulasan menampilkan semua masukan publik. Anda dapat memfilter berdasarkan rating bintang (1-5★), sentimen (Positif, Netral, Negatif), dan status balasan.',
      'tips': [
        'Filter ulasan negatif untuk penanganan prioritas keluhan pasien.',
        'Lihat riwayat sentimen yang telah dikategorikan secara otomatis oleh AI.',
      ],
    },
    {
      'title': '3. Log Balasan AI & Filter Periode Bulan',
      'subtitle': 'Moderasi balasan otomatis berbasis tanggal',
      'icon': Icons.chat_bubble_rounded,
      'color': const Color(0xFF10B981),
      'description':
          'Log Balasan AI mencatat seluruh rekomendasi balasan. Filter bulan (misal: September 2026) otomatis mengambil rentang tanggal date_from (2026-09-01) hingga date_to (2026-09-30).',
      'tips': [
        'Ubah dropdown bulan di sudut kanan atas tabel untuk ganti periode.',
        'Klik tombol "Kirim Balasan" untuk mempublikasikan balasan AI ke Google Maps.',
      ],
    },
    {
      'title': '4. Manajemen Template Balasan',
      'subtitle': 'Standarisasi respons balasan instansi',
      'icon': Icons.edit_document,
      'color': const Color(0xFF8B5CF6),
      'description':
          'Buat dan kelola template balasan resmi untuk mempercepat moderasi. Gunakan variabel dinamis seperti {reviewer_name} untuk balasan personal.',
      'tips': [
        'Gunakan template resmi untuk keluhan pelayanan ruang rawat inap.',
        'Tambahkan template baru dengan menekan "+ Template Baru".',
      ],
    },
    {
      'title': '5. Bilah Pencarian Pintar & Command /',
      'subtitle': 'Pencarian instan dengan sintaks khusus',
      'icon': Icons.saved_search_rounded,
      'color': const Color(0xFFEC4899),
      'description':
          'Bilah pencarian di header mendukung sintaks pintar! Ketik / diikuti tanggal (misal: / 2026-09), rating (/ 5 bintang), atau status (/ pending) untuk filter instan.',
      'tips': [
        'Ketik / 2026-09 untuk langsung membuka Log Balasan bulan September.',
        'Ketik / pengaturan untuk membuka panel pengaturan secara instan.',
      ],
    },
  ];

  final List<Map<String, dynamic>> _featuresCatalog = [
    {
      'menu': NavMenu.dashboard,
      'title': 'Dashboard Utama',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFF6366F1),
      'badge': 'Statistik Real-time',
      'description':
          'Menampilkan kartu metrik total ulasan, rating rata-rata, grafik sentimen, dan peta Google Maps interaktif lokasi RSUD dr. Soebandi.',
    },
    {
      'menu': NavMenu.templet,
      'title': 'Template Balasan',
      'icon': Icons.edit_document,
      'color': Color(0xFF8B5CF6),
      'badge': 'Kustom AI',
      'description':
          'Kumpulan template pesan balasan resmi untuk mempercepat moderasi tanggapan atas ulasan positif maupun kritik pembangun.',
    },
    {
      'menu': NavMenu.review,
      'title': 'Daftar Ulasan Publik',
      'icon': Icons.star_rounded,
      'color': Color(0xFFF59E0B),
      'badge': 'Moderasi Ulasan',
      'description':
          'Monitoring ulasan masuk dari Google Maps dengan filter bintang (1-5★), status (Pending/Terkirim), dan klasifikasi sentimen otomatis.',
    },
    {
      'menu': NavMenu.balas,
      'title': 'Log Balasan AI',
      'icon': Icons.chat_bubble_rounded,
      'color': Color(0xFF10B981),
      'badge': 'Terintegrasi Backend',
      'description':
          'Riwayat dan draf balasan AI Assistant. Dilengkapi filter periode bulan yang terhubung langsung dengan query parameter date_from & date_to.',
    },
    {
      'menu': NavMenu.logBot,
      'title': 'Aktivitas Bot',
      'icon': Icons.android_rounded,
      'color': Color(0xFF06B6D4),
      'badge': 'Otomatisasi Latar Belakang',
      'description':
          'Catatan eksekusi bot pemantau ulasan baru yang berjalan secara otomatis untuk menyinkronkan data Google Maps.',
    },
  ];

  final List<Map<String, String>> _slashCommands = [
    {
      'command': '/ 2026-09',
      'desc': 'Filter langsung ke periode bulan September 2026',
    },
    {
      'command': '/ september 2026',
      'desc': 'Buka Log Balasan dengan filter bulan September',
    },
    {
      'command': '/ 5 bintang',
      'desc': 'Filter ulasan publik yang memiliki rating 5 Bintang',
    },
    {
      'command': '/ pending',
      'desc': 'Filter balasan ulasan yang masih berstatus Pending',
    },
    {
      'command': '/ positif',
      'desc': 'Filter ulasan publik bersentimen Positif',
    },
    {
      'command': '/ pengaturan',
      'desc': 'Langsung membuka panel Pengaturan Aplikasi',
    },
    {
      'command': '/ template baru',
      'desc': 'Membuka form pembuatan Template Balasan baru',
    },
  ];

  final List<Map<String, String>> _faqs = [
    {
      'q': 'Bagaimana cara memfilter data ulasan untuk bulan tertentu?',
      'a':
          'Buka menu "Log Balasan AI", lalu pilih dropdown Bulan di kanan atas tabel. Atau gunakan bilah pencarian di header dan ketik perintah seperti "/ 2026-09" atau "/ september 2026".',
    },
    {
      'q': 'Bagaimana cara mengatur jumlah notifikasi yang ditarik?',
      'a':
          'Klik ikon roda gigi (Pengaturan) di kanan atas, lalu sesuaikan opsi "Batas Riwayat Notifikasi" (misal: 20, 50, atau 100). Aplikasi akan mengambil data notifikasi unread sesuai batas tersebut.',
    },
    {
      'q': 'Apa fungsi dari filter kata kasar (profanity filter)?',
      'a':
          'Ketika diaktifkan di Pengaturan, kata-kata kasar pada ulasan publik akan otomatis disensor menjadi *** untuk kenyamanan tampilan staf moderasi.',
    },
    {
      'q': 'Bagaimana menandai semua notifikasi telah dibaca?',
      'a':
          'Buka lonceng notifikasi di header, lalu klik "Tandai semua telah dibaca". Sistem akan memanggil endpoint /api/notifications/read-all dan memperbarui badge notifikasi.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF13151A) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: context.width > 900 ? 840 : (context.width * 0.92),
        height: context.height > 720 ? 640 : (context.height * 0.88),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Dialog
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pusat Panduan & Tutorial Aplikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sistem Moderasi Ulasan & Balasan AI RSUD dr. Soebandi',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.grey.shade400,
                  ),
                  tooltip: 'Tutup',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar Filter Inside Helper
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E222B)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E3440)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Cari topik panduan (misal: "filter bulan", "slash command", "balas ulasan")...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.grey.shade500
                        : Colors.grey.shade400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: isDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade500,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Navigation Tabs
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: primaryColor,
              unselectedLabelColor:
                  isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              indicatorColor: primaryColor,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.touch_app_rounded, size: 16),
                  text: 'Tutorial Interaktif',
                ),
                Tab(
                  icon: Icon(Icons.grid_view_rounded, size: 16),
                  text: 'Katalog Fitur',
                ),
                Tab(
                  icon: Icon(Icons.terminal_rounded, size: 16),
                  text: 'Command & Search',
                ),
                Tab(
                  icon: Icon(Icons.quiz_rounded, size: 16),
                  text: 'Tanya Jawab (FAQ)',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Views Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWalkthroughTab(isDark, primaryColor),
                  _buildFeaturesCatalogTab(isDark, primaryColor),
                  _buildSlashCommandsTab(isDark, primaryColor),
                  _buildFaqTab(isDark, primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 1: Walkthrough Tutorial
  Widget _buildWalkthroughTab(bool isDark, Color primaryColor) {
    final step = _walkthroughSteps[_walkthroughStep];
    final Color stepColor = step['color'] as Color;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step Progress Bar
          Row(
            children: List.generate(_walkthroughSteps.length, (index) {
              final active = index == _walkthroughStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? stepColor
                        : (index < _walkthroughStep
                            ? stepColor.withOpacity(0.4)
                            : (isDark
                                ? const Color(0xFF2E3440)
                                : Colors.grey.shade200)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Main Step Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E222B) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: stepColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: stepColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: stepColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  step['description'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? Colors.grey.shade300 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF13151A)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: stepColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_rounded,
                            color: stepColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tips Penggunaan:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: stepColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...(step['tips'] as List<String>).map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: stepColor,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey.shade300
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Walkthrough Controller Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: _walkthroughStep > 0
                    ? () {
                        setState(() {
                          _walkthroughStep--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Sebelumnya'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                'Langkah ${_walkthroughStep + 1} dari ${_walkthroughSteps.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _walkthroughStep < _walkthroughSteps.length - 1
                    ? () {
                        setState(() {
                          _walkthroughStep++;
                        });
                      }
                    : () {
                        Navigator.of(context).pop();
                      },
                icon: Icon(
                  _walkthroughStep < _walkthroughSteps.length - 1
                      ? Icons.arrow_forward_rounded
                      : Icons.check_circle_rounded,
                  size: 16,
                ),
                label: Text(
                  _walkthroughStep < _walkthroughSteps.length - 1
                      ? 'Langkah Selanjutnya'
                      : 'Selesai Tutorial',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TAB 2: Features Catalog Tab
  Widget _buildFeaturesCatalogTab(bool isDark, Color primaryColor) {
    final filtered = _featuresCatalog.where((item) {
      if (_searchQuery.isEmpty) return true;
      final title = (item['title'] as String).toLowerCase();
      final desc = (item['description'] as String).toLowerCase();
      final badge = (item['badge'] as String).toLowerCase();
      return title.contains(_searchQuery) ||
          desc.contains(_searchQuery) ||
          badge.contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada fitur yang cocok dengan "$_searchQuery"',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = filtered[index];
        final NavMenu menu = item['menu'] as NavMenu;
        final Color itemColor = item['color'] as Color;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E222B) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: itemColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: itemColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: itemColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['badge'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: itemColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['description'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Get.find<HomeController>().toNavigation(menu.index);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: itemColor.withOpacity(0.1),
                  foregroundColor: itemColor,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Buka', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB 3: Slash Commands Tab
  Widget _buildSlashCommandsTab(bool isDark, Color primaryColor) {
    final filtered = _slashCommands.where((item) {
      if (_searchQuery.isEmpty) return true;
      final cmd = item['command']!.toLowerCase();
      final desc = item['desc']!.toLowerCase();
      return cmd.contains(_searchQuery) || desc.contains(_searchQuery);
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.terminal_rounded, color: primaryColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Gunakan perintah pintar berikut langsung di kolom pencarian header di paling atas!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...filtered.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E222B) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E3440)
                      : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF13151A)
                          : const Color(0xFFE0E7FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      item['command']!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item['desc']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // TAB 4: FAQ Tab
  Widget _buildFaqTab(bool isDark, Color primaryColor) {
    final filtered = _faqs.where((item) {
      if (_searchQuery.isEmpty) return true;
      final q = item['q']!.toLowerCase();
      final a = item['a']!.toLowerCase();
      return q.contains(_searchQuery) || a.contains(_searchQuery);
    }).toList();

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E222B) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
            ),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding:
                const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Icon(
              Icons.help_outline_rounded,
              color: primaryColor,
              size: 20,
            ),
            title: Text(
              item['q']!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            children: [
              Text(
                item['a']!,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: isDark
                      ? Colors.grey.shade300
                      : Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
