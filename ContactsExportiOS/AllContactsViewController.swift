//
//  ViewController.swift
//  ContactsExportiOS
//
//  Created by Abdurrahman Ibrahem Ghanem on 12/23/15.
//  Copyright © 2015 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class AllContactsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UIAlertViewDelegate {
    
    @IBOutlet weak var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save , target: self , action: "exportContacts")
        
        ContactsManager.readAllContacts
        { (success: Bool) -> Void in
            if success
            {
                self.table.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: table view datasource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("idCellContactBirthday") as? ContactTableViewCell
        
        if cell == nil
        {
            cell = ContactTableViewCell.instanceFromNib()
        }
        
        let currentContact = ContactsManager.contacts[indexPath.row]
        
        // cell.lblFullname.text = "\(currentContact.givenName) \(currentContact.familyName)"
        cell!.lblFullname.text = CNContactFormatter.stringFromContact(currentContact, style: .FullName)
        
        
        // Set the birthday info.
        if let birthday = currentContact.birthday {
            // cell.lblBirthday.text = "\(birthday.year)-\(birthday.month)-\(birthday.day)"
            cell!.lblBirthday.text = getDateStringFromComponents(birthday)
        }
        else {
            cell!.lblBirthday.text = "Not available birthday data"
        }
        
        // Set the contact image.
        if let imageData = currentContact.imageData {
            cell!.imgContactImage.image = UIImage(data: imageData)
        }
        
        // Set the contact's work email address.
        var homeEmailAddress: String!
        for emailAddress in currentContact.emailAddresses {
            if emailAddress.label == CNLabelHome {
                homeEmailAddress = emailAddress.value as! String
                break
            }
        }
        
        if homeEmailAddress != nil {
            cell!.lblEmail.text = homeEmailAddress
        }
        else {
            cell!.lblEmail.text = "Not available home email"
        }
        
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ContactsManager.contacts.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100.0
    }
    
    //MARK: table view delegate
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedContact = ContactsManager.contacts[indexPath.row]
        
        let keys = [CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName), CNContactEmailAddressesKey, CNContactBirthdayKey, CNContactImageDataKey]
        
        if selectedContact.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
            let contactViewController = CNContactViewController(forContact: selectedContact)
            contactViewController.contactStore = ContactsManager.contactStore
            contactViewController.displayedPropertyKeys = keys
            navigationController?.pushViewController(contactViewController, animated: true)
        }
        else 
        {
            ContactsManager.requestForAccess({ (accessGranted) -> Void in
                if accessGranted 
                {
                    do {
                        let contactRefetched = try ContactsManager.contactStore.unifiedContactWithIdentifier(selectedContact.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let contactViewController = CNContactViewController(forContact: contactRefetched)
                            contactViewController.contactStore = ContactsManager.contactStore
                            contactViewController.displayedPropertyKeys = keys
                            self.navigationController?.pushViewController(contactViewController, animated: true)
                        })
                    }
                    catch 
                    {
                        print("Unable to refetch the selected contact.", separator: "", terminator: "\n")
                    }
                }
            })
        }
        
        tableView .deselectRowAtIndexPath(indexPath , animated: true)
    }
    
    private func getDateStringFromComponents(dateComponents: NSDateComponents) -> String! 
    {
        if let date = NSCalendar.currentCalendar().dateFromComponents(dateComponents) 
        {
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale.currentLocale()
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            let dateString = dateFormatter.stringFromDate(date)
            
            return dateString
        }
        
        return nil
    }
    
    private var podUrlTextField: UITextField?
    
    func exportContacts()
    {
        let alertView = UIAlertController(title: "Export Contacts", message: "Enter your pod url", preferredStyle: UIAlertControllerStyle.Alert)
        alertView.addAction(UIAlertAction(title: "Export" , style: UIAlertActionStyle.Default , handler: {(alertView) -> Void in
            
            if let podURL = self.podUrlTextField?.text
            {
                ContactsManager.contactsExporter.exportContacts(podURL)
            }
        }))
        
        alertView.addAction(UIAlertAction(title: "Cancel" , style: UIAlertActionStyle.Default , handler: nil))
        alertView.addTextFieldWithConfigurationHandler({(textField) -> Void in
                
            textField.placeholder = "Enter your pod URL"
            textField.text = "https://exportcontactsios.databox.me"
            self.podUrlTextField = textField
        })
        
        self.presentViewController(alertView , animated: true , completion: nil)
    }
}

