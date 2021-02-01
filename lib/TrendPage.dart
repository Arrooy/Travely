import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:travely/HashtagBar.dart';

class TrendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Pressed page");
      },
      child: Stack(
        children: [
        Container(
        height: double.infinity,
        width: double.infinity,
          child:
          Image.network("https://qtxasset.com/travelagentcentral/1581619297/shutterstock_1067855027.jpg/shutterstock_1067855027.jpg?99r3CQxfs0jWE48ix6vqYM1Cp15PhnkQ",
          fit: BoxFit.cover,)),

          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  alignment: Alignment.centerRight,
                  child: IconButton(
                      icon: Icon(Icons.star_border),
                      tooltip: "Add to favorites",
                      onPressed: () {
                        print("Fav button pressed.");
                      }),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Text(
                              "Puerto Rico",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 54),
                            ),
                            Text(
                              "120€",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 42),
                            )
                          ]),

                      Text("Monday, 27/02",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
                      HashtagBar(["Adventure", "Food", "Night fun", "Impresive"], true),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
