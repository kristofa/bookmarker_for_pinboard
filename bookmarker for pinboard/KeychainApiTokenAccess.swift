import Foundation

class KeychainApiTokenAccess : CommonKeychainAccess {
    
    private static let safariExtensionSuffix = "/pinboard.in bookmarker Extension.appex"
    
    
    func createOrUpdateToken(apiToken: String) -> ApiTokenCreateOrUpdateResponse {
        let apiTokenKeychain = apiToken.data(using: String.Encoding.utf8)!
        
        var status: OSStatus
        if (existingApiToken()) {
            let searchQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                              kSecAttrService as String: KeychainApiTokenAccess.serviceName]
            let updateQuery: [String: Any] = [kSecValueData as String: apiTokenKeychain]
            status = SecItemUpdate(searchQuery as CFDictionary, updateQuery as CFDictionary)
        } else {
            // We want to share our keychain item between the main app and the Safari app extension.
            var thisApp: SecTrustedApplication? = nil
            let statusThisApp = SecTrustedApplicationCreateFromPath(nil, &thisApp)
            
            var safariExtension: SecTrustedApplication? = nil
            // The path to the Safari App Extension
            let path: String = Bundle.main.builtInPlugInsPath! + KeychainApiTokenAccess.safariExtensionSuffix
            
            let pathAsNsString = path as NSString
            let utf8 = pathAsNsString.utf8String
            let statusSafariExtension = SecTrustedApplicationCreateFromPath(utf8!, &safariExtension)
            
            guard statusThisApp == errSecSuccess && statusSafariExtension == errSecSuccess else {
                NSLog("[ERROR] Creating trusted applications failed: Returned status for main app: \(statusThisApp), status for extension: \(statusSafariExtension).")
                return ApiTokenCreateOrUpdateResponse.ErrorCreatingTrustedApplicationsFailed(statusThisApp, statusSafariExtension)
            }
            
            let trustedApps: [SecTrustedApplication] = [thisApp!, safariExtension!]
            var access: SecAccess? = nil
            let statusAccessCreate = SecAccessCreate(KeychainApiTokenAccess.serviceName as CFString, trustedApps as CFArray, &access)
            
            guard statusAccessCreate == errSecSuccess else {
                NSLog("[ERROR] Creating SecAccess failed. Returned status: \(statusAccessCreate)")
                return ApiTokenCreateOrUpdateResponse.ErrorCreatingSecAccess(statusAccessCreate)
            }
            
            let addQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                           kSecAttrService as String: KeychainApiTokenAccess.serviceName,
                                           kSecValueData as String: apiTokenKeychain,
                                           kSecAttrAccess as String: access! ]
            status = SecItemAdd(addQuery as CFDictionary, nil)
        }
        
        switch status {
            case errSecSuccess : return ApiTokenCreateOrUpdateResponse.Success
            default:
                NSLog("[ERROR] Creating or updating item to keychain failed. Status: \(status)")
                return ApiTokenCreateOrUpdateResponse.ErrorCreatingOrUpdatingApiToken(status)
        }
    }
    
    private func existingApiToken() -> Bool {
        let apiTokenQuery = query()
        let status = SecItemCopyMatching(apiTokenQuery as CFDictionary, nil)
        
        switch status {
        case errSecItemNotFound:
            return false
        default:
            return true
        }
    }
    
}
