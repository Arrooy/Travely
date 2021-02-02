import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math';

class PhotoGrid extends StatelessWidget {
  List<Widget> _tiles = const <Widget>[
    const _ImageTile('https://picsum.photos/200/300/?random'),
    const _ImageTile('https://picsum.photos/201/300/?random'),
    const _ImageTile('https://picsum.photos/202/300/?random'),
    const _ImageTile('https://picsum.photos/203/300/?random'),
    const _ImageTile('https://picsum.photos/204/300/?random'),
    const _ImageTile('https://picsum.photos/205/300/?random'),
    const _ImageTile('https://picsum.photos/206/300/?random'),
    const _ImageTile('https://picsum.photos/209/300/?random'),
    const _ImageTile('https://picsum.photos/207/300/?random'),
    const _ImageTile('https://picsum.photos/208/300/?random'),
  ];

  @override
  Widget build(BuildContext context) {
    return ImageTile(_tiles, _generateRandomDistribution(10));
  }

  List<List<bool>> _initialAvailabilityGrid(int n) {
    List<List<bool>> a = new List<List<bool>>();
    for (int i = 0; i < 4*n; i++) {
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
          for (int k = j+1; k < 4; k++)
            if (row[k] == true) return (k - j);
          return (4 - j);
        }
    }
    return 0;
  }

  void _updateAvailabilityMatrix(List<List<bool>> avail, int width, int height) {
    for (int i = 0; i < avail.length; i++)
      for (int j = 0; j < 4; j++)
        if (avail[i][j] == false) {
          for (int m = j; m < j + width; m++) for (int n = i; n < i + height; n++)
            avail[n][m] = true;
          return;
        }
  }

  List<StaggeredTile> _generateRandomDistribution(int N) {
    List<StaggeredTile> _staggeredTiles = List<StaggeredTile>();
    List<List<bool>> avail = _initialAvailabilityGrid(N);
    for (int i = 0; i < N; i++) {
      int width = 1+Random().nextInt(_getMaxWidth(avail));
      int height = 1+Random().nextInt(3);
      _updateAvailabilityMatrix(avail, width, height);
      _staggeredTiles.add(StaggeredTile.count(width, height));
    }
    return _staggeredTiles;
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
  const _ImageTile(this.gridImage);

  @override
  Widget build(BuildContext context) {
    return new Card(
      color: const Color(0x00000000),
      elevation: 3.0,
      child: new GestureDetector(
        onTap: () {
          print("hello");
        },
        child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new NetworkImage(gridImage),
                fit: BoxFit.cover,
              ),
              borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
            )
        ),
      ),
    );
  }
}