//
//  Contact.swift
//  ContactsExportiOS
//
//  Created by Abdurrahman Ibrahem Ghanem on 12/23/15.
//  Copyright © 2015 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class ContactsManager {
    
    static let contactStore = CNContactStore()
    static var contacts = [CNContact]()
    static let contactsExporter = ContactsExporter()
    
    class func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus
        {
        case .Authorized:
            completionHandler(accessGranted: true)
            
        case .Denied, .NotDetermined:
            contactStore.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access
                {
                    completionHandler(accessGranted: access)
                }
                else
                {
                    if authorizationStatus == CNAuthorizationStatus.Denied
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            showMessage(message)
                        })
                    }
                }
            })
            
        default:
            completionHandler(accessGranted: false)
        }
    }
    
    class func showMessage(message: String) {
        let alertController = UIAlertController(title: "Contacts Exporter", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        
        let pushedViewControllers = (AppDelegate.getAppDelegate().window?.rootViewController as! UINavigationController).viewControllers
        let presentedViewController = pushedViewControllers[pushedViewControllers.count - 1]
        
        presentedViewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func readAllContacts(loadingFinished: (success: Bool) -> Void)
    {
        requestForAccess
        { (accessGranted) -> Void in
            if accessGranted 
            {
                contacts.removeAll()
                
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT , 0))
//                {
//                    
//                }
                
//                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName),
//                    CNContactNamePrefixKey,
//                    CNContactGivenNameKey,
//                    CNContactMiddleNameKey,
//                    CNContactFamilyNameKey,
//                    CNContactPreviousFamilyNameKey,
//                    CNContactNameSuffixKey,
//                    CNContactNicknameKey,
//                    CNContactOrganizationNameKey,
//                    CNContactDepartmentNameKey,
//                    CNContactJobTitleKey,
//                    CNContactEmailAddressesKey, 
//                    CNContactPhoneNumbersKey,
//                    CNContactUrlAddressesKey,
//                    CNContactBirthdayKey, 
//                    CNContactImageDataKey,
//                    CNContactThumbnailImageDataKey,
//                    CNContactImageDataAvailableKey,
//                    CNContactNoteKey,
//                    CNContactOrganizationNameKey,
//                    CNContactPostalAddressesKey,
//                    CNContactRelationsKey,
//                    CNContactTypeKey,
//                    CNContactSocialProfilesKey,
//                    CNContactDatesKey]
                let keysToFetch = [CNContactVCardSerialization.descriptorForRequiredKeys()]
                
                // Get all the containers
                var allContainers: [CNContainer] = []
                do {
                    allContainers = try contactStore.containersMatchingPredicate(nil)
                } catch {
                    print("Error fetching containers")
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        loadingFinished(success: false)
                    })
                }
                                
                // Iterate all containers and append their contacts to our results array
                for container in allContainers 
                {
                    let fetchPredicate = CNContact.predicateForContactsInContainerWithIdentifier(container.identifier)
                    
                    do {
                        let containerResults = try contactStore.unifiedContactsMatchingPredicate(fetchPredicate, keysToFetch: keysToFetch)
                        contacts.appendContentsOf(containerResults)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            loadingFinished(success: false)
                        })
                    } catch 
                    {
                        print("Error fetching results for container")
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            loadingFinished(success: false)
                        })
                    }
                }
            }
        }
    }
}