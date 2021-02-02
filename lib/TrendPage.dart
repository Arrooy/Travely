import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:travely/HashtagBar.dart';

import 'model/Booking.dart';

class TrendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        Provider.of<TrendingsModel>(context, listen: false).favButton(context);
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
                      icon: Consumer<TrendingsModel>(builder: (ctx,m,c){
                        return m.current.fav ? Icon(Icons.star,color:Colors.yellowAccent,size: 32,) : Icon(Icons.star_border,size: 32);
                      },),
                      tooltip: "Add to favorites",
                      onPressed: () {
                        Provider.of<TrendingsModel>(context, listen: false).favButton(context);
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
                            Consumer<TrendingsModel>(builder: (ctx,m,c){
                              return Text(
                                m.current.destination,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 54),
                              );
                            },),
                            Consumer<TrendingsModel>(builder: (ctx,m,c){
                              return Text(
                                m.current.price.toString() + "€",

                                textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 42)
                              );
                            },)
                          ]),
                      Consumer<TrendingsModel>(builder: (ctx,m,c){

                        return Text(m.current.departureTime.toString(),style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32));

                      },),

                      HashtagBar(Provider.of<TrendingsModel>(context,listen:false).current.hashtags, true),
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
