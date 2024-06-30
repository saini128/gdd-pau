import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'tablePage.dart'; // Adjust the import to match your project's structure

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _selectedCrop;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _baseTemp;

  final List<String> _crops = ['Rice', 'Wheat', 'Maize', 'Cotton'];
  final TextEditingController _baseTempController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
    print(_startDate);
    print(_endDate);
  }

  @override
  void dispose() {
    _baseTempController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GDD Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/app_image.jpg'),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('Enter the required details'),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Select Crop'),
              value: _selectedCrop,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCrop = newValue;
                  if (_selectedCrop == 'Rice' || _selectedCrop == 'Maize') {
                    _baseTempController.text = '10';
                    _baseTemp = double.tryParse('10');
                  } else if (_selectedCrop == 'Cotton') {
                    _baseTempController.text = '15';
                    _baseTemp = double.tryParse('15');
                  } else {
                    _baseTempController.text = '5';
                    _baseTemp = double.tryParse('5');
                  }
                });
              },
              items: _crops.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: _startDate == null
                          ? 'Start Date'
                          : DateFormat.yMMMd().format(_startDate!),
                      hintText: _startDate == null
                          ? 'Select Start Date'
                          : DateFormat.yMMMd().format(_startDate!),
                    ),
                    onTap: () {
                      _selectDate(context, true);
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: _endDateController,
                    decoration: InputDecoration(
                      labelText: _endDate == null
                          ? 'End Date'
                          : DateFormat.yMMMd().format(_endDate!),
                      hintText: _endDate == null
                          ? 'Select End Date'
                          : DateFormat.yMMMd().format(_endDate!),
                    ),
                    onTap: () {
                      _selectDate(context, false);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              readOnly: true,
              controller: _baseTempController,
              decoration:
                  const InputDecoration(labelText: 'Base Temperature (°C)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _baseTemp = double.tryParse(value);
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_baseTemp != null) {
                  print("Passed data");
                  print(_startDate);
                  print(_endDate);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TablePage(
                        startDate: _startDate!,
                        endDate: _endDate!,
                        baseTemp: _baseTemp!,
                        crop: _selectedCrop!,
                      ),
                    ),
                  );
                } else {
                  // Show error message if any field is not filled
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
