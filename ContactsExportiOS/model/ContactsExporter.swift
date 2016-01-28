//
//  ContactsExporter.swift
//  ContactsExportiOS
//
//  Created by Abdurrahman Ibrahem Ghanem on 12/23/15.
//  Copyright © 2015 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation
import Contacts

class ContactsExporter {
    
    let fileUploader = FileUploader()
    
    func exportContacts(webID:String)
    {
//        let vcards = String(data: self.getvCardRepresentationForContacts(ContactsManager.contacts)!, encoding: NSUTF8StringEncoding)
        
        Utilities.performAsynch(QOS_CLASS_DEFAULT)
        {
            let documentDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let vCardOntologyPath = NSBundle.mainBundle().pathForResource("vCardOntologyMapping", ofType: "plist")
            
//            let _ = try? vcards?.writeToFile(documentDir + "/vCards.ttl" , atomically: true , encoding: NSUTF8StringEncoding)
            
            //        let podCom = PODCommunicator(podURL: podURL , containerPath: "Public/Contacts/")
            var index:Int = 0
            for contact in ContactsManager.contacts
            {
                //            if let vcardData = self.getvCardRepresentationForContacts([contact])
                //            {
                let vcard = contact.turtlize(vCardOntologyPath! , ContactWebID: webID , imageURL: "https://ghanemabdo.databox.me/profile/avatar.jpeg")
                let path = documentDir + "/vCard_" + String(index++) + ".ttl"
                let _ = try? vcard?.writeToFile(path , atomically: true , encoding: NSUTF8StringEncoding)
                
                if let url = NSURL(string:"http://localhost:8080/SwiftUploadFile/receiveFile.php")
                {
                    self.fileUploader.UploadFile(url , filePath: NSURL(fileURLWithPath: path) , fileData: vcard , fileName: "vCard_" + String(index-1) + ".ttl")
                    {
                        (dataObj , success) in
                    
                    }
                }
                //                podCom.sendPut("vCard_" + contact.familyName + "_" + contact.givenName + "_" + contact.identifier, data: vcardData , responseCAllback: {
                //                    (success: Bool , statusCode: String? , data: NSData? , error: NSError?) -> Void in
                //                    
                //                    if error == nil         //success
                //                    {
                //                        
                //                    }
                //                    else                    //failed
                //                    {
                //                        
                //                    }
                //                })
                //            }
            }
        }
    }
    
    func getvCardRepresentationForContacts(contacts:[CNContact]) -> NSData?
    {
        do
        {
            let data = try CNContactVCardSerialization.dataWithContacts(contacts)
            
            return data
        } catch
        {
            print("can't convert contacts to data")
            
            return nil
        }
    }
}