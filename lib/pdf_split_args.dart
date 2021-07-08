class PdfSplitArgs {
  /// File path of the pdf to split
  final String filePath;

  /// Target directory to put files
  final String outDirectory;

  /// Prefix for each pdf page file, default value is 'page_'
  final String outFilePrefix;

  PdfSplitArgs(this.filePath, this.outDirectory, {this.outFilePrefix = 'page_'})
      : assert(filePath != null && outDirectory != null);

  Map get toMap => {
        'filePath': filePath,
        'outDirectory': outDirectory,
        'outFileNamePrefix': outFilePrefix,
      };
}

class PdfSplitResult {
  int pageCount;
  List<String> pagePaths;

  PdfSplitResult(Map result)
      : assert(result.containsKey('pageCount') &&
            result.containsKey('pagePaths') &&
            result['pagePaths'] is List) {
    this.pageCount = result['pageCount'];
    this.pagePaths = [];
    (result['pagePaths'] as List).forEach((path) {
      if (path is String) this.pagePaths.add(path);
    });
  }
}
