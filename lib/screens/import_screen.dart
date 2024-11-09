import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();
  List<material.DataRow> tableRows = [];
  List<String> columnNames = [];
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
        columnNames = rows[0].map((cell) => cell!.value.toString()).toList();

        for (int i = 1; i < rows.length; i++) {
          List<material.DataCell> listCells = rows[i]
              .map((cell) => material.DataCell(Text(cell!.value.toString())))
              .toList();
          tableRows.add(material.DataRow(cells: listCells));
        }
      }

      setState(() => isLoading = false);
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Importar datos de Excel",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            columnNames.isNotEmpty && !isLoading
                ? FilledButton(child: const Text("Importar"), onPressed: () {})
                : const SizedBox(),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Column(
            children: [
              if (isLoading) ...[
                const Expanded(child: Center(child: ProgressRing()))
              ] else if (!isLoading && columnNames.isEmpty) ...[
                Expanded(
                  child: Center(
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
                  ),
                )
              ] else ...[
                Expanded(
                  child: material.Scrollbar(
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
                            columns: columnNames
                                .map((col) =>
                                    material.DataColumn(label: Text(col)))
                                .toList(),
                            rows: tableRows,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
