import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:travely/TrendPagePreview.dart';
import 'package:travely/model/Booking.dart';
import 'package:travely/ui_utils.dart';
import 'package:travely/utils.dart';

import 'model/UserManager.dart';

/*
OLD ADRIA
  final int numElements = 20;
  PhotoGrid(key1):super(key:key1);

  @override
  Widget build(BuildContext context) {
    List<StaggeredTile> staggeredTiles = _generateRandomDistribution(numElements);
    List<Widget> tiles = _generateRandomImages(staggeredTiles);
    return Container(
        color: Theme.of(context).primaryColor,
        child: Column(children: [
          Expanded(child: ImageTile(tiles, staggeredTiles)),
        ]));
  }
 */
//TODO: Solicitar les fotos a google amb el size de la carta.

class PhotoGrid extends StatelessWidget {
  PhotoGrid(key1):super(key:key1);

  @override
  Widget build(BuildContext context) {
    String username = Provider.of<UserManager>(context, listen: false).email.split('@')[0];

    return StreamBuilder(
      stream: FirebaseDatabase.instance.reference().child('${username}/').onValue,
      builder: (context, snap) {
        if (snap.hasData && !snap.hasError && snap.data.snapshot.value!=null) {
          DataSnapshot snapshot = snap.data.snapshot;

          List<_TileInfo> _list = List<_TileInfo>();


          Map<String, dynamic> _rawdata = Map<String, dynamic>.from(snapshot.value);

          _rawdata.forEach((key, value) {

              _list.add(_TileInfo(
                  "${value['shortOrigin']}-${value['shortDestination']}",
                  key,
                  "${value['price']}€",
                  requestImageFromGoogle(value['destination'], context)
              ));
          });

          List<StaggeredTile> staggeredTiles = _generateRandomDistribution(_list.length);
          List<Widget> tiles = _generateRandomImages(staggeredTiles, _list);

          return snap.data.snapshot.value == null ?
          SizedBox()
              :
          PhotoGridContent(tiles, staggeredTiles);
        } else return Center(
            child: Text(
              'You have no favourite plans yet!',
              style: TextStyle(
                color: Colors.white70,
              ),
            )
        );
      },
    );
  }

  List<Widget> _generateRandomImages(List<StaggeredTile> staggeredTiles, List<_TileInfo> info) {
    List<Widget> tiles = List<Widget>();
    for (int i = 0; i < staggeredTiles.length; i++) {
      StaggeredTile st = staggeredTiles[i];
      int type = (st.crossAxisCellCount > 1) ? 3 : ((st.mainAxisCellCount > 1) ? 2 : 1);
      tiles.add(ImageTile(
          gridImage: info[i].image,
          type: type,
          name: info[i].name,
          price: info[i].price,
          id: info[i].id
      ));
    }
    return tiles;
  }

  List<List<bool>> _initialAvailabilityGrid(int n) {
    List<List<bool>> a = new List<List<bool>>();
    for (int i = 0; i < 4 * n; i++) {
      a.add(List<bool>());
      for (int j = 0; j < 4; j++) a[i].add(false);
    }
    return a;
  }

  int _getMaxWidth(List<List<bool>> avail) {
    for (int i = 0; i < avail.length; i++) {
      List<bool> row = avail[i];
      for (int j = 0; j < 4; j++)
        if (row[j] == false) {
          for (int k = j + 1; k < 4; k++) if (row[k] == true) return (k - j);
          return (4 - j);
        }
    }
    return 0;
  }

  void _updateAvailabilityMatrix(
      List<List<bool>> avail, int width, int height) {
    for (int i = 0; i < avail.length; i++)
      for (int j = 0; j < 4; j++)
        if (avail[i][j] == false) {
          for (int m = j; m < j + width; m++)
            for (int n = i; n < i + height; n++) avail[n][m] = true;
          return;
        }
  }

  List<StaggeredTile> _generateRandomDistribution(int N) {
    List<StaggeredTile> staggeredTiles = List<StaggeredTile>();
    List<List<bool>> avail = _initialAvailabilityGrid(N);
    for (int i = 0; i < N; i++) {
      int width = 1 + Random().nextInt(_getMaxWidth(avail));
      int height = 1 + Random().nextInt(3);
      _updateAvailabilityMatrix(avail, width, height);
      staggeredTiles.add(StaggeredTile.count(width, height));
    }
    return staggeredTiles;
  }
}

class PhotoGridContent extends StatelessWidget {
  final List<StaggeredTile> _staggeredTiles;
  final List<Widget> _tiles;
  const PhotoGridContent(this._tiles, this._staggeredTiles) : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: new StaggeredGridView.count(
          crossAxisCount: 4,
          staggeredTiles: _staggeredTiles,
          children: _tiles,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ));
  }
}

class ImageTile extends StatefulWidget {
  final gridImage;
  final int type;
  final String name;
  final String price;
  final String id;
  const ImageTile({this.gridImage, this.type, this.name, this.price, this.id});

  @override
  _ImageTileState createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0x00000000),
      elevation: 3.0,
      child: GestureDetector(
        onLongPress: () async{
          String username = Provider.of<UserManager>(context,listen: false).email.split('@')[0];

          var ref = FirebaseDatabase.instance.reference().child("$username/").child(widget.id);
          await ref.remove();

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if(mounted) setState(() {});
          });
        },
        onTap: (){
          // Implementació de la preview desde bookings. Al final no s'afegeix a l'entrega.
          // Booking bk = new Booking();
          // bk.destination = widget.name;
          // bk.price = int.parse(widget.price.substring(0,1));
          // bk.image = widget.gridImage;
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => TrendPagePreview(bk)),
          // );
        },
        child: Stack(children: [


                 FutureBuilder<Uint8List>(
            future: widget.gridImage,
            builder: (context,snapshot){

              if (snapshot.hasData && snapshot.connectionState == ConnectionState.done){
                return  Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(snapshot.data),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(const Radius.circular(10.0)),
                  ),
                );
              } else if (snapshot.hasError) {
                return futureError(snapshot.error,size: 10);
              }

              return futureInlineLoading(true,size: 10);
            }
          ),
         Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (this.widget.type != 3) ? Color.fromARGB(170, 0, 0, 0) : Colors.transparent,
                    Colors.transparent,
                    Color.fromARGB(170, 0, 0, 0)
                  ],
                ),
                borderRadius: BorderRadius.all(const Radius.circular(10.0)),
              ),
            ),
         // ),
          Align(
            alignment: (this.widget.type == 3) ? Alignment.bottomLeft : Alignment.topLeft,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  widget.name,
                  style: TextStyle(fontSize: (this.widget.type == 3) ? 17 : 13),
                )),
          ),
          Align(
            alignment: (this.widget.type == 2) ? Alignment.bottomLeft : Alignment.bottomRight,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  widget.price,
                  style: TextStyle(fontSize: (this.widget.type == 3) ? 17 : 15),
                )),
          ),
        ]),
      ),
    );
  }
}

class _TileInfo {
  final String name;
  final String id;
  final String price;
//  final String imageName;
  Future<Uint8List> image;

  _TileInfo(this.name,this.id, this.price, this.image);
}