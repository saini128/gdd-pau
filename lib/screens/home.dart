import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'tablePage.dart';

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

  final List<String> _crops = ['Rice', 'Wheat', 'Maize', 'Cotton', 'Mustard'];
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
          _startDateController.text = DateFormat.yMMMd().format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat.yMMMd().format(picked);
        }
      });
    }
  }

  @override
  void dispose() {
    _baseTempController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GDD Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset('assets/app_image.jpg', height: 200)),
            const SizedBox(height: 20),
            const Text(
              'Enter the required details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Crop',
                border: OutlineInputBorder(),
              ),
              value: _selectedCrop,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCrop = newValue;
                  if (_selectedCrop == 'Rice' ||
                      _selectedCrop == 'Maize' ||
                      _selectedCrop == 'Cotton') {
                    _baseTempController.text = '10';
                    _baseTemp = double.tryParse('10');
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
                      labelText: 'Start Date',
                      hintText: 'Select Start Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
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
                      labelText: 'End Date',
                      hintText: 'Select End Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
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
              decoration: const InputDecoration(
                labelText: 'Base Temperature (°C)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _baseTemp = double.tryParse(value);
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedCrop != null &&
                      _startDate != null &&
                      _endDate != null &&
                      _baseTemp != null) {
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
                      const SnackBar(
                        content: Text('Please fill all fields'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
