import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

class ConnectingScreen extends StatefulWidget {
  const ConnectingScreen({super.key});

  @override
  State<ConnectingScreen> createState() => _ConnectingScreenState();
}

class _ConnectingScreenState extends State<ConnectingScreen> {
  bool x = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey,)),
      ),
      body: Column(
        children:  <Widget> [
          const SizedBox(height: 50,),
          x == true 
          ? const Text('Connecting to Device' , style: TextStyle(fontSize: 35),)
          : const Text('Connected to Device' , style: TextStyle(fontSize: 35),),
          const SizedBox(height: 100,),
          const Center(child: SpinKitThreeBounce(color: Colors.green, size: 50,),),
          const SizedBox(height: 170,),
          Card(
          margin:const EdgeInsets.only(left: 35,right: 35) ,
          elevation: 5,
            child: Container(
              margin:const EdgeInsets.only(left: 20,right: 20) ,
              height: 75,
              child: const Center(child: Text('Place the phone as close to the target device as possible.',textAlign: TextAlign.center,)),))
     
      ]),),
    );
  }
}