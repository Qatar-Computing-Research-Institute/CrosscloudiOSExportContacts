//
//  FileUploader.swift
//  tryUploadFile
//
//  Created by Abdurrahman Ibrahem Ghanem on 6/21/15.
//  Copyright (c) 2015 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation

public class FileUploader {
    public typealias CompletionHandler = (obj:AnyObject?, success: Bool?) -> Void
    
    public func UploadFile(serverURL: NSURL, filePath: NSURL, fileData:String? , fileName: String, _ aHandler: CompletionHandler?) -> Void {
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        let request = NSMutableURLRequest(URL: serverURL, cachePolicy: cachePolicy, timeoutInterval: 2.0)
        request.HTTPMethod = "POST"
        
        // Set Content-Type in HTTP header.
        let boundaryConstant = boundaryGenerator()//"Boundary-7MA4YWxkTLLu0UIW"; // This should be auto-generated.
        let contentType = "multipart/form-data; boundary=" + (boundaryConstant as String)
        
        let fileName = filePath.lastPathComponent!
        let mimeType = "text/txt"
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Set data
        var dataString = "--\(boundaryConstant)\r\n"
        dataString += "Content-Disposition: form-data; name=\"fileUpload\"; filename=\"\(fileName)\"\r\n"
        dataString += "Content-Type: \(mimeType)\r\n\r\n"
        
        var data:String? = fileData
        if data == nil
        {
            data = try? String(contentsOfFile: filePath.path!, encoding: NSUTF8StringEncoding)
            
            if data == nil
            {
                return
            }
        }
        
        dataString += data!
        dataString += "\r\n"
        dataString += "--\(boundaryConstant)--\r\n"
        
        print(dataString) // This would allow you to see what the dataString looks like.
        
        // Set the HTTPBody we'd like to submit
        let requestBodyData = (dataString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = requestBodyData
        
        // Make an asynchronous call so as not to hold up other processes.
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(request , completionHandler: {
            
            (data , response , error) -> Void in
            
            if let res = response as? NSHTTPURLResponse
            {
                print("status code: " + String(res.statusCode))
                print("data is: " + String(data: data! , encoding: NSUTF8StringEncoding)!)
            }
            
            if let _ = error {
                aHandler?(obj: error, success: false)
            } else {
                aHandler?(obj: data, success: true)
            }
            
        })
        
        task.resume()
    }
    
    public func UploadData(serverURL: NSURL, filePath: NSURL, fileData:NSData? , fileName: String, _ aHandler: CompletionHandler?) -> Void {
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        let request = NSMutableURLRequest(URL: serverURL, cachePolicy: cachePolicy, timeoutInterval: 2.0)
        request.HTTPMethod = "POST"
        
        // Set Content-Type in HTTP header.
        let boundaryConstant = boundaryGenerator()//"Boundary-7MA4YWxkTLLu0UIW"; // This should be auto-generated.
        let contentType = "multipart/form-data; boundary=" + (boundaryConstant as String)
        
        let fileName = filePath.lastPathComponent!
        let mimeType = "text/txt"
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Set data
        let mutableData = NSMutableData();
        var dataString = "--\(boundaryConstant)\r\n"
        dataString += "Content-Disposition: form-data; name=\"fileUpload\"; filename=\"\(fileName)\"\r\n"
        dataString += "Content-Type: \(mimeType)\r\n\r\n"
        
        mutableData.appendData((dataString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        
        var data = fileData
        if data == nil
        {
            do {
                data = NSData(contentsOfFile: fileName)
            }catch
            {
                
            }
            
            if data == nil
            {
                return
            }
        }
        
        mutableData.appendData(data!)
//        dataString += data!
        dataString = "\r\n"
        dataString += "--\(boundaryConstant)--\r\n"
        
        mutableData.appendData((dataString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!)
        
//        print(dataString) // This would allow you to see what the dataString looks like.
        
        // Set the HTTPBody we'd like to submit
        let requestBodyData = mutableData
        request.HTTPBody = requestBodyData
        
        // Make an asynchronous call so as not to hold up other processes.
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let task = session.dataTaskWithRequest(request , completionHandler: {
            
            (data , response , error) -> Void in
            
            if let res = response as? NSHTTPURLResponse
            {
                print("status code: " + String(res.statusCode))
                print("data is: " + String(data: data! , encoding: NSUTF8StringEncoding)!)
            }
            
            if let _ = error {
                aHandler?(obj: error, success: false)
            } else {
                aHandler?(obj: data, success: true)
            }
            
        })
        
        task.resume()
    }
    
    private func boundaryGenerator() -> NSString
    {
        var boundary = ""
        var nHyphens = random() % 10
        
        //generate hyphens in the beginning
        for _ in 3...(3 + nHyphens)
        {
            boundary += "-"
        }
        
        let charCount = random() % 16
        
        for _ in 10...(10 + charCount)
        {
            let isUppercase = random() % 2
            
            var us = "a".unicodeScalars
            
            if isUppercase == 0
            {
                us = "A".unicodeScalars
            }
            
            let asciiValue =  us[us.startIndex].value + UInt32(rand() % 26)
            let char = UnicodeScalar(asciiValue)
            boundary += "\(Character(char))"
            
            print("\(Character(char))")
        }
        
        //generate huphens in the end
        nHyphens = random() % 8
        
        for _ in 2...(2 + nHyphens)
        {
            boundary += "-"
        }
        
        return boundary
    }
}
