//
//  FileDownloader.swift
//  tryUploadFile
//
//  Created by Abdurrahman Ibrahem Ghanem on 6/23/15.
//  Copyright (c) 2015 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation

protocol FileDownloaderDelegate {
    func fileDownloadFinished(success: Bool , fileContent content: String?)
    func fileListDownloadFinished(success: Bool , fileList list: [String]?)
}

public class FileDownloader {
    public typealias FileListCompletionHandler = (success: Bool? , list:[String]? , downloadFolder: String?) -> Void
    public typealias FileDownloadCompletionHandler = (success: Bool? , content:String?) -> Void
    var delegate: FileDownloaderDelegate? = nil
    
    func downloadFile (downloadFileURL fileURL: String, _ handler: FileDownloadCompletionHandler?) -> Void
    {
        let serverUrl = NSURL(string: fileURL)
        var request = NSMutableURLRequest(URL: serverUrl!)
        request.HTTPMethod = "POST"
                
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response, dataObject, error) in
            println(response)
            println(error)
            if let apiError = error {
                self.delegate?.fileDownloadFinished(false , fileContent: nil)
                handler?(success: false , content: nil)
            } else {
                let filesContent = NSString(data: dataObject , encoding: NSUTF8StringEncoding) as? String
                self.delegate?.fileDownloadFinished(true , fileContent: filesContent!)
                handler?(success: true , content: filesContent)
            }})
    }
    
    func getListOfFiles (serverDirectory: String , inFolder folder:String , _ handler: FileListCompletionHandler?) -> Void
    {
        let serverUrl = NSURL(string: serverDirectory)
        var request = NSMutableURLRequest(URL: serverUrl!)
        request.HTTPMethod = "POST"
        request.HTTPBody = "folderName=\(folder)".dataUsingEncoding(NSUTF8StringEncoding)
                
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response, dataObject, error) in
            println(response)
            println(error)
            if let apiError = error {
                self.delegate?.fileListDownloadFinished(false , fileList: nil)
                handler?(success: false , list: nil , downloadFolder: nil)
            } else {
                var fileArray = NSString(data: dataObject, encoding: NSUTF8StringEncoding)?.componentsSeparatedByString(",") as? [String]
                self.delegate?.fileListDownloadFinished(true , fileList: fileArray)
                let filesDirectory = fileArray?.removeLast()
                handler?(success: true , list: fileArray , downloadFolder: filesDirectory)
            }})
    }
    
    func getFilesURLs(filesList: [String] , serverAddress server: String , serverSubdirectory directory: String) -> [String]
    {
        return filesList.map{
            (file) -> String in
            return "\(server)/\(directory)\(file)"
        }
    }
}