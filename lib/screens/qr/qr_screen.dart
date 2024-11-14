import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';


class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
int _currentIndex = 0;


   
  @override
  Widget build(BuildContext context) {
    return  SafeArea(child:  Scaffold(
      appBar: AppBar(
        actions: <Widget>[  
          PopupMenuButton(
                   shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                   icon: const Icon(Icons.notifications_none, color: Colors.black,),
                   itemBuilder: (context){
                     return [
                            const PopupMenuItem<int>(
                                value: 0,
                                child: Text("Notification"),
                            ),
                        ];
                   },
                   onSelected:(value){
                      if(value == 0){
                         print("Show notification");
                      }
                   }
                  ),
              PopupMenuButton(
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                   icon: const Icon(Icons.add,color: Colors.black),
                   itemBuilder: (context){
                     return [
                            const PopupMenuItem<int>(
                                value: 0,
                                child: Text("Add device"),
                            ),

                            const PopupMenuItem<int>(
                                value: 1,
                                child: Text("Scan"),
                            ),
                              const PopupMenuItem<int>(
                                value: 2,
                                child: Text("Upload QR"),
                            ),
                        ];
                   },
                   onSelected:(value){
                      if(value == 0){
                         print("Add device");
                      }else if(value == 1){
                        scanQR();
                      }
                   }
                  ),
                  
        ],
      ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int newIndex){
            setState(() {
              _currentIndex = newIndex;
            });
          },
          items: const [
          BottomNavigationBarItem(label: 'Device',icon: Icon(Icons.smartphone)),
          BottomNavigationBarItem(label: 'Authentication',icon: Icon(Icons.key)),
          BottomNavigationBarItem(label: 'Profile',icon: Icon(Icons.emoji_emotions))
        ],),
    ));
  }
  
Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', false, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
  }


}