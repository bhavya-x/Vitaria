import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'custom_bottom_bar.dart'; // Assuming this is your custom bottom bar file

class CalenderfinalWidget extends StatefulWidget {
  final PageController pageController;
  final int selectedIndex;

  const CalenderfinalWidget({
    super.key,
    required this.pageController,
    required this.selectedIndex,
  });

  @override
  _CalenderfinalWidgetState createState() => _CalenderfinalWidgetState();
}

class _CalenderfinalWidgetState extends State<CalenderfinalWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<String>> _events = {
    DateTime(2025, 3, 24): [
      '8:00 AM - Take 1 tablet of Lisinopril 10mg',
      '2:00 PM - Appointment with Dr. Smith (Cardiology)',
    ],
    DateTime(2025, 3, 25): [
      '9:00 AM - Take 2 tablets of Metformin 500mg',
      '6:00 PM - Take 1 capsule of Omeprazole 20mg',
    ],
    DateTime(2025, 3, 26): [
      '10:00 AM - Follow-up with Dr. Jones (Endocrinology)',
      '3:00 PM - Take 1 tablet of Atorvastatin 20mg',
    ],
  };
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchEventsForDate(_selectedDay!);
  }

  Future<void> _fetchEventsForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://vitaria.onrender.com/appointments/?date=${date.toIso8601String()}'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _events[date] = List<String>.from(responseData['events']);
        });
      } else {
        print('Failed to load events from API, using static events');
      }
    } catch (error) {
      print('Error fetching events: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addEvent(DateTime date, String eventJson) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://vitaria.onrender.com/appointments/appointment'),
        headers: {'Content-Type': 'application/json'},
        body: eventJson,
      );

      if (response.statusCode == 200) {
        await _fetchEventsForDate(date);
      } else {
        throw Exception('Failed to add event');
      }
    } catch (error) {
      print('Error adding event: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              if (_selectedDay != null) {
                _fetchEventsForDate(_selectedDay!);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _fetchEventsForDate(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) => [],
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    padding: EdgeInsets.all(16.0),
                    children: [
                      Text(
                        'Schedule for ${_selectedDay != null ? DateFormat('yyyy-MM-dd').format(_selectedDay!) : "selected date"}',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      if (_selectedDay != null)
                        ...(_events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? []).map((event) => Card(
                              elevation: 2.0,
                              margin: EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  event,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            )),
                      if (_selectedDay != null && (_events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? []).isEmpty)
                        Text('No events for this date.'),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedDay != null) {
            _showAddEventDialog(context);
          }
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: widget.selectedIndex,
        icons: [
          Icons.timeline,
          Icons.chat,
          Icons.calendar_today,
        ],
        routes: [
          '/timeline',
          '/chat',
          '/calendar',
        ],
        pageNames: [
          'Timeline',
          'Chat',
          'Calendar',
        ],
        onTap: (index) {
          if (widget.pageController.hasClients) {
            widget.pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final TextEditingController labelController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    TimeOfDay? selectedTime;
    bool repeatWeekly = false;
    String? errorMessage;

    final Map<String, bool> repeatDays = {
      'Sun': false,
      'Mon': false,
      'Tue': false,
      'Wed': false,
      'Thu': false,
      'Fri': false,
      'Sat': false,
    };
    if (_selectedDay != null) {
      final dayOfWeek = DateFormat('EEE').format(_selectedDay!);
      repeatDays[dayOfWeek] = true;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add New Event'),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label Field with Validation
                      TextField(
                        controller: labelController,
                        decoration: InputDecoration(
                          labelText: 'Event Label *',
                          hintText: 'e.g., Medication Dose',
                          border: OutlineInputBorder(),
                          errorText: errorMessage,
                        ),
                      ),
                      SizedBox(height: 16.0),

                      // Time Field with Time Picker
                      TextField(
                        controller: timeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Event Time *',
                          hintText: 'Select time',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.access_time),
                            onPressed: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  selectedTime = picked;
                                  timeController.text = picked.format(context);
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),

                      // Description Field
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'e.g., Take with water',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 16.0),

                      // Repeat Toggle Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Repeat Weekly',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Switch(
                            value: repeatWeekly,
                            onChanged: (value) {
                              setDialogState(() {
                                repeatWeekly = value;
                              });
                            },
                          ),
                        ],
                      ),

                      // Show repeat days only if repeatWeekly is true
                      if (repeatWeekly) ...[
                        SizedBox(height: 8.0),
                        Text(
                          'Select Days:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 6.0,
                          children: repeatDays.keys.map((day) {
                            return FilterChip(
                              label: Text(day),
                              selected: repeatDays[day]!,
                              onSelected: (selected) {
                                setDialogState(() {
                                  repeatDays[day] = selected;
                                });
                              },
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (labelController.text.isEmpty) {
                      setDialogState(() {
                        errorMessage = 'Please enter an event label';
                      });
                    } else if (selectedTime == null) {
                      setDialogState(() {
                        errorMessage = 'Please select an event time';
                      });
                    } else if (repeatWeekly && !repeatDays.values.any((selected) => selected)) {
                      setDialogState(() {
                        errorMessage = 'Please select at least one day for repeat';
                      });
                    } else {
                      final eventTime = selectedTime!.format(context);
                      final event = {
                        'label': labelController.text,
                        'time': eventTime,
                        'description': descriptionController.text,
                        'repeat_weekly': repeatWeekly,
                        'repeat_days': repeatWeekly ? repeatDays : null,
                      };
                      if (_selectedDay != null) {
                        final eventString = '$eventTime - ${labelController.text}${descriptionController.text.isNotEmpty ? " (${descriptionController.text})" : ""}';
                        setState(() {
                          final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                          _events[dateKey] = _events[dateKey] ?? [];
                          _events[dateKey]!.add(eventString);
                        });
                        _addEvent(_selectedDay!, json.encode(event));
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add Event'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}