//
//  URLSession+JSONResponseHandling.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/1/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import Foundation
import Result

public typealias ErrorMessageInterpreter = (Any) -> String?

public typealias JsonResponseInterpreter<T> = (Any) -> T?

public extension URLSession {
    
    
    static let ghs_jsonContentTypes = ["application/json", "text/json"]
    static let ghs_successfulStatusCodesNoContent = [200, 201, 202, 204]

    /*
     This adds a method to the NSURLSession that requires far less error checking and 
     handling on the part of the caller. For simplicity, it assumes the following:
     * That the request is an HTTP/HTTPS request.
     * That it expects a 200 response and a JSON body.
     
     These are the parameters:
     * request: The request to be executed.
     * apiLabel: The name of the API. For example, "Gmail", "Feed Wrangler". Used to generate 
       meaningful error messages.
     * operationLabel: Text describing the operation that the request is attempting to perform, 
       such as "add a label".
     * jsonResponseInterpreter: Converts an Any into the object expected by the resultHandler. 
       It may return nil to indicate that it cannot parse the response. The AnyObject parameter 
       will be the result of calling NSJSONSerialization.JSONObjectWithData on the response data.
     * errorMessageInterpreter: If specified, attempts to parse an error message from a JSON response
       when the server serves a 4xx or 5xx error. May return nil to indicate that no error message
       could be found in the response.
     * handler: Will be called when completed with either a success response or an error response.
     */
    public func ghs_dataTask<T>( request: URLRequest, apiLabel: String, operationLabel: String, jsonResponseInterpreter: @escaping JsonResponseInterpreter<T>, errorMessageInterpreter: @escaping ErrorMessageInterpreter = { (x) in return nil }, handler: @escaping HTTPAPIResultHandler<T> ) -> URLSessionDataTask {
        NotificationCenter.default.post(name: NetworkNotifications.starting, object: nil)
        return self.dataTask(with: request, completionHandler: {[unowned self](data, response, error) in
            self.ghs_completionHandler(request: request, apiLabel: apiLabel, operationLabel: operationLabel, data: data, response: response, error: error, jsonResponseInterpreter: jsonResponseInterpreter, errorMessageInterpreter: errorMessageInterpreter, handler: handler)
            NotificationCenter.default.post(name: NetworkNotifications.finishing, object: nil)
        })
    }

    /*
     This is similar to the method above. These are the differences:
     * It assumes that the server will send an empty response or a response that can be
       ignored when successful. As a result there is no jsonResponseInterpreter
       parameter.
     * It will accept an HTTP response code of 200, 201, 202, or 204.
     */
    public func ghs_dataTask( request: URLRequest, apiLabel: String, operationLabel: String, errorMessageInterpreter: @escaping ErrorMessageInterpreter = { (x) in return nil }, handler: @escaping HTTPAPIResultHandler<Void> ) -> URLSessionDataTask {

        return self.ghs_dataTask(request: request, apiLabel: apiLabel, operationLabel: operationLabel, jsonResponseInterpreter: URLSession.self.ghs_voidJsonInterpreter, handler: handler)
    }
    
    /*
        A placeholder function that returns void, to be used when there is no need
        to parse a response body.
    */
    static func ghs_voidJsonInterpreter( any: Any ) -> Void {
        
    }

    public func ghs_completionHandler<T>( request: URLRequest, apiLabel: String, operationLabel: String, data: Data?, response: URLResponse?, error: Error?, jsonResponseInterpreter: @escaping JsonResponseInterpreter<T>, errorMessageInterpreter: @escaping ErrorMessageInterpreter, handler: @escaping (Result<T,HTTPAPIError>) -> Void ) {
        if let httpResponse = response as? HTTPURLResponse {
            
            // If jsonResponseInterpreter returns Void, there is no reason to parse the JSON. There may not even be JSON to 
            // parse. Accept a wider variety of status codes and essentially call Result.success(Void).
            if Void.self == T.self {
                if URLSession.ghs_successfulStatusCodesNoContent.contains(httpResponse.statusCode) {
                    
                    // I couldn't find a way to pass Void directly to Result.success(...).
                    if let obj = jsonResponseInterpreter("x") {
                        handler(Result.success(obj))
                        return
                    }
                    
                }
            }
            
            if httpResponse.statusCode == 200 {
                guard let mimeType = httpResponse.mimeType, URLSession.ghs_jsonContentTypes.contains(mimeType) else {
                    handler(Result.failure(HTTPAPIError.responseNotJson(apiLabel: apiLabel, operationLabel: operationLabel, contentType: httpResponse.mimeType)))
                    return
                }
                if let d = data {
                    let jsonParsed = try? JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions())
                    if let json = jsonParsed {
                        if let result = jsonResponseInterpreter(json) {
                            handler(Result.success(result))
                        } else {
                            handler(Result.failure(HTTPAPIError.interpretResponse(apiLabel: apiLabel, operationLabel: operationLabel)))
                        }
                    } else {
                        handler(Result.failure(HTTPAPIError.interpretResponse(apiLabel: apiLabel, operationLabel: operationLabel)))
                    }
                } else {
                    handler(Result.failure(HTTPAPIError.interpretResponse(apiLabel: apiLabel, operationLabel: operationLabel)))
                }
            } else {
                if httpResponse.statusCode > 399 {
                    if let theData = data, let errorMessage = self.ghs_parsePotentialError(httpResponse: httpResponse, data: theData, errorMessageInterpreter: errorMessageInterpreter) {
                        handler(Result.failure(HTTPAPIError.errorMessageFromServer(apiLabel: apiLabel, operationLabel: operationLabel, message: errorMessage)))
                        return
                    }
                }
                handler(Result.failure(HTTPAPIError.statusCode(apiLabel: apiLabel, operationLabel: operationLabel, statusCode: httpResponse.statusCode)))
            }
        } else {
            if let e = error {
                handler(Result.failure(HTTPAPIError.connection(apiLabel: apiLabel, operationLabel: operationLabel, error: e)))
            } else {
                handler(Result.failure(HTTPAPIError.urlSessionUnexpectedResponse(apiLabel: apiLabel, operationLabel: operationLabel)))
            }
        }
    }

    private func ghs_parsePotentialError( httpResponse: HTTPURLResponse, data: Data, errorMessageInterpreter: ErrorMessageInterpreter ) -> String? {
        guard let contentType = httpResponse.mimeType, URLSession.ghs_jsonContentTypes.contains(contentType) else {
            return nil
        }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }
        return errorMessageInterpreter(jsonObject)
    }

}
