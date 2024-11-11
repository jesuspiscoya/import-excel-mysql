import 'dart:io';

import 'package:excel/excel.dart';
import 'package:excel_import_db/controller/import_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:intl/intl.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();
  List<String> columns = [];
  List<List<String>> values = [];
  bool isLoading = false;

  void pickFile() async {
    setState(() => isLoading = true);

    // Abre el selector de archivos
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Selecciona tu archivo Excel',
      type: FileType.custom,
      allowedExtensions: ["xls", "xlsx"],
    );

    if (result != null) {
      // Obtiene el archivo seleccionado
      File file = File(result.files.single.path!);

      // Lee el contenido del archivo
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      // Obtiene la primera Hoja del Excel
      final table = excel.tables[excel.tables.keys.first];
      final rows = table?.rows;

      if (rows != null && rows.isNotEmpty) {
        columns = rows[0].map((cell) => cell!.value.toString()).toList();

        rows.removeWhere((element) {
          element.removeWhere((cell) => cell?.value == null);
          return element.isEmpty;
        });

        for (int i = 1; i < rows.length; i++) {
          List<String> data = rows[i].map((cell) {
            if (cell!.value is DateCellValue) {
              DateTime date = DateTime.parse(cell.value.toString());
              return DateFormat('yyyy-MM-dd').format(date);
            }
            return cell.value.toString();
          }).toList();
          values.add(data);
        }
      }

      setState(() => isLoading = false);
    } else {
      setState(() => isLoading = false);
    }
  }

  void importData(BuildContext context) async {
    final importController = await ImportController.conect();

    if (context.mounted) {
      setState(() => isLoading = true);
      await importController?.importData(context, columns, values);
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!isLoading) ...[
          ScaffoldPage(
            header: PageHeader(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Importar datos de Excel",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  columns.isNotEmpty && !isLoading
                      ? FilledButton(
                          child: const Text("Importar"),
                          onPressed: () => importData(context))
                      : const SizedBox(),
                ],
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: columns.isEmpty
                  ? Center(
                      child: FilledButton(
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          child: Text(
                            "Seleccionar archivo",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, height: 1.1),
                          ),
                        ),
                        onPressed: () => pickFile(),
                      ),
                    )
                  : material.Scrollbar(
                      controller: horizontalScrollController,
                      thumbVisibility: true,
                      child: material.SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: horizontalScrollController,
                        child: material.Scrollbar(
                          controller: verticalScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            controller: verticalScrollController,
                            child: material.DataTable(
                              columns: columns
                                  .map((col) =>
                                      material.DataColumn(label: Text(col)))
                                  .toList(),
                              rows: values
                                  .map((row) => material.DataRow(
                                      cells: row
                                          .map((cell) => material.DataCell(
                                              Text(cell.toString())))
                                          .toList()))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          )
        ] else ...[
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(child: ProgressRing()),
          )
        ],
      ],
    );
  }
}
