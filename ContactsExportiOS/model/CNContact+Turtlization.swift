//
//  CNContact+Turtlization.swift
//  ContactsExportiOS
//
//  Created by Abdurrahman Ibrahem Ghanem on 12/30/15.
//  Copyright © 2015 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation
import Contacts

extension CNContact: Turtlizer
{
    func turtlize(ontologyFile: String, ContactWebID webid: String , imageURL: String) -> String?
    {
        if let ontologyDict = NSDictionary(contentsOfFile: ontologyFile)
        {
            let vcardURI = webid + "/Applications/contacts/vcard_" + self.identifier
            var contactRDF = "@prefix vCard: <http://www.w3.org/2006/vcard/ns#> .\n\n" +
                            "<" + vcardURI + ">\n" +
                            "\tvCard:hasUID <" + webid + ">;\n"
            
            //contact type
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactTypeKey, itemPrefix: "vCard:" , contactItem: self.contactType.stringValue().capitalizedString , itemSuffix: "")
            
            //name
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactGivenNameKey , itemPrefix: "\"" , contactItem: self.givenName , itemSuffix: "\"")
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactFamilyNameKey , itemPrefix: "\"" , contactItem: self.familyName , itemSuffix: "\"")
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactNamePrefixKey , itemPrefix: "\"" , contactItem: self.namePrefix , itemSuffix: "\"")
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactNameSuffixKey , itemPrefix: "\"" , contactItem: self.nameSuffix , itemSuffix: "\"")
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactNicknameKey , itemPrefix: "\"" , contactItem: self.nickname , itemSuffix: "\"")
            
            //work related info
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactJobTitleKey , itemPrefix: "\"" , contactItem: self.jobTitle , itemSuffix: "\"")
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactOrganizationNameKey , itemPrefix: "\"" , contactItem: self.organizationName , itemSuffix: "\"")
        
            //photo
            if imageURL.characters.count > 0
            {
                contactRDF += "\tvCard:hasPhoto <" + imageURL + ">;\n"
            }
            
            //emails
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactEmailAddressesKey , itemPrefix: "<mailto:" , contactItem: self.emailAddresses , itemSuffix: ">")
        
            //phones
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactPhoneNumbersKey , itemPrefix: "<tel:" , contactItem: self.phoneNumbers , itemSuffix: ">")
        
            //addresses
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactPostalAddressesKey , itemPrefix: "" , contactItem: self.postalAddresses , itemSuffix: "")
            
            //instant messaging
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactInstantMessageAddressesKey , itemPrefix: "\"" , contactItem: self.instantMessageAddresses , itemSuffix: "\"")
            
            //url addresses
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactUrlAddressesKey , itemPrefix: "<" , contactItem: self.urlAddresses , itemSuffix: ">")
            
            //contact relations
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactRelationsKey , itemPrefix: "\"" , contactItem: self.contactRelations , itemSuffix: "\"")
            
            //note
            contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactNoteKey , itemPrefix: "\"" , contactItem: self.note , itemSuffix: "\"")
            
            //birthday
            if let bday = self.birthday
            {
                contactRDF += appendTriple(ontologyDict , contactItemKey: CNContactBirthdayKey , itemPrefix: "\"" , contactItem: bday , itemSuffix: "\"")
            }
            
            return contactRDF
        }
        
        return nil
    }
    
    func deturtlize(turtleString trtlString: String)
    {
        
    }
    
    func appendTriple(ontologyDict: NSDictionary , contactItemKey itemKey: String , itemPrefix: String, contactItem: AnyObject , itemSuffix: String) -> String
    {
        if self.isKeyAvailable(itemKey)
        {
            if let ontologyTerm = ontologyDict[itemKey] as? String
            {
                if let ci = contactItem as? String
                {
                    if ci.characters.count > 0
                    {
                        return "\tvCard:" + ontologyTerm +  " " + itemPrefix + ci + itemSuffix + " ;\n"
                    }
                }
                else if let ci = contactItem as? [CNLabeledValue]
                {
                    var resultRDF = ""
                    
                    for labelValue in ci
                    {
                        if let value = labelValue.value as? String  //email addresses and instant messaging addresses
                        {
                            resultRDF += "\tvCard:" + ontologyTerm +  " " + itemPrefix + value + itemSuffix + " ;\n"
                        }
                        else if let value = labelValue.value as? CNPhoneNumber
                        {
                            resultRDF += "\tvCard:" + ontologyTerm +  " " + itemPrefix + value.stringValue + itemSuffix + " ;\n"
                        }
                        else if let value = labelValue.value as? CNPostalAddress
                        {
                            resultRDF += "\tvCard:" + ontologyTerm +  " [\n" +
                                "\t\tvCard:hasCountryName \"" + value.country + "\";\n" +
                                "\t\tvCard:hasRegion \"" + value.state + "\";\n" +
                                "\t\tvCard:hasLocality \"" + value.city + "\";\n" +
                                "\t\tvCard:hasStreetAddress \"" + value.street + "\";\n" +
                                "\t\tvCard:hasPostalCode \"" + value.postalCode + "\";\n" +
                                "\t] ;\n"
                        }
                        else if let value = labelValue.value as? CNInstantMessageAddress
                        {
                            resultRDF += "\tvCard:" + ontologyTerm +  " " + itemPrefix + value.username + itemSuffix + " ;\n"
                        }
                        else if let value = labelValue.value as? CNContactRelation
                        {
                            resultRDF = "\tvCard:" + ontologyTerm +  " " + itemPrefix + value.name + itemSuffix + " ;\n"
                        }
//                        else if let value = labelValue.value as? CNSocialProfile
//                        {
//                            let resultRDF = "vCard:" + ontologyTerm +  " [" +
//                                "vCard:hasCountryName \"" + value.country + "\";\n" +
//                                "vCard:hasRegion \"" + value.state + "\";\n" +
//                                "vCard:hasLocality \"" + value.city + "\";\n" +
//                                "vCard:hasStreetAddress \"" + value.street + "\";\n" +
//                                "vCard:hasPostalCode \"" + value.postalCode + "\";\n" +
//                            "] ;\n"
//                            return resultRDF
//                        }
                    }
                    
                    return resultRDF
                }
                else if let ci = contactItem as? NSDateComponents
                {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if ci.isValidDateInCalendar(NSCalendar.currentCalendar())
                    {
                        let dateString = dateFormatter.stringFromDate(ci.date!)
                        return "\tvCard:" + ontologyTerm +  " " + itemPrefix + dateString + itemSuffix + " ;\n"
                    }
                }
            }
        }
        
        return ""
    }
}

extension CNContactType
{
    func stringValue() -> String
    {
        switch self
        {
        case .Person:
            return "Individual"
        case .Organization:
            return "Organization"
        }
    }
}