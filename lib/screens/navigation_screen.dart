import 'package:excel_import_db/screens/configurations_screen.dart';
import 'package:excel_import_db/screens/import_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      transitionBuilder: (child, animation) => DrillInPageTransition(
        animation: animation,
        child: child,
      ),
      appBar: NavigationAppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 17),
          child: Image.asset('assets/laive-logo.png', height: 40),
        ),
        title: const Text(
          'Importar datos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      pane: NavigationPane(
          header: const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text("Menu"),
          ),
          items: [
            PaneItem(
                icon: const Icon(FluentIcons.settings),
                title: const Text("Configuración"),
                body: const ConfigurationsScreen()),
            PaneItem(
                icon: const Icon(FluentIcons.add_notes),
                title: const Text("Importar"),
                body: const ImportScreen()),
          ],
          selected: _currentIndex,
          displayMode: PaneDisplayMode.auto,
          onChanged: (value) => setState(() => _currentIndex = value)),
    );
  }
}
