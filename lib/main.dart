import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Add this line
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zzik_ssu/app_router.dart';
import 'package:zzik_ssu/core/theme/app_theme.dart';
import 'package:zzik_ssu/features/settings/settings_screen.dart';
import 'package:zzik_ssu/features/transaction/data/model/transaction_model.dart';
import 'package:zzik_ssu/features/transaction/data/transaction_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([TransactionSchema], directory: dir.path);

  runApp(
    ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWith(
          (ref) => TransactionRepository(isar),
        ),
      ],
      child: const ZzikSsuApp(),
    ),
  );
}

class ZzikSsuApp extends ConsumerWidget {
  const ZzikSsuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Zzik-SSu',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
    );
  }
}
