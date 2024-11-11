import 'dart:async';
import 'dart:convert';

import 'package:excel_import_db/controller/conection_controller.dart';
import 'package:excel_import_db/model/conection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImportController {
  final MySqlConnection? _conn;

  ImportController._(this._conn);

  static Future<ImportController?> conect() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? connShared = prefs.getString('conection');
    late MySqlConnection conn;

    if (connShared != null) {
      final Conection conection = Conection.fromMap(jsonDecode(connShared));
      conn = await ConectionController().getConnection(conection);
      return ImportController._(conn);
    } else {
      return ImportController._(null);
    }
  }

  Future<void> importData(
    BuildContext context,
    List<String> columns,
    List<List<String>> rows,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? connShared = prefs.getString('conection');

      if (connShared == null) throw Exception('Debe configurar la conexión.');

      final Conection conection = Conection.fromMap(jsonDecode(connShared));

      for (var i = 0; i < rows.length; i++) {
        final String val =
            List.generate(columns.length, (index) => '?').join(', ');
        final String query =
            'INSERT INTO ${conection.db}.${conection.table} (${columns.join(', ')}) VALUES ($val);';
        await _conn!.query(query, rows[i]);
      }

      if (context.mounted) {
        showDialog<String>(
          context: context,
          builder: (context) => ContentDialog(
            content: const Text("Los datos se han importado correctamente."),
            actions: [
              FilledButton(
                child: const Text('Aceptar'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }

      prefs.clear();
      columns.clear();
    } catch (e) {
      if (context.mounted) {
        showDialog<String>(
          context: context,
          builder: (context) => ContentDialog(
            content: Text(e.toString()),
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
}
