import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart' show FlutterImageCompress, CompressFormat;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _hasLoaded = false;
  String _error = '';
  String _success = '';
  bool _isUploadingAvatar = false;
  String? _localAvatarPath;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  Timer? _successTimer;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadProfile();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    _emailController.dispose();
    _shakeController.dispose();
    _successTimer?.cancel();
    super.dispose();
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<void> _pickAndCropImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        maxWidth: 1024,
        maxHeight: 1024,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Foto',
            toolbarColor: const Color(0xFF4F46E5),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
            activeControlsWidgetColor: const Color(0xFF4F46E5),
          ),
          IOSUiSettings(
            title: 'Potong Foto',
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      if (croppedFile == null) return;

      if (!mounted) return;
      setState(() {
        _isUploadingAvatar = true;
        _localAvatarPath = croppedFile.path;
      });
      await _compressAndUpload(croppedFile.path);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
          _error = 'Gagal memilih atau memotong gambar: $e';
        });
        debugPrint('Pick/crop error: $e');
      }
    }
  }

  Future<void> _compressAndUpload(String filePath) async {
    final auth = context.read<AuthProvider>();
    final userId = auth.userId;
    if (userId == null) return;

    try {
      final file = File(filePath);
      final fileSize = await file.length();
      debugPrint('Avatar file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');

      Uint8List? compressedBytes;

      if (fileSize > 5 * 1024 * 1024) {
        try {
          compressedBytes = await FlutterImageCompress.compressWithFile(
            filePath,
            minWidth: 1024,
            minHeight: 1024,
            quality: 70,
            rotate: 0,
            format: CompressFormat.jpeg,
          );
          debugPrint('Compressed with flutter_image_compress');
        } catch (e) {
          debugPrint('flutter_image_compress failed, falling back to raw bytes: $e');
          compressedBytes = await file.readAsBytes();
        }
      } else {
        compressedBytes = await file.readAsBytes();
      }

      if (compressedBytes == null || compressedBytes.isEmpty) {
        if (mounted) {
          setState(() {
            _isUploadingAvatar = false;
            _error = 'Gagal memproses gambar.';
          });
        }
        return;
      }

      debugPrint('Uploading ${compressedBytes.length} bytes...');

      final ext = 'jpg';
      final fileName = 'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _supabase.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            compressedBytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      if (!mounted) return;
      setState(() {
        _avatarUrlController.text = publicUrl;
        _isUploadingAvatar = false;
        _success = 'Foto berhasil diupload.';
      });
      debugPrint('Avatar uploaded: $publicUrl');
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
          _error = 'Gagal mengupload foto: $e';
        });
      }
    }
  }

  Future<void> _loadProfile() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.userId;
    if (userId == null) return;

    // Pre-fill with auth metadata
    final metaName = auth.user?.userMetadata?['name']?.toString() ?? '';
    setState(() {
      _nameController.text = metaName;
      _emailController.text = auth.email ?? '';
    });

    // Try to load from profiles table
    try {
      final response = await _supabase
          .from('profiles')
          .select('name, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          if (response['name'] != null) {
            _nameController.text = response['name'] as String;
          }
          if (response['avatar_url'] != null) {
            _avatarUrlController.text = response['avatar_url'] as String;
          }
          _emailController.text = auth.email ?? '';
        });
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
    }
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.userId;
    if (userId == null) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Nama wajib diisi.');
      _shakeController.forward(from: 0);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
      _success = '';
    });

    try {
      final avatarUrl = _avatarUrlController.text.trim();

      // Check if profile exists first
      final existingProfile = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existingProfile != null) {
        // Update existing profile
        await _supabase.from('profiles').update({
          'name': name,
          if (avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
          'email': auth.email ?? '',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
      } else {
        // Insert new profile
        await _supabase.from('profiles').insert({
          'id': userId,
          'name': name,
          'email': auth.email ?? '',
          if (avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        await auth.updateUserName(name);
        if (!mounted) return;
        setState(() {
          _success = 'Profil berhasil disimpan.';
        });
        _successTimer?.cancel();
        _successTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal menyimpan profil: $e';
          _shakeController.forward(from: 0);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _avatarUrlController,
              builder: (context, value, child) {
                return _ProfileAvatarCard(
                  name: _nameController.text,
                  avatarUrl: _localAvatarPath != null
                      ? _localAvatarPath!
                      : value.text.trim(),
                  isLocal: _localAvatarPath != null,
                  isUploading: _isUploadingAvatar,
                  onTap: _pickAndCropImage,
                );
              },
            ),
            const SizedBox(height: 20),
            _FormCard(
              children: [
                // Name field (editable)
                _LabeledInput(
                  label: 'Nama',
                  controller: _nameController,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                // Email field (read-only)
                _LabeledInput(
                  label: 'Email',
                  controller: _emailController,
                  enabled: false,
                  icon: Icons.mail_outline_rounded,
                ),
                const SizedBox(height: 16),
                // Avatar URL (optional)
                _LabeledInput(
                  label: 'Avatar URL (opsional)',
                  controller: _avatarUrlController,
                  icon: Icons.image_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              ),
              child: _MessageBanner(error: _error, success: _success),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatarCard extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final bool isLocal;
  final bool isUploading;
  final VoidCallback onTap;

  const _ProfileAvatarCard({
    required this.name,
    this.avatarUrl = '',
    this.isLocal = false,
    this.isUploading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join()
        : '?';

    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: isUploading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : _buildAvatarContent(initials),
                ),
                if (!isUploading)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profil Anda',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name.isEmpty ? 'Masukkan nama Anda' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUploading ? 'Mengupload...' : 'Ketuk untuk ganti foto',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContent(String initials) {
    if (avatarUrl.isEmpty) {
      return Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    if (isLocal) {
      return ClipOval(
        child: Image.file(
          File(avatarUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: avatarUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Center(
          child: Text(
            initials.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final IconData? icon;

  const _LabeledInput({
    required this.label,
    required this.controller,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            color: enabled
                ? Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white
                : Theme.of(context).textTheme.bodySmall?.color,
          ),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 18) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: enabled
                ? (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E293B)
                    : Colors.white)
                : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String error;
  final String success;

  const _MessageBanner({required this.error, required this.success});

  @override
  Widget build(BuildContext context) {
    final message = error.isNotEmpty ? error : success;
    if (message.isEmpty) return const SizedBox.shrink();

    final isError = error.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFFF0F0)
            : const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isError
              ? const Color(0xFFFFD6D6)
              : const Color(0xFFD6FFDF),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: isError
                ? const Color(0xFFEF4444)
                : const Color(0xFF22C55E),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
