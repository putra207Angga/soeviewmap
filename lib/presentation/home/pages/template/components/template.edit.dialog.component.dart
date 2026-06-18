part of 'main.components.dart';

class TemplateEditDialog extends StatefulWidget {
  final int rating;
  final String initialText;
  final TemplateController controller;

  const TemplateEditDialog({
    super.key,
    required this.rating,
    required this.initialText,
    required this.controller,
  });

  @override
  State<TemplateEditDialog> createState() => _TemplateEditDialogState();
}

class _TemplateEditDialogState extends State<TemplateEditDialog> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _insertPlaceholder(String placeholder) {
    final text = _textController.text;
    final selection = _textController.selection;

    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, placeholder);
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: selection.start + placeholder.length,
      );
    } else {
      _textController.text = text + placeholder;
    }
    setState(() {});
  }

  String _getFormattedPreview() {
    final rawText = _textController.text;
    if (rawText.isEmpty) return 'Tulis sesuatu untuk melihat pratinjau...';
    
    return rawText
        .replaceAll('{reviewerName}', 'Agus Santoso')
        .replaceAll('{locationName}', 'Poliklinik Spesialis')
        .replaceAll('{rating}', widget.rating.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 550,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E222B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      RatingStars(rating: widget.rating.toDouble(), size: 14),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Template Bintang ${widget.rating}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
              ),
              const SizedBox(height: 14),

              // Placeholder buttons label
              Text(
                'SISIPKAN VARIABEL OTOMATIS (BOT)',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              // Variable inserter chips row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildVariableChip(
                    label: '{reviewerName}',
                    description: 'Nama Reviewer',
                    onTap: () => _insertPlaceholder('{reviewerName}'),
                    theme: theme,
                    isDark: isDark,
                  ),
                  _buildVariableChip(
                    label: '{locationName}',
                    description: 'Lokasi RS',
                    onTap: () => _insertPlaceholder('{locationName}'),
                    theme: theme,
                    isDark: isDark,
                  ),
                  _buildVariableChip(
                    label: '{rating}',
                    description: 'Bintang',
                    onTap: () => _insertPlaceholder('{rating}'),
                    theme: theme,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Text editor label & field
              Text(
                'TEMPLATE PESAN',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                maxLength: 400,
                style: const TextStyle(fontSize: 12, height: 1.4),
                decoration: InputDecoration(
                  hintText: 'Tulis template balasan bot di sini...',
                  hintStyle: const TextStyle(fontSize: 12),
                  filled: true,
                  fillColor: isDark ? Colors.black.withOpacity(0.15) : Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(12),
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.2,
                    ),
                  ),
                  counterText: '', // Hide default counter to render our custom character budget
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_textController.text.length} / 400 karakter',
                  style: TextStyle(
                    fontSize: 9,
                    color: _textController.text.length > 350
                        ? Colors.redAccent
                        : Colors.grey.shade500,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Live Preview Block
              Text(
                'PRATINJAU REAL-TIME (SIMULASI BALASAN)',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.15),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.smart_toy_rounded,
                          size: 13,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Simulasi Respon Bot',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getFormattedPreview(),
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      widget.controller.updateTemplate(widget.rating, _textController.text);
                      Get.back();
                      Get.snackbar(
                        'Template Diperbarui',
                        'Template bintang ${widget.rating} berhasil disimpan dan disinkronkan ke bot.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: isDark
                            ? const Color(0xFF1E222B)
                            : Colors.white.withOpacity(0.95),
                        colorText: isDark ? Colors.white : Colors.black,
                        borderWidth: 1,
                        borderColor: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
                        duration: const Duration(seconds: 3),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Simpan Template',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVariableChip({
    required String label,
    required String description,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($description)',
              style: TextStyle(
                fontSize: 8,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTemplateEditDialog extends StatefulWidget {
  final CustomTemplate? initialTemplate;
  final TemplateController controller;

  const CustomTemplateEditDialog({
    super.key,
    this.initialTemplate,
    required this.controller,
  });

  @override
  State<CustomTemplateEditDialog> createState() => _CustomTemplateEditDialogState();
}

class _CustomTemplateEditDialogState extends State<CustomTemplateEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _triggerValueController;
  late TextEditingController _textController;
  late String _triggerType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialTemplate?.name ?? '');
    _triggerValueController = TextEditingController(text: widget.initialTemplate?.triggerValue ?? '');
    _textController = TextEditingController(text: widget.initialTemplate?.templateText ?? '');
    _triggerType = widget.initialTemplate?.triggerType ?? 'Lokasi';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _triggerValueController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _insertPlaceholder(String placeholder) {
    final text = _textController.text;
    final selection = _textController.selection;

    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, placeholder);
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: selection.start + placeholder.length,
      );
    } else {
      _textController.text = text + placeholder;
    }
    setState(() {});
  }

  String _getFormattedPreview() {
    final rawText = _textController.text;
    if (rawText.isEmpty) return 'Tulis sesuatu untuk melihat pratinjau...';
    
    final sampleTrigger = _triggerValueController.text.trim().isNotEmpty
        ? _triggerValueController.text.trim()
        : (_triggerType == 'Lokasi' ? 'Poliklinik Kebidanan' : 'antri');

    return rawText
        .replaceAll('{reviewerName}', 'Agus Santoso')
        .replaceAll('{locationName}', sampleTrigger);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 580,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E222B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.initialTemplate == null ? Icons.add_circle_outline : Icons.edit_note,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.initialTemplate == null
                              ? 'Tambah Template Kustom Baru'
                              : 'Edit Template Kustom',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(
                  height: 1,
                  color: isDark ? const Color(0xFF2E3440) : Colors.grey.shade200,
                ),
                const SizedBox(height: 14),

                Text(
                  'NAMA TEMPLATE KUSTOM',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Balasan untuk Poli Anak...',
                    hintStyle: const TextStyle(fontSize: 12),
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'TIPE PEMICU (TRIGGER TYPE)',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _triggerType = 'Lokasi'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _triggerType == 'Lokasi'
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : (isDark ? Colors.black.withOpacity(0.1) : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _triggerType == 'Lokasi'
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: _triggerType == 'Lokasi'
                                      ? theme.colorScheme.primary
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Lokasi RSUD',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _triggerType == 'Lokasi'
                                        ? theme.colorScheme.primary
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _triggerType = 'Kata Kunci'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _triggerType == 'Kata Kunci'
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : (isDark ? Colors.black.withOpacity(0.1) : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _triggerType == 'Kata Kunci'
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.key_rounded,
                                  size: 14,
                                  color: _triggerType == 'Kata Kunci'
                                      ? theme.colorScheme.primary
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Kata Kunci',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _triggerType == 'Kata Kunci'
                                        ? theme.colorScheme.primary
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(
                  _triggerType == 'Lokasi' ? 'NAMA DEPARTEMEN / LOKASI RSUD' : 'KATA KUNCI PEMICU',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _triggerValueController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: _triggerType == 'Lokasi'
                        ? 'Contoh: Instalasi Gawat Darurat (IGD) atau Poliklinik Gigi'
                        : 'Contoh: antri, lambat, ramah',
                    hintStyle: const TextStyle(fontSize: 12),
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'SISIPKAN VARIABEL OTOMATIS (BOT)',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildVariableChip(
                      label: '{reviewerName}',
                      description: 'Nama Reviewer',
                      onTap: () => _insertPlaceholder('{reviewerName}'),
                      theme: theme,
                      isDark: isDark,
                    ),
                    _buildVariableChip(
                      label: '{locationName}',
                      description: 'Lokasi RS',
                      onTap: () => _insertPlaceholder('{locationName}'),
                      theme: theme,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(
                  'TEMPLATE PESAN BALASAN',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                  maxLength: 400,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                  decoration: InputDecoration(
                    hintText: 'Tulis template balasan bot kustom Anda...',
                    hintStyle: const TextStyle(fontSize: 12),
                    filled: true,
                    fillColor: isDark ? Colors.black.withOpacity(0.15) : Colors.grey.shade50,
                    contentPadding: const EdgeInsets.all(12),
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.2,
                      ),
                    ),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_textController.text.length} / 400 karakter',
                    style: TextStyle(
                      fontSize: 9,
                      color: _textController.text.length > 350 ? Colors.redAccent : Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  'PRATINJAU REAL-TIME',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.smart_toy_rounded, size: 13, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Simulasi Respon Bot Kustom',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getFormattedPreview(),
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Batal',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.trim().isEmpty ||
                            _triggerValueController.text.trim().isEmpty ||
                            _textController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Gagal Menyimpan',
                            'Semua kolom input wajib diisi.',
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }

                        if (widget.initialTemplate == null) {
                          final newT = CustomTemplate(
                            id: 'ct_${DateTime.now().millisecondsSinceEpoch}',
                            name: _nameController.text.trim(),
                            triggerType: _triggerType,
                            triggerValue: _triggerValueController.text.trim(),
                            templateText: _textController.text.trim(),
                          );
                          widget.controller.addCustomTemplate(newT);
                          Get.back();
                          Get.snackbar(
                            'Template Ditambahkan',
                            'Template kustom baru berhasil dibuat.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: isDark ? const Color(0xFF1E222B) : Colors.white.withOpacity(0.95),
                            colorText: isDark ? Colors.white : Colors.black,
                          );
                        } else {
                          final updated = widget.initialTemplate!.copyWith(
                            name: _nameController.text.trim(),
                            triggerType: _triggerType,
                            triggerValue: _triggerValueController.text.trim(),
                            templateText: _textController.text.trim(),
                          );
                          widget.controller.updateCustomTemplate(updated);
                          Get.back();
                          Get.snackbar(
                            'Template Diperbarui',
                            'Perubahan template kustom berhasil disimpan.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: isDark ? const Color(0xFF1E222B) : Colors.white.withOpacity(0.95),
                            colorText: isDark ? Colors.white : Colors.black,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        widget.initialTemplate == null ? 'Buat Template' : 'Simpan Perubahan',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVariableChip({
    required String label,
    required String description,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($description)',
              style: TextStyle(
                fontSize: 8,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
