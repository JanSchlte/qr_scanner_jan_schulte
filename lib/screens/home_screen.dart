//Dies ist praktisch nur der StartScreen. Außer einem Button weist dieser keine Funktionalität auf und enthält lediglich Style-Elemente
//Da fast alles nur Design-Elemente sind, wusste ich nicht genau, was ich dazu schreiben soll. Daher gibt es nicht allzu viele Kommentare.
import 'package:flutter/material.dart';
import 'package:qr_scanner/components/contact_cards.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //https://api.flutter.dev/flutter/material/Scaffold-class.html
      //Der Scaffold bietet immer das Grundgerüst: AppBar + Body des Screens
      appBar: AppBar(
        title: Text(
          'QR Scanner',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        //Hier werden alle children der Column schön auf dem Screen orientiert
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Jan Schulte',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pacifico',
              //Diese FontFamily musste ich mir extra aus dem Internet laden. Siehe pubsepc.yaml
              fontSize: 40.0,
              color: Colors.lightBlueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'FLUTTER ENTWICKLUNG'.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.blueGrey.shade900,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
            ),
          ),
          SizedBox(
            //Hier wird einfach der Strich entworfen, welcher den Text von den Karten trennen soll
            height: 20.0,
            width: 150.0,
            child: Divider(
              color: Colors.lightBlueAccent,
              thickness: 5.0,
            ),
          ),
          ContactCard(
            //Diese ContactCards habe ich selber programmiert. Siehe hierfür components\contact_cards
            icon: Icon(
              Icons.phone,
              color: Colors.lightBlueAccent,
            ),
            text: 'jan.schulte0211@gmail.com',
          ),
          SizedBox(
            height: 5.0,
            //Eine SizedBox ist lediglich immer dafür konzipiert, einen hard-gecodeten Abstand zu kreieren
          ),
          ContactCard(
            icon: Icon(
              Icons.mail,
              color: Colors.lightBlueAccent,
            ),
            text: '+49 170 3682566',
          ),
          SizedBox(
            height: 150.0,
          ),
          Padding(
            padding: EdgeInsets.all(25.0),
            //Mit diesem Padding-Widget erreiche ich, dass der Button nicht stumpf auf dem Boden klebt
            child: FlatButton(
              child: Padding(
                padding: EdgeInsets.all(5.0),
                //Mit diesem Padding-Widget wird ein Abstand zwischen dem "Scannen" Text und dem Button erschaffen
                child: Text(
                  'Scannen',
                  style: TextStyle(
                    fontSize: 45.0,
                    color: Colors.white,
                  ),
                ),
              ),
              color: Colors.lightBlueAccent,
              onPressed: () {
                //Dies ist die Funktion, die ausgelöst wird, wenn der Button gedrückt wird
                //Hier wird einfach nur zum (vorher benannten "scanner_screen" gewechselt
                Navigator.pushNamed(context, 'scanner_screen');
              },
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
                //Hiermit erreicht man die abgerundeten Ecken des Buttons
              ),
            ),
          ),
        ],
      ),
    );
  }
}
