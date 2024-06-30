import 'package:flutter/material.dart';
import 'dart:math';

class TablePage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final double baseTemp;
  final String crop;

  const TablePage({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.baseTemp,
    required this.crop,
  }) : super(key: key);

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  late List<DataRow> _dataRows;
  int _currentPage = 0;
  static const int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _dataRows = _generateDataRows();
  }

  List<DataRow> _generateDataRows() {
    List<DataRow> rows = [];
    int sNo = 1;
    DateTime currentDate = widget.startDate;
    double cumulativeGDD = 0.0;
    Random random = Random();

    while (currentDate.isBefore(widget.endDate) ||
        currentDate.isAtSameMomentAs(widget.endDate)) {
      double minTemp =
          5.0 + random.nextInt(10); // Random min temp between 10 and 19
      double maxTemp = minTemp +
          random.nextInt(5); // Random max temp between minTemp and minTemp + 4
      double dailyGDD = ((minTemp + maxTemp) / 2) - widget.baseTemp;
      if (dailyGDD < 0) {
        dailyGDD = 0;
      }
      cumulativeGDD += dailyGDD;

      rows.add(DataRow(cells: [
        DataCell(Text(sNo.toString(), style: TextStyle(fontSize: 15))),
        DataCell(Text('${currentDate.day}-${currentDate.month}',
            style: TextStyle(fontSize: 15))),
        DataCell(Text(
            '${minTemp.toStringAsFixed(1)}/${maxTemp.toStringAsFixed(1)}',
            style: TextStyle(fontSize: 15))),
        DataCell(
            Text(dailyGDD.toStringAsFixed(1), style: TextStyle(fontSize: 15))),
        DataCell(Text(cumulativeGDD.toStringAsFixed(1),
            style: TextStyle(fontSize: 15))),
      ]));

      sNo++;
      currentDate = currentDate.add(Duration(days: 1));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    int totalRows = _dataRows.length;
    int totalPages = (totalRows / _rowsPerPage).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GDD Calculator Results'),
      ),
      body: Column(
        children: [
          Container(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      Text(
                          'Start Date: ${widget.startDate.day}/${widget.startDate.month}/${widget.startDate.year}'),
                      Text(
                          'End Date: ${widget.endDate.day}/${widget.endDate.month}/${widget.endDate.year}'),
                      Text('Crop Selected: ${widget.crop}'),
                      Text('Base Temperature: ${widget.baseTemp}°C')
                    ],
                  ))),
          Container(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 10.0,
                  headingRowHeight: 30.0,
                  dataRowHeight: 30.0,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'S.No',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Date',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Temp (°C)',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Daily GDD',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Cumulative GDD',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                  rows: _dataRows
                      .skip(_currentPage * _rowsPerPage)
                      .take(_rowsPerPage)
                      .toList(),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentPage > 0)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentPage--;
                    });
                  },
                  child: const Text('Previous'),
                ),
              if (_currentPage < totalPages - 1)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentPage++;
                    });
                  },
                  child: const Text('Next'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
