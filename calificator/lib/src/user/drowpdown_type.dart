import 'package:calificator/src/user/user_type.dart';
import 'package:flutter/material.dart';



class DropdownType extends StatefulWidget {
   Function(UserType) notifyParent;


   DropdownType({Key? key,required this.notifyParent}) : super(key: key);



  @override
  State<DropdownType> createState() => _DropdownTypeState();
}

class _DropdownTypeState extends State<DropdownType> {
  UserType dropdownValue = UserType.values.first;



  _DropdownTypeState();

  @override
  Widget build(BuildContext context) {
    return DropdownButton<UserType>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.green),
      underline: Container(
        height: 2,
        color: Colors.green,
      ),
      onChanged: (UserType? value) {
        // This is called when the user selects an item.
        dropdownValue=value!;
        widget.notifyParent(value!);

      },
      items: UserType.values.map<DropdownMenuItem<UserType>>((UserType userType) {
        return DropdownMenuItem<UserType>(
          value: userType,
          child: Text(userType.value),
        );
      }).toList(),
    );
  }
}
