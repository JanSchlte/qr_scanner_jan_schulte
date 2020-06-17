//Hier werden die für den scanner_screen relevanten Pakete importiert. Dazu gehören natürlich diverse, vorher entworfene Elemente aus \components
//Außerdem werden hier die im pubspec.yaml gedownloadeten Pakete konkret für die Verwendung importiert
import 'dart:typed_data';
import 'package:qr_scanner/components/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
//Dies ist das QR-Plugin, auf welches unten im Code dann immer einfach mit scanner zugegriffen werden kann
import 'package:share/share.dart';
import 'package:flutter/services.dart';

class ScannerScreen extends StatefulWidget {
  //Da der scanner_screen extrem komplex ist, muss alles in einem Stateful Widget gecodet werden
  //https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  //Dies ist der ScaffoldKey, welcher später zur Steuerung der "Snack-Bar" verwendet werden muss
  String barcode = '';
  //Der String barcode ist das Ergebnis der Scans und hat später noch eine große Wichtigkeit für das Script
  Uint8List bytes = Uint8List(200);
  //Auf dieser Uint8List basiert später der generierte QR-Code
  bool pictureIsVisible = false;
  //Diese Variable ist für die dynamische Anzeige der Funktionen bzw. Buttons relevant
  final TextEditingController _controller = new TextEditingController();
  //Der TextEditingController ist im Endeffekt nur dafür wichtig, später die Tastatur beim Textfeld entfernen zu können

  @override
  initState() {
    super.initState();
  }
  //https://api.flutter.dev/flutter/widgets/State/initState.html
  //Diese Methode wird nur einmal bei der Erstellung des Widgets abgerufen werden

  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  //https://api.flutter.dev/flutter/widgets/State/dispose.html
  //Für Performance Zwecken wird der controller in dieser Methode gelöscht, wenn das Widget zerstört wurde (wenn z. B. der Screen wieder zurückgewechselt werden würde

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('QR Scanner'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: ListView(
          //Ein ListView habe ich an dieser Stelle verwendet, da ich mit einer Column Probleme hatte, da ich recht viele Größen gehardcoded habe und es dann
          //massig Probleme mit den Abmessungen der unterschiedlichen Screen-Größen gab. Ein ListView ermöglicht dem User praktisch einfach, nach unten zu scrollen. Somit
          //wird es keine Fehlermeldungen wegen den Abmessungen geben
          //https://api.flutter.dev/flutter/widgets/ListView-class.html
          shrinkWrap: true,
          //https://api.flutter.dev/flutter/widgets/ListView/shrinkWrap.html
          //Durch shrinkWrap = true ist die Größe des ListViews von dem enthaltenen Content abhängig
          children: <Widget>[
            Padding(
              //Mit diesem Padding-Widget wird Abstand vom Rand geschaffen
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                //Hier wird das TextFeld programmiert, in welches der User seine eigene URL einfügen kann bzw. soll
                controller: _controller,
                style: TextStyle(color: Colors.black54),
                decoration: InputDecoration(
                  //Hier wird das Textfeld nur etwas verschönert
                  labelText: 'Deine URL einfügen',
                  fillColor: Colors.white70,
                  suffixIcon: IconButton(
                    //https://api.flutter.dev/flutter/material/InputDecoration/suffixIcon.html
                    //SuffixIcon = Icon im Textfeld, welchem mit dem IconButton eine Funktionalität zugesprochen wurde
                    icon: Icon(Icons.check_circle_outline),
                    onPressed: () {
                      setState(() {
                        //https://api.flutter.dev/flutter/widgets/State/setState.html
                        //Dem Framework wird mitgeteilt, dass der State des Objekts geändert wurde. Veranlasst also praktisch einen Re-Build
                        _controller.clear();
                        //Hier wird das Textfeld geleert, nachdem die Eingabe durch den IconButton bestätigt wurde
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        //Mit diesem Befehl wird die Tastatur dann automatisch entfernt, da der User dies sonst manuell hätte tun müssen
                        this.bytes = Uint8List(0);
                        pictureIsVisible = false;
                        //Der potenziell generierte QR-Code wird gelöscht und dementsprechend auch die dazugehörige boolean-Variable auf false gesetzt
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  barcode = value;
                  //Hier wird der Inhalt des Textfelds auf den String barcode übertragen
                },
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            SizedBox(
              width: 220,
              height: 220,
              child: Image.memory(bytes),
              //Diese SizedBox enthält den potenziell generierten QR-Code
            ),
            SizedBox(
              height: 5.0,
            ),
            Row(
              //In dieser Row wird praktisch nur der String Barcode angezeigt
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Icon(
                    Icons.info,
                    color: Colors.blueGrey,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Text(
                      'Ergebnis: $barcode',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: barcode == ''
                        ? Colors.blueGrey
                        : Colors.lightBlueAccent,
                    //Hier wird signalisiert, dass man auch nur die URL teilen kann, falls eine URL überhaupt existiert
                  ),
                  onPressed: () {
                    _share(context, barcode);
                    //Die share Methode von unten wird mit dem Barcode-String aufgerufen, d. h. man kann den Link über das Share-Plugin teilen
                  },
                ),
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            Column(
              //Info: Ich konnte diese ganzen Button nicht einmal coden und dann immer etwas abändern, da ich
              //sie nicht aus der Column als Widget extracten konnte. Daher ist dies nicht wirklich schöner Code.
              //Allerdings konnte ich es aufgrund der Funktionalität nicht schöner machen.
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  //Mit dem padding wird ein Seitenabstand vom Bildschirmrand erzeugt
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(horizontal: 50.0),
                    //Mit dem padding wird ein Seitenabstand erzeugt
                    color: kButtonColor,
                    onPressed: _scan,
                    //Die _scan Methode von unten wird aufgerufen.
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text("Scannen", style: kButtonTextStyle),
                    ),
                  ),
                ),
                SizedBox(
                  height: kSizedBoxHeight,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: RaisedButton(
                    color: kButtonColor,
                    onPressed: _scanPhoto,
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text("Foto Scannen", style: kButtonTextStyle),
                    ),
                  ),
                ),
                SizedBox(
                  height: kSizedBoxHeight,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: RaisedButton(
                    color: kButtonColor,
                    onPressed: barcode == '' ? null : () => _launchURL(barcode),
                    //Dieser Button soll nur funktionieren, wenn auch wirklich ein String Barcode vorhanden ist, mit dem man eine Internet Seite öffnen könnte
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Text("URL öffnen", style: kButtonTextStyle),
                    ),
                  ),
                ),
                SizedBox(
                  height: kSizedBoxHeight,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: RaisedButton(
                    color: kButtonColor,
                    onPressed: barcode == ''
                        ? null
                        : () {
                            _generateBarCode(barcode);
                            pictureIsVisible = true;
                          },
                    //Dieser Button soll nur funktionieren, wenn auch wirklich ein String Barcode vorhanden ist, mit dem man einen QR-Code generieren könnte
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child:
                          Text("QR-Code generieren", style: kButtonTextStyle),
                    ),
                  ),
                ),
                SizedBox(
                  height: kSizedBoxHeight,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        //Mit diesem IconButton kann man den generierten QR-Code im lokalen Speicher sichern
                        Icons.file_download,
                        color: pictureIsVisible == false
                            ? null
                            : Colors.lightBlueAccent,
                        size: kIconSize,
                        //Dies soll wieder signalisieren, dass man den QR-Code nur speichern kann, falls dieser schon generiert wurde. Dafür existiert extra die pictureIsVisible-Variable
                      ),
                      onPressed: pictureIsVisible == false
                          ? null
                          : () async {
                              //Diese Methode muss zwangsläufig vom Typ async sein
                              //https://dart.dev/codelabs/async-await
                              //Die async Methode wird verwendet, damit das Programm während dieser komplexen Aufgabe weiterlaufen kann und sich nicht aufhängt
                              final picture =
                                  await ImageGallerySaver.saveImage(this.bytes);
                              //Dies ist der tatsächliche Speichervorgang des generierten QR-Codes, welcher durch das saveImage Plugin gelingen kann
                              SnackBar snackBar;
                              //Eine SnackBar ist so etwas wie eine kurze Benachrichtigung
                              //https://api.flutter.dev/flutter/material/SnackBar-class.html
                              bool success = picture == null ? false : true;
                              //Diese Variable wird eingeführt, um später die Snackbar korrekt anzeigen zu können
                              if (success) {
                                //Falls das Speichern erfolgreich war
                                snackBar = new SnackBar(
                                  content: new Text(
                                    'QR-Code erfolgreich gespeichert!',
                                    style: (TextStyle(color: Colors.white)),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  //Dadurch scheint die Snackbar leicht zu "schweben"
                                  backgroundColor: Colors.blueGrey,
                                  duration: Duration(seconds: 3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                      //Hier wird die Snackbar rechts und links oben abgerundet, um ein schöneres Design zu kriegen
                                    ),
                                  ),
                                );
                                _scaffoldKey.currentState
                                    .showSnackBar(snackBar);
                                //Der ScaffoldKey muss zwangsläufig verwendet werden, wenn  man eine SnackBar anzeigen will. Nur darum habe ich ihn oben eingeführt
                              } else {
                                //Falls es einen Fehler beim Speichervorgang gab
                                snackBar = new SnackBar(
                                  content: new Text(
                                      'QR-Code konnte nicht gespeichert werden!'),
                                  backgroundColor: Colors.blueGrey,
                                  duration: Duration(seconds: 3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                    ),
                                  ),
                                );
                                _scaffoldKey.currentState
                                    .showSnackBar(snackBar);
                              }
                            },
                    ),
                    IconButton(
                      //Dieser IconButton soll einfach nur alles wieder auf den Ursprung setzen
                      icon: Icon(
                        Icons.clear,
                        color: barcode == '' ? null : Colors.lightBlueAccent,
                        size: kIconSize,
                      ),
                      color: kButtonColor,
                      onPressed: barcode == ''
                          //Diese Methode macht allerdings nur Sinn, wenn überhaupt etwas zu clearen existiert. Dafür sorgt diese kurze if-Abfrage
                          ? null
                          : () {
                              _delete();
                            },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
      //Hier wird auch nur das unschöne Debug-Banner entfernt
    );
  }

  //Aufgrund der Komplexität der Aufgaben müssen sie beinahe alle vom Typ async sein, damit das System
  //weiter flüssig laufen kann. Andernfalls würde es sich wahrscheinlich bei jeder Aufgabe lange aufhängen

  Future _scan() async {
    String barcode = await scanner.scan();
    setState(() => this.barcode = barcode);
    //Mit dem qr-Plugin wird hier die Kamera für einen klassischen QR-Scan verwendet
  }

  Future _scanPhoto() async {
    String barcode = await scanner.scanPhoto();
    setState(() => this.barcode = barcode);
    //Diese Methode greift auf die Gallerie zu und scannt dann den bereits gespeicherten QR-Code.
  }

  Future _generateBarCode(String eigeneURL) async {
    Uint8List result = await scanner.generateBarCode(eigeneURL);
    /*
    Diese Methode generiert den QR Code. Dafür wird das qr-Plugin benötigt (siehe pubspec.yaml)
    Im source Code:
    Future<Uint8List> generateBarCode(String code) async {
    assert(code != null && code.isNotEmpty);
    return await _channel.invokeMethod('generate_barcode', {"code": code});
    */
    this.setState(() {
      //Erneut veranlasst die SetState Methode ein Rebuild des Stateful-Widget
      this.bytes = result;
      this.barcode = eigeneURL;
    });
  }

  _launchURL(String providedURL) async {
    //diese Methode öffnet einfach die gegebene URL. Dafür wird das Plug-In url_launcher benötigt
    String url = providedURL;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw '$url konnte nicht geöffnet werden';
    }
  }

  _delete() {
    setState(() {
      this.bytes = Uint8List(0);
      pictureIsVisible = false;
      barcode = '';
      //Dies ist die clear Methode. Hier werden einfach nur alle Variablen auf den default-Value zurückgesetzt
    });
  }

  _share(BuildContext context, String sharedItem) {
    Share.share(sharedItem);
    //Dies ist die share Methode, mit der man dann später mal den Link an andere teilen kann. Diese Methode basiert auf dem share-Plug-In aus der pubspec.yaml Datei
  }
}
