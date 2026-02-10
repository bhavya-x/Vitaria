import 'package:flutter/material.dart';
import 'custom_bottom_bar.dart'; // Import the CustomBottomBar

class TimelineScreen extends StatefulWidget {
  final PageController pageController;
  final int selectedIndex;

  const TimelineScreen({
    super.key,
    required this.pageController,
    required this.selectedIndex,
  });

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final List<Map<String, dynamic>> _timelineEvents = [
    {
      'time': '08:00 AM',
      'title': 'Morning Medication',
      'description': 'Take 1 tablet of Lisinopril 10mg for blood pressure.',
    },
    {
      'time': '12:00 PM',
      'title': 'Doctor Appointment',
      'description': 'Check-up with Dr. Smith - Cardiology.',
    },
    {
      'time': '03:00 PM',
      'title': 'Afternoon Dose',
      'description': 'Take 2 tablets of Metformin 500mg for diabetes.',
    },
    {
      'time': '06:00 PM',
      'title': 'Evening Medication',
      'description': 'Take 1 capsule of Omeprazole 20mg for acid reflux.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Timeline'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Refresh the timeline
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: _timelineEvents.length,
        itemBuilder: (context, index) {
          final event = _timelineEvents[index];
          return TimelineEventCard(
            time: event['time'],
            title: event['title'],
            description: event['description'],
          );
        },
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
}

class TimelineEventCard extends StatelessWidget {
  final String time;
  final String title;
  final String description;

  const TimelineEventCard({
    super.key,
    required this.time,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0), // Note: 'bottom' seems intended instead of 'custom'
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}