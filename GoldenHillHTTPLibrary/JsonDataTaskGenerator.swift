//
//  JsonDataTaskGenerator.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 7/11/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import Foundation

class JsonDataTaskGenerator<T> {
    
    let request: URLRequest
    let apiLabel: String
    let operationLabel: String
    
    var errorMessageInterpreter: ErrorMessageInterpreter
    
    var jsonResponseInterpreter: JsonResponseInterpreter<T>?
    var handler: HTTPAPIResultHandler<T>?
    
    
    init( request: URLRequest, apiLabel: String, operationLabel: String ) {
        self.request = request
        self.apiLabel = apiLabel
        self.operationLabel = operationLabel
        self.errorMessageInterpreter = { (x: Any) in
            return nil
        }
    }
    
    func dataTask( fromSession session: URLSession ) -> URLSessionDataTask {
        return session.ghs_dataTask(request: request, apiLabel: self.apiLabel, operationLabel: self.operationLabel, jsonResponseInterpreter: self.jsonResponseInterpreter!, errorMessageInterpreter: self.errorMessageInterpreter, handler: self.handler!)
    }
    
}
