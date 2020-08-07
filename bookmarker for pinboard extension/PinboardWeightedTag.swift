import Foundation

struct PinboardWeightedTag : Comparable {
    let tagName: String
    let tagCount: Int
    
    init(tagName: String, tagCount: Int) {
        self.tagName = tagName
        self.tagCount = tagCount
    }
    
    static func < (first: PinboardWeightedTag , second: PinboardWeightedTag) -> Bool {
        return first.tagCount < second.tagCount
    }
    
    static func <= (first: PinboardWeightedTag , second: PinboardWeightedTag) -> Bool {
        return first.tagCount <= second.tagCount
    }
    
    static func > (first: PinboardWeightedTag , second: PinboardWeightedTag) -> Bool {
        return first.tagCount > second.tagCount
    }
    
    static func >= (first: PinboardWeightedTag , second: PinboardWeightedTag) -> Bool {
        return first.tagCount >= second.tagCount
    }
}
