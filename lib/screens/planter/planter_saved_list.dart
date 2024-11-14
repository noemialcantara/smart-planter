import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';

class SavedList extends StatelessWidget {
  SavedList({super.key});

  final List<String> items = [
    'Botanical Name',
    'Botanical Name',
    'Botanical Name',
    'Botanical Name',
    'Botanical Name',
    'Botanical Name',
    'Botanical Name',
    'Botanical Name',
    'Botanical Name',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackgroundColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Saved Lists",
            style: GoogleFonts.openSans(color: Colors.black)),
      ),
      body: _buildDisplayLists(context),
    );
  }

  _buildDisplayLists(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          tileColor: AppColors.white,
          title: Text(items[index],
              style: GoogleFonts.openSans(color: Colors.black)),
          subtitle:
              Text('23 items', style: GoogleFonts.openSans(color: Colors.black)),
          trailing: const Icon(Icons.chevron_right_sharp),
        );
      },
    );
  }
}
