import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mercadosalud/generated/locale_keys.g.dart';

class TimeAndDuration extends StatelessWidget {
  final String time;
  final String timeWithinHour;
  final bool free;
  final int price;
  TimeAndDuration({required this.time, required this.timeWithinHour, required this.free, required this.price});
  @override
  Widget build(BuildContext context) {
    String status = this.free ? LocaleKeys.UI_CalendarView_turno_libre.tr() : LocaleKeys.UI_CalendarView_turno_ocupado.tr();
    return Container(
      child: Row(
        children: [
          free ? Icon(Icons.arrow_left, size: 35, color: Colors.green): Icon(Icons.arrow_left, size: 35, color: Colors.redAccent),
          Text(
            formatFullHour(time, timeWithinHour),
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            status + " (\$" + price.toString() + ")",
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

  String formatFullHour(String time, String timeWithinHour) {
    return time.split(":").first + ":" + timeWithinHour;
  }
}
