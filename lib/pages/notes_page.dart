import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whiteboard/whiteboard.dart';

void main() {
  runApp(NotesApp());
}

class NotesApp extends StatefulWidget {
  @override
  _NotesAppState createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  @override
  void initState() {
    super.initState();
  }

  WhiteBoardController whiteBoardController = WhiteBoardController();
  bool isVisible = true;
  int i = 0;
  bool erasing = false;
  int paletteColorIndex = 0;
  int strokeSizeIndex = 0;
  List<Color> palette = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.pink,
    Colors.black,
  ];
  List<double> stroke = [
    4.0,
    7.0,
    10.0,
  ];

  void paletteColorChange() {
    setState(() {
      if (paletteColorIndex < 6) {
        paletteColorIndex++;
      } else {
        paletteColorIndex = 0;
      }
    });
  }

  void pencilStrokeChange() {
    setState(() {
      if (strokeSizeIndex < 2) {
        strokeSizeIndex++;
      } else {
        strokeSizeIndex = 0;
      }
    });
  }

  void erase() {
    setState(() {
      erasing = !erasing;
    });
  }

  GlobalKey _globalkey = GlobalKey();
  Future<void> save() async {
    final RenderRepaintBoundary boundary =
        _globalkey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    //Request Permissions
    if (!(await Permission.storage.status.isGranted))
      await Permission.storage.request();

    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(pngBytes),
        quality: 90,
        name: ("canvas$i"));
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black54,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Notes'),
              Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: "Save",
                  onPressed: () {
                    setState(() {
                      i = i + 1;
                      save();
                    });
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.save,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage(
            //     'assets/fourlines.png',
            //   ),
            //   fit: BoxFit.fill,
            // ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Flexible(
                    child: RepaintBoundary(
                      key: _globalkey,
                      child: WhiteBoard(
                        backgroundColor: Colors.transparent,
                        controller: whiteBoardController,
                        isErasing: erasing,
                        onConvertImage: (value) {},
                        strokeColor: palette[paletteColorIndex],
                        strokeWidth: stroke[strokeSizeIndex],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 150,
                right: 3,
                child: Container(
                  width: 20,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        isVisible = !isVisible;
                      });
                    },
                    icon: Icon(
                      Icons.arrow_right,
                    ),
                    color: Colors.white,
                  ),
                ),
              ),
              AnimatedPositioned(
                curve: Curves.fastOutSlowIn,
                duration: Duration(milliseconds: 500),
                right: isVisible ? 10 : -80,
                top: 20,
                child: Container(
                  margin: EdgeInsets.all(8),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      //1
                      Container(
                        // margin: EdgeInsets.only(left: 15),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.transparent,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (erasing == true) {
                                  erase();
                                } else {
                                  pencilStrokeChange();
                                }
                              },
                              child: FaIcon(
                                FontAwesomeIcons.pencilAlt,
                                color: Colors.grey[850],
                                size: 16 + stroke[strokeSizeIndex],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            //2
                            GestureDetector(
                              onTap: () {
                                paletteColorChange();
                              },
                              child: FaIcon(
                                FontAwesomeIcons.palette,
                                color: palette[paletteColorIndex],
                                size: 25,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            //3
                            GestureDetector(
                              onTap: () {
                                erase();
                              },
                              child: FaIcon(
                                FontAwesomeIcons.eraser,
                                color: Colors.green,
                                size: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      //4
                      Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              tooltip: "Undo",
                              onPressed: () {
                                whiteBoardController.undo();
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.undo,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              tooltip: "Redo",
                              onPressed: () {
                                whiteBoardController.redo();
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.redo,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              tooltip: "Clear",
                              onPressed: () {
                                whiteBoardController.clear();
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.timesCircle,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
