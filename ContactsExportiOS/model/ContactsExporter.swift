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
    
    var delegate: AllContactsViewController?
    let fileUploader = FileUploader()
    
    func exportContacts(webID:String , exportURL: String)
    {
//        let vcards = String(data: self.getvCardRepresentationForContacts(ContactsManager.contacts)!, encoding: NSUTF8StringEncoding)
        
        self.delegate?.showLoading(true)
        
        Utilities.performAsynch(QOS_CLASS_DEFAULT)
        {
            let documentDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            let newDir = documentDir.stringByAppendingString("/vCards/")
            let _ = try? NSFileManager.defaultManager().createDirectoryAtPath(newDir , withIntermediateDirectories: false , attributes: nil)
            let vCardOntologyPath = NSBundle.mainBundle().pathForResource("vCardOntologyMapping", ofType: "plist")
            
//            let _ = try? vcards?.writeToFile(documentDir + "/vCards.ttl" , atomically: true , encoding: NSUTF8StringEncoding)
            
            //        let podCom = PODCommunicator(podURL: podURL , containerPath: "Public/Contacts/")
            var index:Int = 1000
            for contact in ContactsManager.contacts
            {
                //            if let vcardData = self.getvCardRepresentationForContacts([contact])
                let vcard = contact.turtlize(vCardOntologyPath! , ContactWebID: webID , imageURL: "https://ghanemabdo.databox.me/profile/avatar.jpeg")
                let path = documentDir + "/vCards/vCard_" + String(index++) + ".ttl"
                let _ = try? vcard?.writeToFile(path , atomically: true , encoding: NSUTF8StringEncoding)
                
//                if let url = NSURL(string:exportURL)
//                {
//                    self.fileUploader.UploadFile(url , filePath: NSURL(fileURLWithPath: path) , fileData: vcard , fileName: "vCard_100" + String(index-1) + ".ttl")
//                    {
//                        (dataObj , success) in
//                    
//                    }
//                }
            }
            
            let path = documentDir + "/" + webID.stringByReplacingOccurrencesOfString("/" , withString: "") + "_vcards.zip"
            
            if (NSFileManager.defaultManager().fileExistsAtPath(path))
            {
                let _ = try? NSFileManager.defaultManager().removeItemAtPath(path)
            }
            
            ZipArchive.createZipFileAtPath(path , withContentsOfDirectory: newDir)
            
            let data = NSData(contentsOfFile: path)
            
//            if let url = NSURL(string:"http://qcrikpi.qcri.org/importContacts/receiveFile.php")
            if let url = NSURL(string:exportURL)
            {
                self.fileUploader.UploadData(url , filePath: NSURL(fileURLWithPath: path) , fileData: data , fileName: "cards.zip")
                {
                    (dataObj , success) in
                        
                    Utilities.performSynch
                    {
                        () -> Void in
                        self.delegate?.showLoading(false)
                    }
                }
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