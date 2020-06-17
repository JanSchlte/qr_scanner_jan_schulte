//In dieser Klasse werden die Kontaktkarten auf dem home_screen entworfen
import 'package:flutter/material.dart';

class ContactCard extends StatelessWidget {
  final Icon icon;
  final String text;

  ContactCard({this.icon, this.text});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
      child: Padding(
        padding: EdgeInsets.all(0.01),
        child: ListTile(
          leading: icon,
          title: Text(
            text,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 17.5,
              color: Colors.blueGrey.shade900,
            ),
          ),
        ),
      ),
    );
  }
}
