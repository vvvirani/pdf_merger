import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_merger/pdf_merge_args.dart';
import 'package:pdf_merger/pdf_split_args.dart';

class PdfMerger {
  static const MethodChannel _channel = const MethodChannel('pdf_merger');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  // PDF Merger
  static Future<PdfMergeResult> mergeMultiplePDF(
      {@required List<String> paths, @required String outputDirPath}) async {
    final pdfMergeResult = PdfMergeResult();

    final Map<String, dynamic> params = <String, dynamic>{
      'paths': paths,
      'outputDirPath': outputDirPath
    };

    if (paths.length == 0 || paths.length < 2) {
      pdfMergeResult.status = false;
      pdfMergeResult.message = 'Select minimum 2 Pdf for merge';
    } else {
      try {
        bool isPDF = true;

        for (int i = 0; i < paths.length; i++) {
          if (!paths[i].endsWith('.pdf')) {
            isPDF = false;
          }
        }

        if (isPDF) {
          final String response =
              await _channel.invokeMethod('mergeMultiplePDF', params);
          if (response == 'error') {
            pdfMergeResult.status = false;
            pdfMergeResult.message = 'Error in processing. Try again';
          } else {
            pdfMergeResult.status = true;
            pdfMergeResult.message = 'Pdf merge successfully';
            pdfMergeResult.result = response;
          }
        } else {
          pdfMergeResult.status = false;
          pdfMergeResult.message = 'Select pdf files';
        }
      } on Exception catch (exception) {
        pdfMergeResult.status = false;
        pdfMergeResult.message = exception.toString();
      } catch (e) {
        pdfMergeResult.status = false;
        pdfMergeResult.message = e.toString();
      }
    }
    return pdfMergeResult;
  }

  // PDF Split
  static Future<PdfSplitResult> splitPDF(PdfSplitArgs args) async {
    Map<dynamic, dynamic> result =
        await _channel.invokeMethod('splitPDF', args.toMap);
    return PdfSplitResult(result);
  }
}
