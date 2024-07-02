import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

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
  List<DataRow> _dataRows = [];
  int _currentPage = 0;
  static const int _rowsPerPage = 10;
  List<Map<String, dynamic>>? _maxTemperatureData;
  List<Map<String, dynamic>>? _minTemperatureData;

  @override
  void initState() {
    super.initState();
    _loadTemperatureData().then((data) {
      setState(() {
        _maxTemperatureData = data;
        _dataRows = _generateDataRows();
      });
    });
    _loadMinTemperatureData().then((data) {
      setState(() {
        _minTemperatureData = data;
        _dataRows = _generateDataRows();
      });
    });
  }

  Future<List<Map<String, dynamic>>> _loadTemperatureData() async {
    final String jsonString =
        await rootBundle.loadString('assets/max_temperature_data.json');
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }

  Future<List<Map<String, dynamic>>> _loadMinTemperatureData() async {
    final String jsonString =
        await rootBundle.loadString('assets/min_temperature_data.json');
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }

  List<DataRow> _generateDataRows() {
    if (_minTemperatureData == null || _maxTemperatureData == null) {
      return [];
    }
    List<DataRow> rows = [];
    int sNo = 1;
    DateTime currentDate = widget.startDate;
    double cumulativeGDD = 0.0;

    while (currentDate.isBefore(widget.endDate) ||
        currentDate.isAtSameMomentAs(widget.endDate)) {
      int dayOfYear = int.parse(DateFormat('D').format(currentDate));
      String yearKey = currentDate.year.toString();

      // Skip February 29 for non-leap years
      // if (currentDate.month == 2 &&
      //     currentDate.day == 29 &&
      //     !isLeapYear(currentDate.year)) {
      //   currentDate = currentDate.add(Duration(days: 1));
      //   continue;
      // }

      if (dayOfYear - 1 >= _minTemperatureData!.length ||
          _minTemperatureData![dayOfYear - 1][yearKey] == null) {
        currentDate = currentDate.add(Duration(days: 1));
        continue;
      }

      double minTemp = _minTemperatureData![dayOfYear - 1][yearKey];
      double maxTemp = _maxTemperatureData![dayOfYear - 1][yearKey];
      if (!isLeapYear(currentDate.year) &&
          currentDate.isAfter(DateTime(currentDate.year, 2, 28))) {
        minTemp = _minTemperatureData![dayOfYear][yearKey];
        maxTemp = _maxTemperatureData![dayOfYear][yearKey];
      }
      double dailyGDD = ((minTemp + maxTemp) / 2) - widget.baseTemp;
      if (dailyGDD < 0) {
        dailyGDD = 0;
      }
      cumulativeGDD += dailyGDD;

      rows.add(DataRow(cells: [
        DataCell(Text(sNo.toString(), style: TextStyle(fontSize: 15))),
        DataCell(Text(
            '${currentDate.day}-${currentDate.month}-${currentDate.year}',
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

  bool isLeapYear(int year) {
    if (year % 4 != 0) return false;
    if (year % 100 != 0) return true;
    if (year % 400 != 0) return false;
    return true;
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
            ),
          ),
          SingleChildScrollView(
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
          SizedBox(height: 20),
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
