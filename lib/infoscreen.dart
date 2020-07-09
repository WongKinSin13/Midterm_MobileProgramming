import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:test_midsem/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InfoScreen extends StatefulWidget {
  final Destination destination;

  const InfoScreen({Key key, this.destination}) : super(key: key);

  @override
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  double screenHeight, screenWidth;
  List<Marker> allMarkers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(65, 105, 225, 1),
        title: Text(" " + widget.destination.locname, style: TextStyle(fontSize: 23.0,)),
      ),
      body: Container(
        color: Color.fromRGBO(65, 105, 225, 0.1),
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Container(
              height: screenHeight / 3,
              width: screenWidth / 1.5,
              child: CachedNetworkImage(
                fit: BoxFit.fill,
                imageUrl:
                    "http://slumberjer.com/visitmalaysia/images/${widget.destination.imagename}",
                placeholder: (context, url) => new CircularProgressIndicator(),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              ),
            ),
            SizedBox(height: 6),
            Container(
                //width: screenWidth / 1.2,
                child: Card(
                    color: Colors.lightBlue[50],
                    elevation: 6,
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Table(
                                defaultColumnWidth: FlexColumnWidth(1.0),
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 400,
                                          child: Text("Description",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 400,
                                          child: Text(
                                            " " +
                                                widget.destination.description,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 100,
                                          child: Text("Web link",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: GestureDetector(
                                          onTap: _launchURL,
                                          child: Text(
                                            " " + widget.destination.url,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 100,
                                          child: Text("Address",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 100,
                                          child: Text(
                                            " " + widget.destination.address,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 30,
                                          child: Text("Contact",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: GestureDetector(
                                          onTap: () => launch(
                                              "tel://${widget.destination.contact}"),
                                          child: Text(
                                            " " + widget.destination.contact,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ]),
                                ]),
                            SizedBox(height: 3),
                          ],
                        )))),
          ],
        )),
      ),
    );
  }

  _launchURL() async {
    String url = 'http://${widget.destination.url}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch link: $url';
    }
  }
}
