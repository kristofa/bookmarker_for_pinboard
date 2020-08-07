
import Foundation


class PinboardApiResponseParser {
    
    private struct DefaultResponse : Decodable {
        var resultCode: String
        
        enum CodingKeys: String, CodingKey {
            case resultCode = "result_code"
        }
    }
    
    private struct ExistingUrl : Decodable {
        var url: String
        var title: String
        var description: String
        var shared: String
        var toread: String
        var tags: String
        var time: String
        
        enum CodingKeys: String, CodingKey {
            case url = "href"
            case title = "description"
            case description = "extended"
            case shared = "shared"
            case toread = "toread"
            case tags = "tags"
            case time = "time"
        }
        
        func isPrivate() -> Bool {
            if (shared == "yes") {
                return false
            }
            return true
        }
        
        func readLater() -> Bool {
            if (toread == "yes") {
                return true
            }
            return false
        }
    }
    
    private struct ExistingUrlEntries : Decodable {
        
        var date: String
        var posts: [ExistingUrl]
    }
    
    static func parseDefaultResponse(body: Data) -> PinboardApiResponseNoPayload {
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(DefaultResponse.self, from: body)
            if (response.resultCode == "done") {
                return PinboardApiResponseNoPayload.Succes
            } else {
                return PinboardApiResponseNoPayload.Error(response.resultCode)
            }
        } catch let error {
            return PinboardApiResponseNoPayload.Error("Error when parsing response: \(error)")
        }
    }
    
    static func parseExistingUrlEntries(body: Data) -> PinboardApiResponseExistingUrlEntries {
        
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(ExistingUrlEntries.self, from: body)
            let urls = response.posts.map(
                {
                    (value: ExistingUrl) -> PinboardUrl in
                    return PinboardUrl(url: value.url, title: value.title, description: value.description, isPrivate: value.isPrivate(), readLater: value.readLater(), tags: value.tags, date: value.time)
                    
            })
            return PinboardApiResponseExistingUrlEntries.Succes(urls)
        } catch let error {
            // NSLog(String(data: body, encoding: .utf8)!)
            return PinboardApiResponseExistingUrlEntries.Error("Error when parsing result of looking up URL: \(error)")
        }
    }
    
    static func parseTags(body: Data) -> PinboardTagsResponse {
        do {
            let json = try JSONSerialization.jsonObject(with: body, options: [])
            var tagArray = [PinboardWeightedTag]()
            if let dictionary = json as? [String: Int] {
                for (key, value) in dictionary {
                    tagArray.append(PinboardWeightedTag(tagName: key, tagCount: value))
                }
            }
            return PinboardTagsResponse.Success(tagArray)
        } catch let error {
            return PinboardTagsResponse.Error("Error when parsing tags as returned by the api:  \(error)")
        }
    }
}
