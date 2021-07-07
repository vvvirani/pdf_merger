import Flutter
import UIKit
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
        } else if call.method == "getPlatformVersion" {
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
