import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterbleplugin/flutterbleplugin.dart';

import 'BleInfo.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<BleInfo> bleInfoItems = [];
  bool _scanning = false;
  final Flutterbleplugin _bluetooth = Flutterbleplugin();

  @override
  void initState() {
    super.initState();
    _bluetooth.devices.listen((device) {
      setState(() {
        //remove duplicate device from list
        var list = bleInfoItems.where((i) => i.name == device.name).toList();
        if (list.isEmpty) {
          bleInfoItems.add(BleInfo(device.name, device.address,
              device.rssiDistance, device.rssiValue));
        }
      });
    });
    _bluetooth.scanStopped.listen((device) {
      setState(() {
        _scanning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Bluetooth',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          // isExtended: true,
          child: Icon(_scanning ? Icons.stop : Icons.bluetooth_searching),
          backgroundColor: Colors.green,
          onPressed: () async {
            try {
              if (_scanning) {
                await _bluetooth.stopScan();
                debugPrint("scanning stoped");
                setState(() {
                  bleInfoItems.clear();
                });
              } else {
                await _bluetooth.startScan(pairedDevices: false);
                debugPrint("scanning started");
                setState(() {
                  _scanning = true;
                });
              }
            } on PlatformException catch (e) {
              debugPrint(e.toString());
            }
          },
        ),
        body: bleInfoItems.length > 0
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: bleInfoItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    //color: Colors.white,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.white60, blurRadius: 1.0),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bleInfoItems[index].name!,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              bleInfoItems[index].address!,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Signal: ' +
                                  bleInfoItems[index].rssiValue! +
                                  ' dBm',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          getDynamicName(
                              double.parse(bleInfoItems[index].rssiDistance!)),
                          scale: 4,
                        )
                      ],
                    ),
                  );
                })
            : Center(
                child: Container(
                  child: Text("Device Not Available"),
                ),
              ),
      ),
    );
  }

  getDynamicName(double rssi) {
    if (rssi > 0.0 && rssi < 2.0) {
      return 'assets/wifi-4.png';
    } else if (rssi > 2.0 && rssi < 4.0) {
      return 'assets/wifi-3.png';
    } else if (rssi > 4.0 && rssi < 8.0) {
      return 'assets/wifi-2.png';
    } else {
      return 'assets/wifi-1.png';
    }
  }
}
