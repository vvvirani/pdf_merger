class PdfMergeResult {
  bool status;
  String message;
  String result;

  PdfMergeResult({this.status, this.message, this.result});

  Map get toMap => {
        'status': status,
        'message': message,
        'result': result,
      };
}
