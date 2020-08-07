import Foundation


class PinboardApi : NSObject, URLSessionDataDelegate {
    
    private static let pinboardAddPostUrl = URL(string: "https://api.pinboard.in/v1/posts/add")!
    private static let pinboardGetPostsUrl = URL(string: "https://api.pinboard.in/v1/posts/get")!
    private static let pinboardGetTagsUrl = URL(string: "https://api.pinboard.in/v1/tags/get")!
    private static let getUrlErrorPrefix = "When retrieving previously saved bookmark: "
    private static let addUrlErrorPrefix = "When adding or updating bookmark: "
    private static let getTagsErrorPrefix = "When retrieving tags for user: "
    
    func add(apiToken: String, pinboardUrl: PinboardUrl, completionHandler: @escaping (PinboardUrl, PinboardApiResponseNoPayload) -> Void) -> Void {
        
        let updatedTitle = pinboardUrl.title.replacingOccurrences(of: " ", with: "+")
        
        guard let url = addQueryParams(
            url: PinboardApi.pinboardAddPostUrl,
            newParams:
            [
                URLQueryItem.init(name:"url", value: pinboardUrl.url),
                URLQueryItem.init(name: "description", value: updatedTitle),
                URLQueryItem.init(name: "auth_token", value: apiToken),
                URLQueryItem.init(name: "extended", value: pinboardUrl.description),
                URLQueryItem.init(name: "tags", value: pinboardUrl.tags),
                URLQueryItem.init(name: "shared", value: boolToString(value: !pinboardUrl.isPrivate)),
                URLQueryItem.init(name: "toread", value: boolToString(value: pinboardUrl.readLater)),
                URLQueryItem.init(name: "format", value: "json")] ) else {
                    completionHandler(pinboardUrl, PinboardApiResponseNoPayload.Error(PinboardApi.addUrlErrorPrefix + "Unable to create pinboard url"))
            return
        }
            
        var urlRequest = URLRequest(url: url, timeoutInterval: 2.0)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: urlRequest)
        {
            (data, response, error) in
            
                guard error == nil else {
                    completionHandler(pinboardUrl, PinboardApiResponseNoPayload.Error(PinboardApi.addUrlErrorPrefix + "Got an error when invoking request to api.pinboard.in: \(error!.localizedDescription)"))
                    return
                }
                
                let responseDataAsString = data != nil ? String(data: data!, encoding: .utf8)! : "[No response data]"
                if let response = response as? HTTPURLResponse {
                    
                    switch (response.statusCode) {
                        case 200 :
                            let responseToReturn = PinboardApiResponseParser.parseDefaultResponse(body: data ?? Data())
                            completionHandler(pinboardUrl, responseToReturn)
                        case 401 :
                            completionHandler(pinboardUrl, PinboardApiResponseNoPayload.Error(PinboardApi.addUrlErrorPrefix + "Got 'Forbidden' response. The configured API Token is probably invalid."))
                        default :
                            completionHandler(pinboardUrl, PinboardApiResponseNoPayload.Error(PinboardApi.addUrlErrorPrefix + "Got an unexpected status code from api.pinboard.in: code: \(response.statusCode), response body: \(responseDataAsString)"))
                    }
                    
                } else {
                    completionHandler(pinboardUrl, PinboardApiResponseNoPayload.Error(PinboardApi.addUrlErrorPrefix + "Got an unexpected response when invoking request to api.pinboard.in. Can't validate success. Response data: \(responseDataAsString)"))
                    return
                }
        }
        task.resume()
    }

    func get(apiToken: String, inputUrl: String, completionHandler: @escaping (String, PinboardApiResponseExistingUrlEntries) -> Void) -> Void {
        
        guard let url = addQueryParams(
            url: PinboardApi.pinboardGetPostsUrl,
            newParams:
            [
                URLQueryItem.init(name: "url", value: inputUrl),
                URLQueryItem.init(name: "auth_token", value: apiToken),
                URLQueryItem.init(name: "format", value: "json")] ) else {
            
                    completionHandler(inputUrl, PinboardApiResponseExistingUrlEntries.Error(PinboardApi.getUrlErrorPrefix + "Unable to create pinboard url"))
            return
        }
            
        var urlRequest = URLRequest(url: url, timeoutInterval: 3.0)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: urlRequest)
        {
            (data, response, error) in
            
                guard error == nil else {
                    completionHandler(inputUrl, PinboardApiResponseExistingUrlEntries.Error(PinboardApi.getUrlErrorPrefix + "Got an error when invoking request to api.pinboard.in: \(error!.localizedDescription)"))
                    return
                }
                
                let responseDataAsString = data != nil ? String(data: data!, encoding: .utf8)! : "[No response data]"
                if let response = response as? HTTPURLResponse {
                    switch (response.statusCode) {
                        case 200 :
                            let responseToReturn = PinboardApiResponseParser.parseExistingUrlEntries(body: data ?? Data())
                            completionHandler(inputUrl, responseToReturn)
                        case 401 :
                            completionHandler(inputUrl, PinboardApiResponseExistingUrlEntries.Error(PinboardApi.getUrlErrorPrefix + "Got 'Forbidden' response. The configured API Token is probably invalid."))
                        default :
                            completionHandler(inputUrl, PinboardApiResponseExistingUrlEntries.Error(PinboardApi.getUrlErrorPrefix + "Got an unexpected status code from api.pinboard.in: code: \(response.statusCode), response body: \(responseDataAsString)"))
                    }
                } else {
                    completionHandler(inputUrl, PinboardApiResponseExistingUrlEntries.Error(PinboardApi.getUrlErrorPrefix + "Got an unexpected response when invoking request to api.pinboard.in. Can't validate success. Response data: \(responseDataAsString)"))
                    return
                }
        }
        task.resume()
    }
    
    func getTags(apiToken: String, completionHandler: @escaping (PinboardTagsResponse) -> Void) -> Void {
        
        guard let url = addQueryParams(
            url: PinboardApi.pinboardGetTagsUrl,
            newParams:
            [
                URLQueryItem.init(name: "auth_token", value: apiToken),
                URLQueryItem.init(name: "format", value: "json")] ) else {
                    completionHandler(PinboardTagsResponse.Error(PinboardApi.getTagsErrorPrefix + "Unable to create pinboard url"))
            return
        }
            
        var urlRequest = URLRequest(url: url, timeoutInterval: 3.0)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: urlRequest)
        {
            (data, response, error) in
            
                guard error == nil else {
                    completionHandler( PinboardTagsResponse.Error(PinboardApi.getTagsErrorPrefix + "Got an error when invoking request to api.pinboard.in: \(error!.localizedDescription)"))
                    return
                }
                
                let responseDataAsString = data != nil ? String(data: data!, encoding: .utf8)! : "[No response data]"
                if let response = response as? HTTPURLResponse {
                    switch (response.statusCode) {
                        case 200 :
                            let responseToReturn = PinboardApiResponseParser.parseTags(body: data ?? Data())
                            completionHandler(responseToReturn)
                        case 401 :
                            completionHandler( PinboardTagsResponse.Error(PinboardApi.getTagsErrorPrefix + "Got 'Forbidden' response. The configured API Token is probably invalid."))
                        default :
                            completionHandler( PinboardTagsResponse.Error(PinboardApi.getTagsErrorPrefix + "Got an unexpected status code from api.pinboard.in: code: \(response.statusCode), response body: \(responseDataAsString)"))
                    }
                } else {
                    completionHandler(PinboardTagsResponse.Error(PinboardApi.getTagsErrorPrefix + "Got an unexpected response when invoking request to api.pinboard.in. Can't validate success. Response data: \(responseDataAsString)"))
                    return
                }
        }
        task.resume()
    }
    
    private func addQueryParams(url: URL, newParams: [URLQueryItem]) -> URL? {
        let urlComponents = NSURLComponents.init(url: url, resolvingAgainstBaseURL: false)
        guard urlComponents != nil else { return nil; }
        if (urlComponents?.queryItems == nil) {
            urlComponents!.queryItems = [];
        }
        urlComponents!.queryItems!.append(contentsOf: newParams);
        return urlComponents?.url;
    }
    
    private func boolToString(value: Bool) -> String {
        return value == true ? "yes" : "no"
    }
    
    
}

