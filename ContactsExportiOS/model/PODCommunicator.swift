//
//  PODCommunicator.swift
//  ContactsExportiOS
//
//  Created by Abdurrahman Ibrahem Ghanem on 12/30/15.
//  Copyright © 2015 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation

typealias ResponseCallback = (success: Bool , statusCode: String? , data: NSData? , error: NSError?) -> Void

class PODCommunicator: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate
{
    let podURL: String
    let containerPath: String
    let requestsExecQueue = NSOperationQueue()
    
    init(podURL: String , containerPath: String)
    {
        self.podURL = podURL
        self.containerPath = containerPath
    }
    
    // Http methods implementation
    func sendPost(resourceName: String , data: NSData? , responseCallback: ResponseCallback)
    {
        
    }
    
    func sendGet(resourceName: String , data: NSData? , responseCallback: ResponseCallback)
    {
        
    }
    
    func sendPut(resourceName: String , data: NSData , responseCAllback: ResponseCallback)
    {
        if let request = self.giveMeHttpRequestObject(resourceName)
        {
//            request.HTTPMethod = "PUT"
//            request.setValue("\(data.length)" , forHTTPHeaderField: "Content-Length")
//            request.setValue("text/turtle;charset=utf-8" , forHTTPHeaderField: "Content-Type")
//            request.setValue("<http://www.w3.org/ns/ldp#Resource>; rel=\"type\"", forHTTPHeaderField: "Link")
//            request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:43.0) Gecko/20100101 Firefox/43.0" , forHTTPHeaderField: "User-Agent")

            request.HTTPMethod = "GET"
//            request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" , forHTTPHeaderField: "Accept")
//            request.setValue("gzip, deflate, sdch" , forHTTPHeaderField: "Accept-Encoding")
//            request.setValue("en-US,en;q=0.8", forHTTPHeaderField: "Accept-Language")
//            request.setValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
//            request.setValue("http://linkeddata.github.io/warp/", forHTTPHeaderField: "Referer")
//            request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36" , forHTTPHeaderField: "User-Agent")            
            
            
            let putSession = NSURLSession(configuration: self.setupSessionConfiguration(), delegate: self , delegateQueue: self.requestsExecQueue)
//            let task = putSession.dataTaskWithRequest(request , completionHandler:
//            { (data , response , error) -> Void in 
//                
//                var responseCode:String?
//                
//                if let httpResponse = response as? NSHTTPURLResponse
//                {
//                    responseCode = String(httpResponse.statusCode)
//                }
//                
//                print("response is \(responseCode) error is \(error?.description)")
//                
//                responseCAllback(success: error == nil , statusCode: responseCode , data: data , error: error)
//                
//                if error == nil         //success
//                {
//                    
//                }
//                else                    //failed
//                {
//                    
//                }
//            })
            
            let task = putSession.dataTaskWithURL(NSURL(string: "https://www.exportcontactsios.rww.io/Work/contacts/vCard_0")!)
                { (data , response , error) -> Void in 
                    
                    var responseCode:String?
                    
                    if let httpResponse = response as? NSHTTPURLResponse
                    {
                        responseCode = String(httpResponse.statusCode)
                    }
                    
                    print("response is \(responseCode) error \(error?.description)")
                    
                    responseCAllback(success: error == nil , statusCode: responseCode , data: data , error: error)
                    
                    if error == nil         //success
                    {
                        
                    }
                    else                    //failed
                    {
                        
                    }
            }

            
            task.resume()
        }
    }
    
    func sendDelete(resourceName: String , data: NSData?, responseCallback: ResponseCallback)
    {
        
    }
    
    
    //construct an http request object with the pod url which points to the container
    func giveMeHttpRequestObject(resourceName: String) -> NSMutableURLRequest?
    {
        let fullPath = "https://exportcontactsios.rww.io/Work/contacts/vCard_0"//self.podURL + "/" + self.containerPath + "/" + resourceName
        
        if let url = NSURL(string: fullPath)
        {
            let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy , timeoutInterval: Globals.requestTimeoutInterval)
            
            return request
        }
        
        return nil
    }
    
    //MARK: NSURLSessionDelegate
    
    func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) 
    {
        let identityAndTrust:IdentityAndTrust? = self.extractIdentity("certificate" , certExt: "p12" , certPassword: "rww.io");
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate && identityAndTrust != nil
        {
            let urlCredential:NSURLCredential = NSURLCredential(
                identity: identityAndTrust!.identityRef,
                certificates: identityAndTrust!.certArray as [AnyObject],
                persistence: NSURLCredentialPersistence.ForSession);
            
//            print("Identity: \(urlCredential.identity.debugDescription)")
//            print("certificates: \(urlCredential.certificates.debugDescription)")
            
            challenge.sender?.useCredential(urlCredential, forAuthenticationChallenge: challenge)
            
            
        } else {
            
            // nothing here but us chickens
        }
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession)
    {
        print("session finished")
    }
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?)
    {
        print("error is \(error?.description)")
    }
    
    //MARK: NSURLSessionTaskDelegate
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?)
    {
        print("error is \(error?.description)")
    }
    
//    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void)
//    {
//        let identityAndTrust:IdentityAndTrust? = self.extractIdentity("certificate" , certExt: "p12" , certPassword: "rww.io");
//        
//        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate && identityAndTrust != nil
//        {
//            let urlCredential:NSURLCredential = NSURLCredential(
//                identity: identityAndTrust!.identityRef,
//                certificates: identityAndTrust!.certArray as [AnyObject],
//                persistence: NSURLCredentialPersistence.Permanent);
//            
//            challenge.sender?.useCredential(urlCredential, forAuthenticationChallenge: challenge)
//            
//            
//        } else {
//            
//            // nothing here but us chickens
//        }
//    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void)
    {
        print("redirection done. \(response.description)")
    }
    
    // MARK: extract certificate data
    
    struct IdentityAndTrust {
        
        var identityRef:SecIdentityRef
        var trust:SecTrustRef
        var certArray:NSArray
    }
    
    func extractIdentity(certName:String, certExt: String , certPassword:String) -> IdentityAndTrust?
    {
        var identityAndTrust:IdentityAndTrust?
        var securityError:OSStatus = errSecSuccess
        
        if let path: String = NSBundle.mainBundle().pathForResource(certName , ofType: certExt)
        {
            if let PKCS12Data = NSData(contentsOfFile:path)
            {
                let key : NSString = kSecImportExportPassphrase as NSString
                let options : NSDictionary = [key : certPassword]
                //create variable for holding security information
                //var privateKeyRef: SecKeyRef? = nil
                
                var items : CFArray?
                
                securityError = SecPKCS12Import(PKCS12Data, options, &items)
                
                if securityError == errSecSuccess 
                {
                    let certItems:CFArray = items as CFArray!;
                    let certItemsArray:Array = certItems as Array
                    let dict:AnyObject? = certItemsArray.first;
                    if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> 
                    {
                        // grab the identity
                        let identityPointer:AnyObject? = certEntry["identity"];
                        let secIdentityRef:SecIdentityRef = identityPointer as! SecIdentityRef!;
//                        print("\(identityPointer)  :::: \(secIdentityRef)")
                        // grab the trust
                        let trustPointer:AnyObject? = certEntry["trust"];
                        let trustRef:SecTrustRef = trustPointer as! SecTrustRef;
//                        print("\(trustPointer)  :::: \(trustRef)")
                        // grab the cert
                        let chainPointer:NSArray? = certEntry["chain"] as? NSArray;
                        identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray:  chainPointer!);
                    }
                }
            }
        }
        
        return identityAndTrust;
    }
    
    private func setupSessionConfiguration() -> NSURLSessionConfiguration
    {
        let sessionConf = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConf.allowsCellularAccess = true
        sessionConf.timeoutIntervalForRequest = 30.0
        sessionConf.timeoutIntervalForResource = 60.0
        sessionConf.HTTPMaximumConnectionsPerHost = 10
        
        return sessionConf
    }
}