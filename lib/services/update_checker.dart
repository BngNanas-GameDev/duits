import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class GitHubRelease {
  final String tagName;
  final String name;
  final String body;
  final String htmlUrl;
  final String apkUrl;
  final DateTime publishedAt;

  GitHubRelease({
    required this.tagName,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.apkUrl,
    required this.publishedAt,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    String apkUrl = '';
    if (json['assets'] != null) {
      for (final asset in json['assets']) {
        if (asset['name'] != null && asset['name'].toString().endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] ?? '';
          break;
        }
      }
    }

    return GitHubRelease(
      tagName: json['tag_name']?.toString() ?? '',
      name: json['name']?.toString() ?? json['tag_name']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      htmlUrl: json['html_url']?.toString() ?? '',
      apkUrl: apkUrl,
      publishedAt: DateTime.parse(json['published_at']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }
}

class UpdateInfo {
  final bool hasUpdate;
  final bool isForceUpdate;
  final GitHubRelease? latestRelease;
  final String currentVersion;
  final String latestVersion;

  UpdateInfo({
    required this.hasUpdate,
    required this.isForceUpdate,
    this.latestRelease,
    required this.currentVersion,
    required this.latestVersion,
  });
}

class UpdateChecker {
  static const String _githubOwner = 'BngNanas-GameDev';
  static const String _githubRepo = 'duits';
  static const String _releasesApiUrl = 'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases';

  static Future<PackageInfo> getCurrentVersion() async {
    return await PackageInfo.fromPlatform();
  }

  static int _parseVersion(String version) {
    final cleaned = version.replaceFirst('v', '').replaceFirst('V', '');
    final parts = cleaned.split('.');
    int major = 0, minor = 0, patch = 0;

    if (parts.isNotEmpty) major = int.tryParse(parts[0]) ?? 0;
    if (parts.length > 1) minor = int.tryParse(parts[1]) ?? 0;
    if (parts.length > 2) {
      final patchPart = parts[2].split('-')[0];
      patch = int.tryParse(patchPart) ?? 0;
    }

    return major * 10000 + minor * 100 + patch;
  }

  static bool _isForceUpdate(String currentVersion, String latestVersion, String releaseBody) {
    final current = _parseVersion(currentVersion);
    final latest = _parseVersion(latestVersion);
    final versionDiff = latest - current;

    if (versionDiff >= 10000) return true;

    final forceIndicators = [
      '[force]',
      '[mandatory]',
      '[required]',
      'force update',
      'wajib update',
      'harus update',
    ];

    final lowerBody = releaseBody.toLowerCase();
    return forceIndicators.any((indicator) => lowerBody.contains(indicator));
  }

  static Future<UpdateInfo> checkForUpdate() async {
    try {
      final packageInfo = await getCurrentVersion();
      final currentVersion = packageInfo.version;
      debugPrint('Current app version: $currentVersion');

      final response = await http.get(
        Uri.parse(_releasesApiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      debugPrint('GitHub API response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('Failed to fetch releases: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return UpdateInfo(
          hasUpdate: false,
          isForceUpdate: false,
          currentVersion: currentVersion,
          latestVersion: currentVersion,
        );
      }

      final releases = (jsonDecode(response.body) as List)
          .map((json) => GitHubRelease.fromJson(json))
          .toList();

      debugPrint('Found ${releases.length} releases');

      if (releases.isEmpty) {
        return UpdateInfo(
          hasUpdate: false,
          isForceUpdate: false,
          currentVersion: currentVersion,
          latestVersion: currentVersion,
        );
      }

      final latestRelease = releases.first;
      final latestVersion = latestRelease.tagName.replaceFirst('v', '').replaceFirst('V', '');
      debugPrint('Latest release: $latestVersion (tag: ${latestRelease.tagName})');
      debugPrint('APK URL: ${latestRelease.apkUrl}');
      debugPrint('HTML URL: ${latestRelease.htmlUrl}');

      final hasUpdate = _parseVersion(latestVersion) > _parseVersion(currentVersion);
      final isForceUpdate = hasUpdate ? _isForceUpdate(currentVersion, latestVersion, latestRelease.body) : false;

      debugPrint('Has update: $hasUpdate, Force update: $isForceUpdate');

      return UpdateInfo(
        hasUpdate: hasUpdate,
        isForceUpdate: isForceUpdate,
        latestRelease: hasUpdate ? latestRelease : null,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
      );
    } catch (e) {
      debugPrint('Update check error: $e');
      final packageInfo = await getCurrentVersion();
      return UpdateInfo(
        hasUpdate: false,
        isForceUpdate: false,
        currentVersion: packageInfo.version,
        latestVersion: packageInfo.version,
      );
    }
  }
}
