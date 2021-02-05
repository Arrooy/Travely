import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:travely/HashtagBar.dart';
import 'package:travely/ui_utils.dart';

import 'model/Booking.dart';


// Permet mostrar la informació d'un booking en concret.
class TrendPagePreview extends StatefulWidget {
  final Booking booking;
  TrendPagePreview(this.booking);

  @override
  _TrendPagePreviewState createState() => _TrendPagePreviewState();
}

class _TrendPagePreviewState extends State<TrendPagePreview> {
  @override
  Widget build(BuildContext context) {
    // Es soliciten les dades de la preview
    widget.booking.requestImage(context);
    widget.booking.requestHashtags();
    widget.booking.updateFavFromFirebase(context);

    return GestureDetector(
        onDoubleTap: () {
          Provider.of<TrendingsModel>(context, listen: false).favButton(context,bk: widget.booking);
          setState((){});
        },
        child: Scaffold(
          appBar: AppBar(),
          body: Stack(
            children: [
              Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: FutureBuilder<Uint8List>(
                      future: widget.booking.image,
                      builder: (context,snapshot){

                        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done){
                          return Image.memory(snapshot.data, fit: BoxFit.cover);
                        } else if (snapshot.hasError) {
                          return futureError("Image not available");
                        }

                        return futureLoading("Loading ${widget.booking.destination}");
                      })),

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
                          icon: widget.booking.fav ? Icon(Icons.star,color:Colors.yellowAccent,size: 32,) : Icon(Icons.star_border,size: 32),
                          tooltip: "Add to favorites",
                          onPressed: () {
                            Provider.of<TrendingsModel>(context, listen: false).favButton(context,bk: widget.booking);
                            setState((){});
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
                                Expanded(
                                  flex:6,
                                  child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Text(
                                        widget.booking.destination,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )),
                                ),
                                Expanded(
                                    flex:2,
                                    child:Container()
                                ),
                                Expanded(
                                  flex:2,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: Text(
                                        widget.booking.price.toString() + "€",

                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                )
                              ]),
                        Row(mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Expanded(
                            flex:8,
                            child: FittedBox(
                                fit: BoxFit.cover,
                                child: Text(widget.booking.departureTime != null ? widget.booking.departureTime : "",style: TextStyle(fontWeight: FontWeight.bold))
                            )),
                          Expanded(
                              flex:2,
                              child:Container()
                          )]),

                          FutureBuilder<List<String>>(
                              future: widget.booking.hashtags,
                              builder: (context,snapshot){
                                if (snapshot.hasData && snapshot.connectionState == ConnectionState.done){
                                  return HashtagBar(snapshot.data, true);
                                } else if (snapshot.hasError) {
                                  return futureError("Hashtags not available");
                                }
                                return futureInlineLoading(false);
                              })
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
  }
}
