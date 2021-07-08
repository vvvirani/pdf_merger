import Flutter
import UIKit
import PDFKit
import MobileCoreServices
import ImageIO
import AVFoundation

public class SwiftPdfMergerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "pdf_merger", binaryMessenger: registrar.messenger())
        let instance = SwiftPdfMergerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "mergeMultiplePDF" {

            if let args = call.arguments as? Dictionary<String, Any>{
                
                DispatchQueue.global().async {
                    let singlePDFFromMultiplePDF =  SwiftPdfMergerPlugin.mergeMultiplePDF(args : args)
                    DispatchQueue.main.sync {
                        result(singlePDFFromMultiplePDF)
                    }
                }
                
            } else {
                result("error")
            }
            
        } else if call.method == "splitPDF" {
            
            guard let args = call.arguments as! NSDictionary? else {
                return result(FlutterError(code: "RENDER_ERROR",
                                           message: "Arguments not sended",
                                           details: nil))
            }
            
            let pdfFilePath = args["filePath"] as! String
            let outDirectory = args["outDirectory"] as! String
            let outFileNamePrefix = args["outFileNamePrefix"] as! String
            
            if #available(iOS 11.0, *) {
                let url = NSURL.fileURL(withPath: pdfFilePath)
                if url.isFileURL {
                    let pdfDocument = PDFDocument(url: url)
                    
                    let pages = pdfDocument!.pageCount
                    var pagePaths = [String]()
                    
                    for index in 0...pages-1 {
                        let page = (pdfDocument?.page(at: index))!
                        let singlePageFilename = outDirectory + "/" + outFileNamePrefix + String(index) + ".pdf"
                        let singlePage = PDFDocument.init()
                        singlePage.insert(page, at: 0)
                        singlePage.write(toFile: singlePageFilename)
                        pagePaths.append(singlePageFilename)
                        print(singlePageFilename)
                    }
                    var splitResult = [String : Any]()
                    splitResult["pageCount"] = pages
                    splitResult["pagePaths"] = pagePaths
                    
                    result(splitResult)
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
            
            
        }else if call.method == "getPlatformVersion" {
            result("iOS " + UIDevice.current.systemVersion)
            
        } else{
            result("Not Implemented")
        }
    }
    
    
    class func mergeMultiplePDF(args: Dictionary<String, Any>) -> String? {
        
        do{
            
            if let paths = args["paths"] as? [String], let outputDirPath = args["outputDirPath"] as? String {
                
                guard UIGraphicsBeginPDFContextToFile(outputDirPath, CGRect.zero, nil) else {
                    return "error"
                }
                guard let destContext = UIGraphicsGetCurrentContext() else {
                    return "error"
                }
                
                
                for index in 0 ..< paths.count {
                    let pdfFile = paths[index]
                    let pdfUrl = NSURL(fileURLWithPath: pdfFile)
                    guard let pdfRef = CGPDFDocument(pdfUrl) else {
                        continue
                    }
                    
                    for i in 1 ... pdfRef.numberOfPages {
                        if let page = pdfRef.page(at: i) {
                            var mediaBox = page.getBoxRect(.mediaBox)
                            destContext.beginPage(mediaBox: &mediaBox)
                            destContext.drawPDFPage(page)
                            destContext.endPage()
                        }
                    }
                }
                
                
                destContext.closePDF()
                UIGraphicsEndPDFContext()
                
                return outputDirPath
            }
            
        }
        return "error"
    }
}
