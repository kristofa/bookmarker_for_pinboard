//
//  CommonKeychainAccess.swift
//  pinboard.in bookmarker
//
//  Created by Kristof Adriaenssens on 13/01/2019.
//  Copyright © 2019 Kristof Adriaenssens. All rights reserved.
//

import Foundation

class CommonKeychainAccess {
    
    static let serviceName = "pinboard.in bookmarker"
    
    func getApiToken() -> ApiTokenGetResponse {
        let apiTokenQuery = query()
        var item: CFTypeRef?
        let status = SecItemCopyMatching(apiTokenQuery as CFDictionary, &item)
        
        switch status  {
        case errSecItemNotFound:
            return ApiTokenGetResponse.ErrorApiTokenItemNotFound
        case errSecSuccess:
            guard let existingItem = item as? [String : Any],
                let apiTokenData = existingItem[kSecValueData as String] as? Data,
                let apiToken = String(data: apiTokenData, encoding: String.Encoding.utf8) else {
                    return ApiTokenGetResponse.ErrorUnexpectedApiTokenData
            }
            return ApiTokenGetResponse.Success(apiToken)
        default:
            return ApiTokenGetResponse.ErrorUnknown(status)
        }
    }
    
    func query() -> [String: Any] {
        return [kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: CommonKeychainAccess.serviceName,
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecReturnAttributes as String: true,
                kSecReturnData as String: true]
    }
    
}
