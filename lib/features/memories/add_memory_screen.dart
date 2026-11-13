import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart';
import '../../widgets/common/primary_button.dart';

class AddMemoryScreen extends ConsumerStatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  ConsumerState<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends ConsumerState<AddMemoryScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  final List<int> _photoSeeds = [];
  final List<String> _photoPaths = [];
  bool _loading = false;
  final _picker = ImagePicker();

  Future<void> _pickPhotos() async {
    final imgs = await _picker.pickMultiImage();
    if (imgs.isEmpty) return;
    setState(() {
      for (final img in imgs) {
        _photoPaths.add(img.path);
        _photoSeeds.add(DateTime.now().millisecondsSinceEpoch % 8);
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final session = ref.read(sessionProvider);
    await ref.read(memoriesProvider.notifier).addFromApi(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      date: _date,
      userId: session.currentUser?.id ?? '',
      coupleId: session.couple?.id,
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child:
              const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: Text('Add Memory', style: AppTextStyles.h3()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo area
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._photoSeeds.map((seed) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ArtworkTile(
                                seed: seed,
                                size: 80,
                                borderRadius: 12,
                                icon: Icons.photo_rounded),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _photoSeeds.remove(seed)),
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.close,
                                      size: 11, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  GestureDetector(
                    onTap: _pickPhotos,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.border,
                            style: BorderStyle.solid),
                      ),
                      child: const Icon(Icons.add_photo_alternate_rounded,
                          color: AppColors.textSecondary, size: 28),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _field('Title *', _titleCtrl, hint: 'Our first trip...'),
            const SizedBox(height: 14),
            _field('Description', _descCtrl,
                hint: 'Tell the story...', maxLines: 4),
            const SizedBox(height: 14),
            _field('Location', _locationCtrl,
                hint: 'Where was this?'),
            const SizedBox(height: 14),
            // Date picker
            Text('Date', style: AppTextStyles.caption()),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Text(
                      '${_date.day}/${_date.month}/${_date.year}',
                      style: AppTextStyles.body(),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Save Memory',
              loading: _loading,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption()),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
