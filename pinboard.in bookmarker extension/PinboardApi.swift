//
//  PinboardApi.swift
//  Pinboard Integration Extension
//
//  Created by Kristof Adriaenssens on 02/01/2019.
//  Copyright © 2019 Kristof Adriaenssens. All rights reserved.
//

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
                    guard response.statusCode == 200 else {
                        completionHandler(pinboardUrl, PinboardApiResponse.Error("Got an unexpected status code from api.pinboard.in: code: \(response.statusCode), response body: \(responseDataAsString)"))
                        return
                    }
                    
                    guard responseDataAsString.contains("<result code=\"done\" />") else {
                        completionHandler(pinboardUrl, PinboardApiResponse.Error(responseDataAsString))
                        return
                    }
                    completionHandler(pinboardUrl, PinboardApiResponse.Succes)
                } else {
                    completionHandler(pinboardUrl, PinboardApiResponse.Error("Got an unexpected response when invoking request to api.pinboard.in. Can't validate success. Response data: \(responseDataAsString)"))
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

