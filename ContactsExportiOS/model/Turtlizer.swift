//
//  Turtlizer.swift
//  ContactsExportiOS
//
//  Created by Abdurrahman Ibrahem Ghanem on 12/30/15.
//  Copyright © 2015 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation

protocol Turtlizer
{
    func turtlize(ontologyFile: String, ContactWebID webid: String , imageURL: String) -> String?
    func deturtlize(turtleString trtlString: String)
}