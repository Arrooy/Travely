import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:travely/HashtagBar.dart';
import 'package:travely/ui_utils.dart';

import 'model/Booking.dart';

class TrendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Booking current = Provider.of<TrendingsModel>(context, listen: false).current;

    // Mostra l'imatge de end quan no hi han mes dades al model.
    if(current != null && current.isEnd != null && current.isEnd){

      return Image.network("https://cdn.dopl3r.com//media/memes_files/you-have-reached-the-end-of-the-internet-turn-around-mlcEK.jpg");
    }else{
      return GestureDetector(
        onDoubleTap: () {
          Provider.of<TrendingsModel>(context, listen: false).favButton(context);
        },
        child: Stack(
          children: [
            Container(
                height: double.infinity,
                width: double.infinity,


                child: Consumer<TrendingsModel>(builder: (ctx,m,c){

                  return FutureBuilder<Uint8List>(
                      future: m.current.image,
                      builder: (context,snapshot){

                        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done){
                          return Image.memory(snapshot.data, fit: BoxFit.cover);
                        } else if (snapshot.hasError) {
                          return futureError(snapshot.error);
                        }

                        return futureLoading("Loading the best image from ${m.current.destination}");
                      });
                },)),
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
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Consumer<TrendingsModel>(builder: (ctx,m,c){
                                return Expanded(
                                  flex:6,
                                  child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Text(
                                        m.current.destination,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )),
                                );
                              },),
                              Expanded(
                                  flex:2,
                                  child:Container()
                              ),
                              Consumer<TrendingsModel>(builder: (ctx,m,c){
                                return Expanded(
                                  flex:2,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: Text(
                                        m.current.price.toString() + "€",

                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                );
                              },)
                            ]),
                        Consumer<TrendingsModel>(builder: (ctx,m,c){
                          return Expanded(
                            flex:0,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: Text(m.current.departureTime,style: TextStyle(fontWeight: FontWeight.bold))
                            ),
                          );
                        },),

                        Consumer<TrendingsModel>(builder: (ctx,m,c){
                          return FutureBuilder<List<String>>(
                              future: m.current.hashtags,
                              builder: (context,snapshot){
                                if (snapshot.hasData && snapshot.connectionState == ConnectionState.done){
                                  return HashtagBar(snapshot.data, true);
                                } else if (snapshot.hasError) {
                                  return futureError(snapshot.error);
                                }
                                return futureInlineLoading(false);
                              });
                        },),

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
}
