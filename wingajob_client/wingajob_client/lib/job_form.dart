import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

class JobForm extends StatefulWidget {
  @override
  _JobFormState createState() => _JobFormState();
}

class _JobFormState extends State<JobForm> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _jobType;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _location;
  late String _jobKeywords;
  late final AnimationController _controller;
  bool _detailsPopulated = false;

  final Color _accentColor = Colors.blue;
  final TextStyle _labelStyle =
      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
  final TextStyle _inputStyle = TextStyle(fontSize: 14.0);

  @override
  void initState() {
    super.initState();
    _jobType = 'Full-time';
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    _location = '';
    _jobKeywords = '';
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _checkDetailsPopulated();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  InputDecoration _decorate(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: _labelStyle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      filled: true,
      fillColor: Colors.grey[200],
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _accentColor),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Form'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _jobType,
                onChanged: (value) {
                  setState(() {
                    _jobType = value!;
                    _checkDetailsPopulated();
                  });
                },
                decoration: _decorate('Job Type'),
                items: ['Full-time', 'Internship']
                    .map((jobType) => DropdownMenuItem(
                          value: jobType,
                          child: Text(jobType),
                        ))
                    .toList(),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                  decoration:
                      _decorate('Start Date: ${_formatDate(_startDate)}'),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _startDate = pickedDate;
                        _checkDetailsPopulated();
                      });
                    }
                  }),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: _decorate('End Date: ${_formatDate(_endDate)}'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _endDate = pickedDate;
                      _checkDetailsPopulated();
                    });
                  }
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: _decorate('Location'),
                style: _inputStyle,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter location' : null,
                onSaved: (value) => _location = value!,
                onChanged: (value) {
                  setState(() {
                    _location = value;
                    _checkDetailsPopulated();
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: _decorate('Job Keywords'),
                style: _inputStyle,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter job keywords' : null,
                onSaved: (value) => _jobKeywords = value!,
                onChanged: (value) {
                  setState(() {
                    _jobKeywords = value;
                    _checkDetailsPopulated();
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: _accentColor,
                ),
                onPressed: _detailsPopulated ? _submitForm : null,
                child: Text('Submit'),
              ),
              SizedBox(height: 16.0),
              if (_detailsPopulated) _buildUI(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _checkDetailsPopulated() {
    setState(() {
      _detailsPopulated = _jobType.isNotEmpty &&
          _location.isNotEmpty &&
          _jobKeywords.isNotEmpty;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // print('Job Type: $_jobType');
      // print('Start Date: $_startDate');
      // print('End Date: $_endDate');
      // print('Location: $_location');
      // print('Job Keywords: $_jobKeywords');

      if (_jobType == 'Full-time') {
        _jobType = '1';
      } else {
        _jobType = '0';
      }

      var formData = {
        'jobType': _jobType,
        'startDate': _startDate.toString(),
        'endDate': _endDate.toString(),
        'location': _location,
        'jobKeywords': _jobKeywords,
      };

      String jsonData = json.encode(formData);
      print('my request json would be like:$jsonData');

      try {
        var response = await http.post(
          Uri.parse('http://localhost:5000/submit'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Access-Control-Allow-Origin': '*',
            'Connection': 'keep-alive'
          },
          body: json.encode(formData),
        );

        if (response.statusCode == 200) {
          print('Form data submitted successfully');
        } else {
          print(
              'Failed to submit form data. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error submitting form data: $e');
      }

      var ticker = _controller.forward();
      ticker.whenComplete(() {
        _controller.reset();
      });
    }
  }

  Widget _buildUI() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Lottie.asset(
              "assets/animations/peopledance.json",
              controller: _controller,
              repeat: true,
              // width: 500,
              // height: 500,
              width: MediaQuery.sizeOf(context).height,
              height: MediaQuery.sizeOf(context).width,
            ),
          ),
          Positioned.fill(
            child: Lottie.asset(
              "assets/animations/confetti.json",
              controller: _controller,
              // width: MediaQuery.sizeOf(context).height,
              // height: MediaQuery.sizeOf(context).width,
              fit: BoxFit.cover,
              repeat: false,
            ),
          ),
        ],
      ),
    );
  }
}
