import 'package:excel_import_db/screens/navigation_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      home: const NavigationScreen(),
      theme: FluentThemeData.dark(),
    );
  }
}
