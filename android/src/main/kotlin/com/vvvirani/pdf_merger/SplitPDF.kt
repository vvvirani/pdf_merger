package com.vvvirani.pdf_merger

import android.R.attr.path
import android.util.Log
import com.tom_roush.pdfbox.multipdf.Splitter
import com.tom_roush.pdfbox.pdmodel.PDDocument
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException


class SplitPDF(getResult: MethodChannel.Result) {

    private var result : MethodChannel.Result = getResult

    fun split(filePath: String?, outDirectory: String?, outFileNamePrefix: String?){
        if (filePath == null || outDirectory == null || outFileNamePrefix == null) {
            result.error("PDF_SPLIT", "Arguments must not be null", null);
        } else {
            // Verifying outDirectory existence
            val directory = File(outDirectory)
            if (!directory.isDirectory) {
                result.error("PDF_SPLIT", "outDirectory $outDirectory is not a directory", null)
            }
            // Loading an existing PDF document
            val file: File = File(filePath)
            var doc: PDDocument? = null
            try {
                doc = PDDocument.load(file)
            } catch (e: IOException) {
                e.printStackTrace()
                result.error("PDF_SPLIT", "Error loading $filePath", null)
            }

            // Instantiating Splitter class
            val splitter = Splitter()

            // splitting the pages of a PDF document
            var pages: List<PDDocument>? = null
            try {
                pages = splitter.split(doc)
            } catch (e: IOException) {
                e.printStackTrace()
                result.error("PDF_SPLIT", "Error splitting $path", null)
            }

            // Creating an iterator
            val iterator: Iterator<PDDocument> = pages!!.listIterator()

            // Saving each page as an individual document
            var i = 1
            val pagePaths: MutableList<String> = ArrayList()

            while (iterator.hasNext()) {
                val pd = iterator.next()
                val singlePageFileName = outDirectory.toString() + "/" + outFileNamePrefix + i++ + ".pdf"
                try {
                    pd.save(singlePageFileName)
                    Log.d("PDF_SPLIT", "onMethodCall: $singlePageFileName")
                    pd.close()
                    pagePaths.add(singlePageFileName)
                } catch (e: IOException) {
                    e.printStackTrace()
                    result.error("PDF_SPLIT", "Error saving $singlePageFileName", null)
                }
            }
            try {
                doc!!.close()
            } catch (e: IOException) {
                e.printStackTrace()
                result.error("PDF_SPLIT", "Error closing $path", null)
            }

            val splitResult: MutableMap<String, Any> = HashMap()
            splitResult["pageCount"] = pages.size
            splitResult["pagePaths"] = pagePaths

            result.success(splitResult)
        }
    }
}