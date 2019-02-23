import Foundation

class PinboardApi : NSObject, URLSessionDataDelegate {
    
    private static let pinboardUrl = URL(string: "https://api.pinboard.in/v1/posts/add")!
    
    
    func submit(apiToken: String, pinboardUrl: PinboardUrl, completionHandler: @escaping (PinboardUrl, PinboardApiResponse) -> Void) -> Void {
        
        let updatedTitle = pinboardUrl.title.replacingOccurrences(of: " ", with: "+")
        
        guard let url = addQueryParams(url: PinboardApi.pinboardUrl, newParams: [URLQueryItem.init(name:"url", value: pinboardUrl.url), URLQueryItem.init(name: "description", value: updatedTitle), URLQueryItem.init(name: "auth_token", value: apiToken), URLQueryItem.init(name: "extended", value: pinboardUrl.description), URLQueryItem.init(name: "tags", value: pinboardUrl.tags), URLQueryItem.init(name: "shared", value: boolToString(value: !pinboardUrl.isPrivate)), URLQueryItem.init(name: "toread", value: boolToString(value: pinboardUrl.readLater))] ) else {
            completionHandler(pinboardUrl, PinboardApiResponse.Error("Unable to create pinboard url"))
            return
        }
            
        var urlRequest = URLRequest(url: url, timeoutInterval: 1.0)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: urlRequest)
        {
            (data, response, error) in
            
                guard error == nil else {
                    completionHandler(pinboardUrl, PinboardApiResponse.Error("Got an error when invoking request to api.pinboard.in: \(error.debugDescription)"))
                    return
                }
                
                let responseDataAsString = data != nil ? String(data: data!, encoding: .utf8)! : "[No response data]"
                if let response = response as? HTTPURLResponse {
                    
                    switch (response.statusCode) {
                        case 200 :
                            self.okResponse(pinboardUrl: pinboardUrl, responseData: responseDataAsString, completionHandler: completionHandler)
                        case 401 :
                            completionHandler(pinboardUrl, PinboardApiResponse.Error("Got 'Forbidden' response. The configured API Token is probably invalid."))
                        default :
                            completionHandler(pinboardUrl, PinboardApiResponse.Error("Got an unexpected status code from api.pinboard.in: code: \(response.statusCode), response body: \(responseDataAsString)"))
                    }
                    
                } else {
                    completionHandler(pinboardUrl, PinboardApiResponse.Error("Got an unexpected response when invoking request to api.pinboard.in. Can't validate success. Response data: \(responseDataAsString)"))
                    return
                }
            }
            task.resume()
    }
    
    private func okResponse(pinboardUrl: PinboardUrl, responseData: String, completionHandler: (PinboardUrl, PinboardApiResponse) -> Void) -> Void {
        
        if (responseData.contains("<result code=\"done\" />")) {
                completionHandler(pinboardUrl, PinboardApiResponse.Succes)
        } else {
            completionHandler(pinboardUrl, PinboardApiResponse.Error(responseData))
        }
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

