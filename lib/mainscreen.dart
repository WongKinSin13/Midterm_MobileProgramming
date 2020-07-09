import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:test_midsem/location.dart';
import 'package:test_midsem/infoscreen.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MainScreen extends StatefulWidget {

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List locations;
  int curnumber = 1;
  double screenHeight, screenWidth;

  String curstate = "Kedah";

  String selectedState;
  int quantity = 1;

  List<String> listState = [
    "Johor",
    "Kedah",
    "Kelantan",
    "Melaka",
    "Negeri Sembilan",
    "Pahang", 
    "Penang",
    "Perlis",
    "Perak",
    "Selangor",
    "Sabah",
    "Sarawak",
    "Terengganu"
  ];

  @override
  
  void initState() {
    super.initState();

    _loadData();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    if (locations == null) {
     
      return Scaffold(
          backgroundColor: Color.fromRGBO(65, 105, 225, 0.1),
          appBar: AppBar(
            title: Text('Locations', style: TextStyle(fontSize: 23.0,),),
            leading: Icon(Icons.location_on),
            backgroundColor: Color.fromRGBO(65, 105, 225, 1),
          ),
          body: Container(
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Loading locations...",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                )
              ],
            ),
          )));
    }

      
    return WillPopScope(
      
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Locations', style: TextStyle(fontSize: 23.0,),),
            leading: Icon(Icons.location_on),
            backgroundColor: Color.fromRGBO(65, 105, 225, 1),
            actions: <Widget>[
              //
            ],
          ),
          body: Container(
            color: Color.fromRGBO(65, 105, 225, 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 5),
                Container(
                  height:25,
                  color: Colors.white,
                  child: DropdownButton(
                    dropdownColor: Colors.lightBlueAccent[50],
                    
                    hint: Text(
                      'States',
                      textAlign: TextAlign.center,
                      
                    ),
                    value: selectedState,
                    onChanged: (newValue) {
                      setState(() {
                        selectedState = newValue;

                        print(selectedState);
                        _sortItem(selectedState);
                      });
                    },

                    items: listState.map((selectedState) {
                      return DropdownMenuItem(
                    child: SizedBox(
      width: 100.0, // for example
      child: Text(selectedState, textAlign: TextAlign.center, maxLines: 2,),
    ),
    value: selectedState,);
  }).toList(),
                  ),
                ),
                new SizedBox(height:5),   
                new Icon(Icons.flag, color: Color.fromRGBO(65, 105, 225, 1)),
                Text("Selected state: "+ curstate,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color:Color.fromRGBO(65, 105, 225, 1))),
                new SizedBox(height:5),    
                Flexible(
                    child: GridView.count(
                        crossAxisCount: 2,
                        //childAspectRatio: (9 / 10),
                        children: List.generate(locations.length, (index) {
                          return Card(
                              color: Colors.lightBlue[50],
                              elevation: 8,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(5,0,5,0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () => _onDestinationDetail(index),

                                          child: CachedNetworkImage(
                                          height: 120,
                                        width: 200 ,
                                          fit: BoxFit.cover,
                                          imageUrl:
                                              "http://slumberjer.com/visitmalaysia/images/${locations[index]['imagename']}",
                                          placeholder: (context, url) =>
                                              new CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              new Icon(Icons.error),
                                        ),
                                      //),
                                    ),
                                    new SizedBox(height: 5.0,),
                                    Text(locations[index]['state'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    /*Text(
                                      "State: " + locations[index]['state'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),*/
                                    Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: new Text(locations[index]['loc_name'],
                    textAlign: TextAlign.center,
                    
                    style: TextStyle(
                      fontSize: 17.0,
                      color: Colors.deepOrange
                      
                    ),
                    ),
                    
                  ),
                                  ],
                                ),
                              ));
                        })))
              ],
            ),
          ),
        ));
  }

  _onDestinationDetail(int index) async {
    print(locations[index]['loc_name']);
    Destination destination = new Destination(
        pid: locations[index]['pid'],
        locname: locations[index]['loc_name'],
        state: locations[index]['state'],
        description: locations[index]['description'],
        latitude: locations[index]['latitude'],
        longitude: locations[index]['longitude'],
        url: locations[index]['url'],
        contact: locations[index]['contact'],
        address: locations[index]['address'],
        imagename: locations[index]['imagename']);

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => InfoScreen(
                  destination: destination,
                )));
    _loadData();
  }

  void _loadData() {
    
    String urlLoadJobs =
        "https://slumberjer.com/visitmalaysia/load_destinations.php";
    http.post(urlLoadJobs, body: {}).then((res) {
      setState(() {
        var extractdata = json.decode(res.body);
        locations = extractdata["locations"];
        
        _sortItem(curstate);
      });
    }).catchError((err) {
      print(err);
    });
  }

  void _sortItem(String state) {
    
   
    try {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: true);
      pr.style(message: "Working on it...");
      pr.show();
      String urlLoadJobs =
          "https://slumberjer.com/visitmalaysia/load_destinations.php";
      http.post(urlLoadJobs, body: {
        "state": state,
      }).then((res) {
        setState(() {
          
          curstate = state;
          var extractdata = json.decode(res.body);
          locations = extractdata["locations"];
          FocusScope.of(context).requestFocus(new FocusNode());
          pr.hide();
        });
      }).catchError((err) {
        print(err);
        pr.hide();
      });
      pr.hide();
    } 
    
    catch (e) {
      Toast.show("Error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
    
  }

  Future<bool> _onBackPressed() {
    savepref(true);
    
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            backgroundColor: Colors.lightBlue[50],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            title: new Text(
              'Close application',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            content: new Text(
              'Do you want to exit?',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                  onPressed: () {
                    
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Text(
                    "Exit",
                    style: TextStyle(
                      color: Colors.blue[400],
                    ),
                  )),
              MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.blue[400],
                    ),
                  )),
            ],
          ),
        ) ??
        false;
  }

  void savepref(bool value) async {
    String state = curstate;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      //save preference
      await prefs.setString('state', state);
    }
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String state = (prefs.getString('state')) ?? '';

    setState(() {
      this.curstate = state;
    });
  }
}
