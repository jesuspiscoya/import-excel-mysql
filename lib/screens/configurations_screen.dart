import 'dart:convert';

import 'package:excel_import_db/controller/conection_controller.dart';
import 'package:excel_import_db/model/conection.dart';
import 'package:excel_import_db/widgets/input_form.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationsScreen extends StatefulWidget {
  const ConfigurationsScreen({super.key});

  @override
  State<ConfigurationsScreen> createState() => _ConfigurationsScreenState();
}

class _ConfigurationsScreenState extends State<ConfigurationsScreen> {
  final formConectionKey = GlobalKey<FormState>();
  final TextEditingController hostController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController databaseController = TextEditingController();
  final ConectionController conectionController = ConectionController();
  final SharedPreferencesAsync prefs = SharedPreferencesAsync();
  bool isLoaded = false;

  void testConnection(BuildContext context) async {
    setState(() => isLoaded = true);

    if (formConectionKey.currentState!.validate()) {
      final conection = Conection(
        host: hostController.text,
        port: int.parse(portController.text),
        user: usernameController.text,
        password: passwordController.text,
        db: databaseController.text,
      );
      final String result = await conectionController.tryConected(conection);
      setState(() => isLoaded = false);

      showDialog<String>(
        context: context,
        builder: (context) => ContentDialog(
          content: Text(result),
          actions: [
            FilledButton(
              child: const Text('Aceptar'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void saveConnection(BuildContext context) async {
    setState(() => isLoaded = true);

    if (formConectionKey.currentState!.validate()) {
      final conection = Conection(
        host: hostController.text,
        port: int.parse(portController.text),
        user: usernameController.text,
        password: passwordController.text,
        db: databaseController.text,
      );
      final bool result = await conectionController.saveConnection(conection);
      setState(() => isLoaded = false);

      if (result) {
        showDialog<String>(
          context: context,
          builder: (context) => ContentDialog(
            content: const Text('Conexión guardada con éxito.'),
            actions: [
              FilledButton(
                child: const Text('Aceptar'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        showDialog<String>(
          context: context,
          builder: (context) => ContentDialog(
            content: const Text('Error al guardar la conexión.'),
            actions: [
              FilledButton(
                child: const Text('Aceptar'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> loadConnection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? conection = prefs.getString('conection');
    if (conection != null) {
      final Map<String, dynamic> conectionMap = jsonDecode(conection);
      hostController.text = conectionMap['host'];
      portController.text = conectionMap['port'].toString();
      usernameController.text = conectionMap['user'];
      passwordController.text = conectionMap['password'];
      databaseController.text = conectionMap['db'];
    }
  }

  @override
  void initState() {
    super.initState();
    loadConnection();
  }

  @override
  void dispose() {
    super.dispose();
    hostController.dispose();
    portController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    databaseController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text(
          'Configuración de conexión',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 20),
        child: Form(
          key: formConectionKey,
          child: Column(
            children: [
              Row(
                children: [
                  InputForm(
                    title: 'Hostname',
                    placeholder: '127.0.0.0',
                    controller: hostController,
                  ),
                  const SizedBox(width: 20),
                  InputForm(
                    title: 'Puerto',
                    placeholder: '3306',
                    controller: portController,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  InputForm(
                    title: 'Username',
                    placeholder: 'root',
                    controller: usernameController,
                  ),
                  const SizedBox(width: 20),
                  InputForm(
                    title: 'Password',
                    placeholder: 'password',
                    controller: passwordController,
                    isPassword: true,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  InputForm(
                    title: 'Database',
                    placeholder: 'database',
                    controller: databaseController,
                  ),
                ],
              ),
              isLoaded
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 30),
                        ProgressBar(),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button(
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      child: Text(
                        'Probar conexión',
                        style:
                            TextStyle(fontWeight: FontWeight.w600, height: 1.1),
                      ),
                    ),
                    onPressed: () => testConnection(context),
                  ),
                  const SizedBox(width: 20),
                  FilledButton(
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      child: Text(
                        "Guardar",
                        style:
                            TextStyle(fontWeight: FontWeight.w600, height: 1.1),
                      ),
                    ),
                    onPressed: () => saveConnection(context),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
