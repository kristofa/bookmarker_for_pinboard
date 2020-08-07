import Foundation

enum PinboardTagsResponse {
    case Success([PinboardWeightedTag])
    case Error(String)
}
