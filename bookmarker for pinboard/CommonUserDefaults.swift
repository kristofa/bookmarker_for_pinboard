//
//  CommonUserDefaults.swift
//  bookmarker for pinboard
//
//  Created by Kristof Adriaenssens on 31/03/2019.
//  Copyright © 2019 Kristof Adriaenssens. All rights reserved.
//

import Foundation


class CommonUserDefaults {
    
    static let sharedUserDefaults = UserDefaults(suiteName: "LFASJ6UBQ7.bookmarker.for.pinboard")!
    static let readLaterKey = "readLater"
    static let privateKey = "private"
    
    static let readLaterDefaultValue = "No"
    static let privateDefaultValue = "No"
    
    func setReadLater(value: String) -> Void {
        CommonUserDefaults.sharedUserDefaults.set(value, forKey: CommonUserDefaults.readLaterKey)
    }
    
    func setPrivate(value: String) -> Void {
        CommonUserDefaults.sharedUserDefaults.set(value, forKey: CommonUserDefaults.privateKey)
    }
    
    func getReadLater() -> String? {
        return CommonUserDefaults.sharedUserDefaults.string(forKey: CommonUserDefaults.readLaterKey)
    }
    
    func setReadLaterDefaultValue() -> String {
        CommonUserDefaults.sharedUserDefaults.set(CommonUserDefaults.readLaterDefaultValue, forKey: CommonUserDefaults.readLaterKey)
        return CommonUserDefaults.readLaterDefaultValue
    }
    
    func getPrivate() -> String? {
        return CommonUserDefaults.sharedUserDefaults.string(forKey: CommonUserDefaults.privateKey)
    }
    
    func setPrivateDefaultValue() -> String {
        CommonUserDefaults.sharedUserDefaults.set(CommonUserDefaults.privateDefaultValue, forKey: CommonUserDefaults.privateKey)
        return CommonUserDefaults.privateDefaultValue
    }
    
}
