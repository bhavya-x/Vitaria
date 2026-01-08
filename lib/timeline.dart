import 'package:flutter/material.dart';
import 'chatwidgets.dart'; // Assuming this contains the CustomBottomBar
import 'custom_bottom_bar.dart';
class TimelineScreen extends StatefulWidget {
  final PageController pageController;
  final int selectedIndex;

  const TimelineScreen({super.key, required this.pageController, required this.selectedIndex});

  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final List<Map<String, dynamic>> _timelineEvents = [
    {
      'time': '10:00 AM',
      'title': 'Team Meeting',
      'description': 'Discuss project updates and deadlines.',
    },
    {
      'time': '12:00 PM',
      'title': 'Lunch Break',
      'description': 'Take a break and recharge.',
    },
    {
      'time': '02:00 PM',
      'title': 'Client Call',
      'description': 'Discuss requirements for the new project.',
    },
    {
      'time': '04:00 PM',
      'title': 'Code Review',
      'description': 'Review the latest pull requests.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline'),
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
          widget.pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}

class TimelineEventCard extends StatelessWidget {
  final String time;
  final String title;
  final String description;

  const TimelineEventCard({super.key, 
    required this.time,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
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