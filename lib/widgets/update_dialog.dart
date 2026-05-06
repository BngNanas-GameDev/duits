import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../services/update_checker.dart';
import '../theme/palette.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  final VoidCallback? onSkip;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    this.onSkip,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0;
  bool _downloadComplete = false;

  Future<void> _downloadUpdate() async {
    if (!mounted) return;

    final release = widget.updateInfo.latestRelease;
    if (release == null) return;

    final url = release.apkUrl.isNotEmpty ? release.apkUrl : release.htmlUrl;
    debugPrint('APK download URL: $url');

    if (url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link download tidak tersedia.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      if (!mounted) return;
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0;
      });

      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        debugPrint('Could not get storage directory');
        if (mounted) setState(() => _isDownloading = false);
        return;
      }

      final savePath = '${dir.path}/duits_update.apk';
      debugPrint('Downloading APK to: $savePath');

      final dio = Dio();
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            debugPrint('Download progress: ${(progress * 100).toStringAsFixed(1)}%');
            if (mounted) {
              setState(() {
                _downloadProgress = progress;
              });
            }
          }
        },
        options: Options(
          headers: {'Accept': 'application/vnd.android.package-archive'},
        ),
      );

      debugPrint('Download completed, file size: ${File(savePath).lengthSync()} bytes');

      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _downloadComplete = true;
      });

      final result = await OpenFilex.open(savePath);
      debugPrint('Open file result: ${result.type} - ${result.message}');

      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka installer: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Download/install error: $e');
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = AppPalette.defaultTheme;

    final patchNotes = widget.updateInfo.latestRelease?.body ?? 'Tidak ada catatan rilis.';

    return PopScope(
      canPop: !widget.updateInfo.isForceUpdate,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: palette.cardColor(isDark),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: palette.headerGradient(isDark),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.updateInfo.isForceUpdate
                            ? Icons.system_update
                            : Icons.new_releases,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.updateInfo.isForceUpdate
                          ? 'Update Wajib'
                          : 'Pembaruan Tersedia',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'v${widget.updateInfo.currentVersion}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'v${widget.updateInfo.latestVersion}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_list_bulleted,
                            size: 20,
                            color: palette.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Patch Notes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: palette.text(isDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: palette.scaffoldBackground(isDark),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: palette.dividerColor(isDark),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: _buildPatchNotes(patchNotes, palette, isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    if (_isDownloading) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: _downloadProgress,
                              backgroundColor: palette.primary.withValues(alpha: 0.15),
                              color: palette.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Downloading... ${(_downloadProgress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: palette.secondaryText(isDark),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _downloadUpdate,
                          icon: _downloadComplete
                              ? const Icon(Icons.check_circle_rounded)
                              : const Icon(Icons.download_rounded),
                          label: Text(
                            _downloadComplete ? 'Install Update' : 'Download & Install',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                      if (!widget.updateInfo.isForceUpdate) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Jika gagal install, hapus aplikasi lama terlebih dahulu lalu install APK ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.secondaryText(isDark),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          widget.onSkip?.call();
                        },
                        child: Text(
                          'Nanti Saja',
                          style: TextStyle(
                            color: palette.secondaryText(isDark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (widget.updateInfo.isForceUpdate)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Update ini wajib untuk melanjutkan penggunaan aplikasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.accentColor(isDark),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatchNotes(String notes, AppPalette palette, bool isDark) {
    final lines = notes.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.startsWith('# ')) {
        widgets.add(Text(
          line.replaceFirst('# ', ''),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: palette.text(isDark),
          ),
        ));
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('## ')) {
        widgets.add(Text(
          line.replaceFirst('## ', ''),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: palette.primary,
          ),
        ));
        widgets.add(const SizedBox(height: 4));
      } else if (line.startsWith('### ')) {
        widgets.add(Text(
          line.replaceFirst('### ', ''),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: palette.text(isDark),
          ),
        ));
        widgets.add(const SizedBox(height: 4));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        final content = line.substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•', style: TextStyle(color: palette.primary, fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: _formatInlineText(content, palette, isDark),
              ),
            ],
          ),
        ));
      } else {
        widgets.add(_formatInlineText(line, palette, isDark));
        widgets.add(const SizedBox(height: 4));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _formatInlineText(String text, AppPalette palette, bool isDark) {
    final parts = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*|`(.+?)`');
    var lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        parts.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(
            fontSize: 13,
            color: palette.secondaryText(isDark),
            height: 1.5,
          ),
        ));
      }

      final boldText = match.group(1);
      final codeText = match.group(2);

      if (boldText != null) {
        parts.add(TextSpan(
          text: boldText,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: palette.text(isDark),
            height: 1.5,
          ),
        ));
      } else if (codeText != null) {
        parts.add(TextSpan(
          text: codeText,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            backgroundColor: palette.primary.withValues(alpha: 0.1),
            color: palette.primary,
            height: 1.5,
          ),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(
          fontSize: 13,
          color: palette.secondaryText(isDark),
          height: 1.5,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: parts),
    );
  }
}
