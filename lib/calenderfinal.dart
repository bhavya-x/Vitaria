import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'chatwidgets.dart'; 
import 'custom_bottom_bar.dart';
class CalenderfinalWidget extends StatefulWidget {
  final PageController pageController;
  final int selectedIndex;

  CalenderfinalWidget({required this.pageController, required this.selectedIndex});

  @override
  _CalenderfinalWidgetState createState() => _CalenderfinalWidgetState();
}

class _CalenderfinalWidgetState extends State<CalenderfinalWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};
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
        Uri.parse('https://your-fastapi-endpoint.com/events?date=${date.toIso8601String()}'),
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

  Future<void> _addEvent(DateTime date, String event) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://your-fastapi-endpoint.com/events'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': date.toIso8601String(),
          'event': event,
        }),
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
          widget.pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final TextEditingController _eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: TextField(
            controller: _eventController,
            decoration: InputDecoration(hintText: 'Enter event name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_eventController.text.isNotEmpty && _selectedDay != null) {
                  _addEvent(_selectedDay!, _eventController.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}