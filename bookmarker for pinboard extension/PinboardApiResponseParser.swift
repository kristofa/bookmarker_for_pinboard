
import Foundation


class PinboardApiResponseParser {
    
    struct DefaultResponse : Decodable {
        var resultCode: String
        
        enum CodingKeys: String, CodingKey {
            case resultCode = "result_code"
        }
    }
    
    static func parseDefaultResponse(body: Data) -> PinboardApiResponse {
        
        let decoder = JSONDecoder()
        
        do {
            let response = try decoder.decode(DefaultResponse.self, from: body)
            if (response.resultCode == "done") {
                return PinboardApiResponse.Succes
            } else {
                return PinboardApiResponse.Error(response.resultCode)
            }
        } catch let error {
            return PinboardApiResponse.Error("Error when parsing response: \(error)")
        }
    }
}
