import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Simple provider for theme mode management
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const _SectionHeader(title: '일반'),
          ListTile(
            title: const Text('테마 설정'),
            subtitle: Text(_getThemeModeText(themeMode)),
            leading: const Icon(Icons.brightness_6),
            onTap: () => _showThemeDialog(context),
          ),
          const Divider(),
          const _SectionHeader(title: '정보'),
          ListTile(
            title: const Text('앱 버전'),
            subtitle: _packageInfo == null
                ? null
                : Text(
                    'v${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                  ),
            leading: const Icon(Icons.info_outline),
          ),
          ListTile(
            title: const Text('오픈소스 라이선스'),
            leading: const Icon(Icons.article_outlined),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: _packageInfo?.appName ?? 'Zzik-SSu',
                applicationVersion: _packageInfo?.version,
              );
            },
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '시스템 설정 따름';
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('테마 선택'),
          content: RadioGroup<ThemeMode>(
            groupValue: ref.read(themeModeProvider),
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).state = value;
                Navigator.pop(context);
              }
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  title: Text('시스템 설정 따름'),
                  value: ThemeMode.system,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('라이트 모드'),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text('다크 모드'),
                  value: ThemeMode.dark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
