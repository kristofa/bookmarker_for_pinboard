import Foundation

enum ApiTokenCreateOrUpdateResponse {
    case Success
    case ErrorCreatingTrustedApplicationsFailed(OSStatus, OSStatus)
    case ErrorCreatingSecAccess(OSStatus)
    case ErrorCreatingOrUpdatingApiToken(OSStatus)
}
