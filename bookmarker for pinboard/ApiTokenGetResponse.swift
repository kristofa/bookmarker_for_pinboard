import Foundation

enum ApiTokenGetResponse {
    case Success(String)
    case ErrorApiTokenItemNotFound
    case ErrorUnexpectedApiTokenData
    case ErrorUnknown(OSStatus)
}
