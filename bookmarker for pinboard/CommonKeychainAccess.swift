import Foundation

class CommonKeychainAccess {
    
    static let serviceName = "bookmarker for pinboard"
    
    func getApiToken() -> ApiTokenGetResponse {
        let apiTokenQuery = query()
        var item: CFTypeRef?
        let status = SecItemCopyMatching(apiTokenQuery as CFDictionary, &item)
        
        switch status  {
        case errSecItemNotFound:
            return ApiTokenGetResponse.Error("API token not set.")
        case errSecSuccess:
            guard let existingItem = item as? [String : Any],
                let apiTokenData = existingItem[kSecValueData as String] as? Data,
                let apiToken = String(data: apiTokenData, encoding: String.Encoding.utf8) else {
                    return ApiTokenGetResponse.Error("API token data is invalid. Update API token.")
            }
            return ApiTokenGetResponse.Success(apiToken)
        default:
            return ApiTokenGetResponse.Error("Unknown error when getting API token from keychain. OSStatus: \(status)")
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
