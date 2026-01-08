import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int selectedIndex;
  final List<IconData> icons;
  final List<String> routes;
  final List<String> pageNames;
  final Function(int) onTap;

  CustomBottomBar({
    required this.selectedIndex,
    required this.icons,
    required this.routes,
    required this.pageNames,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) { // context is already available here
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildIcons(context), // Pass context inside build function
      ),
    );
  }

  List<Widget> _buildIcons(BuildContext context) {
    return List.generate(icons.length, (index) {
      return GestureDetector(
        onTap: () {
          if (selectedIndex != index) {
            Navigator.pushReplacementNamed(context, routes[index]); // Navigate on tap
          }
          onTap(index);
        },
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: selectedIndex == index ? Colors.green.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icons[index],
                color: selectedIndex == index ? Colors.green : Colors.grey,
                size: 35.0,
              ),
              Text(
                pageNames[index],
                style: TextStyle(
                  color: selectedIndex == index ? Colors.green : Colors.grey,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
