import 'package:flutter/material.dart';

class TimeAndDurationTemplate extends StatelessWidget {
  final String time;
  final String fraction;
  final int price;
  TimeAndDurationTemplate({required this.time, required this.fraction, required this.price});
  @override
  Widget build(BuildContext context) {
    print(time);
    return Container(
      child: Row(
        children: [
          Icon(Icons.arrow_left, size: 35, color: Colors.green),
          Text(
            time,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            fraction + " (\$" + price.toString() + ")",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
