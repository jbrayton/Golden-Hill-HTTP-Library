//
//  JsonDataTaskGenerator.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 7/11/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import Foundation

public class JsonDataTaskGenerator<T> {
    
    let request: URLRequest
    let apiLabel: String
    let operationLabel: String
    
    public var errorMessageInterpreter: ErrorMessageInterpreter
    
    public var jsonResponseInterpreter: JsonResponseInterpreter<T>?
    public var handler: HTTPAPIResultHandler<T>?
    
    
    public init( request: URLRequest, apiLabel: String, operationLabel: String ) {
        self.request = request
        self.apiLabel = apiLabel
        self.operationLabel = operationLabel
        self.errorMessageInterpreter = { (x: Any) in
            return nil
        }
    }
    
    public func dataTask( fromSession session: URLSession ) -> URLSessionDataTask {
        return session.ghs_dataTask(request: request, apiLabel: self.apiLabel, operationLabel: self.operationLabel, jsonResponseInterpreter: self.jsonResponseInterpreter!, errorMessageInterpreter: self.errorMessageInterpreter, handler: self.handler!)
    }
    
}
