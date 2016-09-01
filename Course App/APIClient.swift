//
//  APIClient.swift
//  Course App
//
//  Created by Ming Ying on 7/17/16.
//  Copyright © 2016 University at Albany. All rights reserved.
//

import Foundation

public class APIClient {
    private var baseURL = ""
    private var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    private func requestFor(path: String,
                            throughMethod method: String,
                            withBody body:AnyObject?) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: baseURL + path)!)
        request.HTTPMethod = method
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(body!, options: NSJSONWritingOptions(rawValue: 0))
        }
        return request
    }
    
    public func post(path: String, json: AnyObject?, completion: (success: Bool, object: AnyObject?) -> ()) {
        let request = requestFor(path, throughMethod: "POST", withBody: json)
        dataTask(request, completion: completion)
    }
    
    public func put(path: String, json: AnyObject?, completion: (success: Bool, object: AnyObject?) -> ()) {
        let request = requestFor(path, throughMethod: "PUT", withBody: json)
        dataTask(request, completion: completion)
    }
    
    public func get(path: String, completion: (success: Bool, object: AnyObject?) -> ()) {
        let request = requestFor(path, throughMethod: "GET", withBody: nil)
        dataTask(request, completion: completion)
    }
    
    public func delete(path: String, completion: (success: Bool, object: AnyObject?) -> ()) {
        let request = requestFor(path, throughMethod: "DELETE", withBody: nil)
        dataTask(request, completion: completion)
    }
    
    private func dataTask(request: NSMutableURLRequest, completion: (success: Bool, object: AnyObject?) -> ()) {
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let data = data {
                let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                if let response = response as? NSHTTPURLResponse where 200...299 ~= response.statusCode {
                    completion(success: true, object: json)
                } else {
                    completion(success: false, object: json)
                }
            }
            }.resume()
    }
}