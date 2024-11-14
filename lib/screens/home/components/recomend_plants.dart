import 'package:flutter/material.dart';
import 'package:hortijoy_mobile_app/screens/details/details_screen.dart';
import 'package:hortijoy_mobile_app/resources/measurements.dart';
import 'package:hortijoy_mobile_app/resources/colors.dart';

class RecomendsPlants extends StatelessWidget {
  const RecomendsPlants({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          RecomendPlantCard(
            image: "assets/images/image_1.png",
            title: "Asparagus Fern",
            country: "Status: Healthy",
            price: 0,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(),
                ),
              );
            },
          ),
          RecomendPlantCard(
            image: "assets/images/image_2.png",
            title: "Evergreen",
            country: "Status: Healthy",
            price: 440,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsScreen(),
                ),
              );
            },
          ),
          RecomendPlantCard(
            image: "assets/images/image_3.png",
            title: "Monstera",
            country: "Status: Critical",
            price: 440,
            press: () {},
          ),
        ],
      ),
    );
  }
}

class RecomendPlantCard extends StatelessWidget {
  const RecomendPlantCard({
    Key? key,
    required this.image,
    required this.title,
    required this.country,
    required this.price,
    required this.press,
  }) : super(key: key);

  final String image, title, country;
  final int price;
  final Function press;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
        left: Measurements.defaultPadding,
        top: Measurements.defaultPadding / 2,
        bottom: Measurements.defaultPadding * 2.5,
      ),
      width: size.width * 0.4,
      child: Column(
        children: <Widget>[
          Image.asset(image),
          GestureDetector(
            onTap: () {
              press();
            },
            child: Container(
              padding: EdgeInsets.all(Measurements.defaultPadding / 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 10),
                    blurRadius: 50,
                    color: country.contains("Critical")
                        ? Colors.red.withOpacity(0.23)
                        : AppColors.primaryColor.withOpacity(0.23),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "$title\n".toUpperCase(),
                    style: Theme.of(context).textTheme.button,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "$country".toUpperCase(),
                    style: TextStyle(
                      color: country.contains("Critical")
                          ? Colors.red.withOpacity(0.5)
                          : AppColors.primaryColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
