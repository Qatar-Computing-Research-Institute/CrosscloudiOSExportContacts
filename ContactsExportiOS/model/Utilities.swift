//
//  Utilities.swift
//  Jalees
//
//  Created by Abdurrahman Ibrahem Ghanem on 9/2/15.
//  Copyright (c) 2015 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation
import UIKit

struct Utilities {
    
    static func performSelectorAfter(delay: Double, closure:() -> ())
    {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW , Int64(delay * Double(NSEC_PER_SEC))) ,
            dispatch_get_main_queue() ,
            closure)
    }
    
    static func performAsynch(qos_class: qos_class_t , closure: () -> () )
    {
        dispatch_async(dispatch_get_global_queue(qos_class , 0) , {
            
            closure()
        })
    }
    
    static func synced(lock: AnyObject, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    static func isOdd(number: Int) -> Bool
    {
        return number % 2 == 1
    }
    
    static func isEven(number: Int) -> Bool
    {
        return !isOdd(number)
    }
    
    static func isPortrait() -> Bool
    {
        return UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation)
    }
    
    static func isLandscape() -> Bool
    {
        return !isPortrait()
    }
}