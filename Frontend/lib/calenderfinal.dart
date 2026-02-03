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
  final Map<DateTime, List<String>> _events = {};
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
            'https://your-fastapi-endpoint.com/events?date=${date.toIso8601String()}'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _events[date] = List<String>.from(responseData['events']);
        });
      } else {
        throw Exception('Failed to load events');
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
        Uri.parse('https://your-fastapi-endpoint.com/events'),
        headers: {'Content-Type': 'application/json'},
        body: eventJson, // JSON string directly passed
      );

      if (response.statusCode == 200) {
        await _fetchEventsForDate(date); // Refresh events for the selected date
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
            eventLoader: (day) => _events[day] ?? [],
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    padding: EdgeInsets.all(16.0),
                    children: [
                      Text(
                        'Schedule for ${_selectedDay != null ? _selectedDay!.toLocal().toString().split(' ')[0] : "selected date"}',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      if (_selectedDay != null && _events[_selectedDay] != null)
                        ..._events[_selectedDay]!.map((event) => ListTile(
                              title: Text(event),
                            )),
                      if (_selectedDay != null && _events[_selectedDay] == null)
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
    bool repeatWeekly = false; // Toggle for weekly repeat
    String? errorMessage;

    // Repeat days with toggle chips, visible only if repeatWeekly is true
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
      final dayOfWeek = DateFormat('EEE').format(_selectedDay!); // Short day name (e.g., Mon)
      repeatDays[dayOfWeek] = true; // Pre-select the current day
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
                  maxWidth: MediaQuery.of(context).size.width * 0.85, // Limit dialog width
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
                          hintText: 'e.g., Team Meeting',
                          border: OutlineInputBorder(),
                          errorText: errorMessage,
                        ),
                      ),
                      SizedBox(height: 16.0),

                      // Description Field
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'e.g., Discuss project updates',
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
                          spacing: 6.0, // Reduced spacing to fit better
                          runSpacing: 6.0, // Vertical spacing between rows
                          children: repeatDays.keys.map((day) {
                            return FilterChip(
                              label: Text(day),
                              selected: repeatDays[day]!,
                              onSelected: (selected) {
                                setDialogState(() {
                                  repeatDays[day] = selected;
                                });
                              },
                              padding: EdgeInsets.symmetric(horizontal: 8.0), // Compact chips
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
                    } else if (repeatWeekly && !repeatDays.values.any((selected) => selected)) {
                      setDialogState(() {
                        errorMessage = 'Please select at least one day for repeat';
                      });
                    } else {
                      final event = {
                        'label': labelController.text,
                        'description': descriptionController.text,
                        'repeat_weekly': repeatWeekly,
                        'repeat_days': repeatWeekly ? repeatDays : null, // Include days only if repeating
                      };
                      if (_selectedDay != null) {
                        _addEvent(_selectedDay!, json.encode(event)); // Structured JSON
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