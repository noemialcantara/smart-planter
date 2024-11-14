import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class NotificationCardWidget extends StatefulWidget {
  const NotificationCardWidget({
    Key? key,
    required this.index,
    required this.data,
  }) : super(key: key);

  final int index;
  final String data;

  @override
  _NotificationCardWidgetState createState() => _NotificationCardWidgetState();
}

class _NotificationCardWidgetState extends State<NotificationCardWidget> {
  bool isRead = false;

  @override
  void initState() {
    super.initState();
    _checkIfRead();
  }

  Future<void> _checkIfRead() async {
    var emailID = await FirebaseFirestore.instance
        .collection("notifications")
        .where("title", isEqualTo: widget.data.split("...")[0])
        .where("subtitle", isEqualTo: widget.data.split("...")[1])
        .where("email",
            isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
        .where("datetime_added", isEqualTo: widget.data.split("...")[2])
        .limit(1)
        .get();

    if (emailID.docs.isNotEmpty) {
      var doc = emailID.docs.first;
      setState(() {
        isRead = doc["is_read"] ?? false;
      });
    }
  }

  Future<void> _markAsRead(bool readStatus) async {
    print("TITLE: " + widget.data.split("...")[1]);
    var emailID = await FirebaseFirestore.instance
        .collection("notifications")
        .where("title", isEqualTo: widget.data.split("...")[0])
        .where("subtitle", isEqualTo: widget.data.split("...")[1])
        .where("email",
            isEqualTo: FirebaseAuth.instance.currentUser?.email.toString())
        .where("datetime_added",
            isEqualTo: widget.data.split("...")[2][0] == "."
                ? widget.data.split("...")[2].substring(1)
                : widget.data.split("...")[2])
        .limit(1)
        .get();

    if (emailID.docs.isNotEmpty) {
      var userUID = emailID.docs.first.id;
      await FirebaseFirestore.instance
          .collection("notifications")
          .doc(userUID)
          .update({"is_read": readStatus});
      setState(() {
        isRead = readStatus;
      });
    }
  }

  String timeAgo(String dateTimeString) {
    DateTime pastTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateTimeString);
    Duration difference = DateTime.now().difference(pastTime);

    if (difference.inSeconds < 60) {
      return "${difference.inSeconds} sec ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hour ago";
    } else if (difference.inDays < 31) {
      return "${difference.inDays} days ago";
    } else if (difference.inDays < 365) {
      int months = difference.inDays ~/ 30;
      return "${months} months ago";
    } else {
      int years = difference.inDays ~/ 365;
      return "${years} years ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        _showDetailDialog(context);
      },
      child: Container(
        margin: EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: isRead ? AppColors.white : Color(0xFFFFF9C4),
          borderRadius: BorderRadius.circular(10),
        ),
        height: 120.0,
        padding: const EdgeInsets.only(top: 30, bottom: 30),
        width: size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEBEDEB),
              ),
              child: Icon(Icons.bookmark_outline,
                  size: 35, color: AppColors.primaryColor),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.split("...")[0] ?? "No title",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.data.split("...")[1] ?? "No data",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      timeAgo(widget.data.split("...")[2][0] == "."
                              ? widget.data.split("...")[2].substring(1)
                              : widget.data.split("...")[2]) ??
                          "1 day ago",
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.more_horiz,
                color: Colors.black,
              ),
              onPressed: () {
                _showModalBottomSheet(context);
              },
            )
          ],
        ),
      ),
    );
  }

  _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 280.0,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(8.0),
                width: 50,
                height: 7,
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: ListTile(
                        leading: Image.asset("assets/icons/mark_as_read.png"),
                        title: Text(isRead ? "Mark as unread" : "Mark as read"),
                        onTap: () async {
                          await _markAsRead(!isRead);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: ListTile(
                        leading: Image.asset("assets/icons/share_icon.png"),
                        title: Text("Share"),
                        onTap: () async {
                          final box = context.findRenderObject() as RenderBox?;
                          String title = widget.data.split("...")[0];
                          String description = widget.data.split("...")[1];

                          await Share.share(
                            '$title\n\n$description',
                            sharePositionOrigin:
                                box!.localToGlobal(Offset.zero) & box.size,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: ListTile(
                        leading: Image.asset("assets/icons/Remove_icon.png"),
                        title: Text("Remove"),
                        onTap: () async {
                          var emailID = await FirebaseFirestore.instance
                              .collection("notifications")
                              .where("title",
                                  isEqualTo: widget.data.split("...")[0])
                              .where("subtitle",
                                  isEqualTo: widget.data.split("...")[1])
                              .where("email",
                                  isEqualTo: FirebaseAuth
                                      .instance.currentUser?.email
                                      .toString())
                              .where("datetime_added",
                                  isEqualTo: widget.data.split("...")[2])
                              .limit(1)
                              .get();
                          var userUID = emailID.docs.first.id;

                          FirebaseFirestore.instance
                              .collection("notifications")
                              .doc(userUID)
                              .delete();

                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.data.split("...")[0] ?? "No title"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(widget.data.split("...")[1] ?? "No description"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
