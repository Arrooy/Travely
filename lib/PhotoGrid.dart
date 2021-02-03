import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import 'model/UserManager.dart';

class PhotoGrid extends StatelessWidget {
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
          _rawdata.forEach((key, value) =>
              _list.add(_TileInfo(
                  "${value['shortOrigin']}-${value['shortDestination']}",
                  "${value['price']}€",
                  value['image']
              )));

          List<StaggeredTile> staggeredTiles = _generateRandomDistribution(_list.length);
          List<Widget> tiles = _generateRandomImages(staggeredTiles, _list);

          return snap.data.snapshot.value == null ?
          SizedBox()
              :
          ImageTile(tiles, staggeredTiles);
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
      tiles.add(_ImageTile(
          gridImage: info[i].image,
          type: type,
          name: info[i].name,
          price: info[i].price
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

class ImageTile extends StatelessWidget {
  final List<StaggeredTile> _staggeredTiles;
  final List<Widget> _tiles;
  const ImageTile(this._tiles, this._staggeredTiles) : super();

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

class _ImageTile extends StatelessWidget {
  final gridImage;
  final int type;
  final String name;
  final String price;
  const _ImageTile({this.gridImage, this.type, this.name, this.price});

  @override
  Widget build(BuildContext context) {
    return new Card(
      color: const Color(0x00000000),
      elevation: 3.0,
      child: GestureDetector(
        onTap: () {
          print("hello");
        },
        child: Stack(children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(gridImage),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(const Radius.circular(10.0)),
            ),
          ),
         Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (this.type != 3) ? Color.fromARGB(170, 0, 0, 0) : Colors.transparent,
                    Colors.transparent,
                    Color.fromARGB(170, 0, 0, 0)
                  ],
                ),
                borderRadius: BorderRadius.all(const Radius.circular(10.0)),
              ),
            ),
         // ),
          Align(
            alignment: (this.type == 3) ? Alignment.bottomLeft : Alignment.topLeft,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  name,
                  style: TextStyle(fontSize: (this.type == 3) ? 17 : 13),
                )),
          ),
          Align(
            alignment: (this.type == 2) ? Alignment.bottomLeft : Alignment.bottomRight,
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  price,
                  style: TextStyle(fontSize: (this.type == 3) ? 17 : 15),
                )),
          ),
        ]),
      ),
    );
  }
}

class _TileInfo {
  final String name;
  final String price;
  final String image;
  _TileInfo(this.name, this.price, this.image);
}