import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_merger/pdf_merger.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> filesPath = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              child: Text('Select Pdf file'),
              onPressed: () async {
                FilePickerResult result =
                    await FilePicker.platform.pickFiles(allowMultiple: true);

                if (result != null) {
                  setState(() {
                    if (Platform.isAndroid) {
                      filesPath =
                          result.paths.map((path) => File(path).path).toList();
                    } else {
                      filesPath.addAll(
                          result.paths.map((path) => File(path).path).toList());
                    }
                  });
                }
              },
            ),
            ...filesPath
                .map((path) => Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(path),
                    ))
                .toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          String outputDirPath =
              await createDirectory('MergePdf') + '/test_merge.pdf';

          var result = await PdfMerger.mergeMultiplePDF(
              paths: filesPath, outputDirPath: outputDirPath);

          print(result.status);
          print(result.message);
          print(result.response);
        },
      ),
    );
  }

  Future<String> getFilePath() async {
    Directory directory;

    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      String newPath = '';
      List<String> folders = directory.path.split('/');
      for (int i = 1; i < folders.length; i++) {
        String folder = folders[i];
        if (folder != 'Android') {
          newPath += '/' + folder;
        } else {
          break;
        }
      }
      return newPath;
    } else {
      directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<String> createDirectory(String directoryName) async {
    String path = await getFilePath() + '/$directoryName';
    Directory directory = Directory(path);
    if (!await directory.exists()) {
      directory.createSync(recursive: true);
    }
    return directory.path;
  }
}
