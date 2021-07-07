import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_merger/pdf_merge_response.dart';

class PdfMerger {
  static const MethodChannel _channel = const MethodChannel('pdf_merger');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<PdfMergeResponse> mergeMultiplePDF(
      {@required List<String> paths, @required String outputDirPath}) async {
    final pdfMergeResponse = PdfMergeResponse();

    final Map<String, dynamic> params = <String, dynamic>{
      'paths': paths,
      'outputDirPath': outputDirPath
    };

    if (paths.length == 0 || paths.length < 2) {
      pdfMergeResponse.status = false;
      pdfMergeResponse.message = 'Select minimum 2 Pdf for merge';
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
            pdfMergeResponse.status = false;
            pdfMergeResponse.message = 'Error in processing. Try again';
          } else {
            pdfMergeResponse.status = true;
            pdfMergeResponse.message = 'Pdf merge successfully';
            pdfMergeResponse.response = response;
          }
        } else {
          pdfMergeResponse.status = false;
          pdfMergeResponse.message = 'Select pdf files';
        }
      } on Exception catch (exception) {
        pdfMergeResponse.status = false;
        pdfMergeResponse.message = exception.toString();
      } catch (e) {
        pdfMergeResponse.status = false;
        pdfMergeResponse.message = e.toString();
      }
    }
    return pdfMergeResponse;
  }
}
