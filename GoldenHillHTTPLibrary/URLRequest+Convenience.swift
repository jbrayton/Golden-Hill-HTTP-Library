//
//  URLRequest+Convenience.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/1/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import Foundation

public extension URLRequest {
    
    public mutating func ghs_setPostJson(_ jsonDictionary: [String: Any]) {
        do {
            self.setValue("application/json", forHTTPHeaderField: "Content-Type")
            self.httpMethod = "POST"
            let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: JSONSerialization.WritingOptions())
            self.httpBody = data
        } catch {
            NSLog("Unable to set POST json")
        }
    }
    
    public mutating func ghs_setPostArgString( _ value: String ) {
        self.httpMethod = "POST"
        self.httpBody = value.data(using: String.Encoding.utf8)
    }
    
    public mutating func ghs_setBasicAuth( username: String, password: String ) {
        let str = String(format: "%@:%@", arguments: [username, password])
        let data = str.data(using: String.Encoding.utf8)!
        let base64 = data.base64EncodedData(options: NSData.Base64EncodingOptions())
        let base64String = String(data: base64, encoding: String.Encoding.utf8)!
        let headerValue = String(format: "Basic %@", base64String)
        self.setValue(headerValue, forHTTPHeaderField: "Authorization")
    }
    
}
