//
//  URLSessionResponseHandlingTests.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/1/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import Foundation
import XCTest
@testable import GoldenHillHTTPLibrary

class URLSessionResponseHandlingTests : XCTestCase {
    
    let url = URL(string: "https://www.goldenhillsoftware.com/")!
    let request = URLRequest(url: URL(string: "https://www.goldenhillsoftware.com/")!)
    let urlSession = URLSession(configuration: URLSessionConfiguration.ephemeral)
    
    private func shouldNotBeCalledParser( obj: Any ) -> ParsedResponse? {
        XCTFail("should not have gotten here")
        return ParsedResponse()
    }
    
    private func simpleSuccessfulParser( obj: Any ) -> ParsedResponse? {
        return ParsedResponse()
    }
    
    private func simpleFailedParser( obj: Any ) -> ParsedResponse? {
        return nil
    }
    
    private func shouldNotBeCalledEmptyResultHandler( ) {
        XCTFail("should not have gotten here")
    }
    
    private func shouldNotBeCalledResultHandler( obj: ParsedResponse ) {
        XCTFail("should not have gotten here")
    }
    
    private func shouldNotBeCalledErrorHandler( error: HTTPAPIError ) {
        XCTFail("should not have gotten here")
    }
    
    private func errorMessageInterpreterReturningNil( input: Any ) -> String? {
        return nil
    }
    
    // The expected input is a JSON string: {"a": "b"}
    private func returnServerError( input: Any ) -> String? {
        guard let inputJson = input as? [String: String] else {
            XCTFail()
            return nil
        }
        XCTAssertEqual(inputJson["a"], "b")
        return "My custom server error."
    }
    
    private func assertError<T>( request: URLRequest, apiLabel: String, operationLabel: String, jsonResponseInterpreter: @escaping (Any) -> T?, errorMessageInterpreter: @escaping (Any) -> String?, data: Data?, response: URLResponse?, error: Error?, expectedErrorMessage: String, file: StaticString, line: UInt ) {
        
        let expectation = self.expectation(description: "test")
        self.urlSession.ghs_completionHandler(request: request, apiLabel: apiLabel, operationLabel: operationLabel, data: data, response: response, error: error, jsonResponseInterpreter: jsonResponseInterpreter, errorMessageInterpreter: errorMessageInterpreter) { (result) in
            switch result {
            case .success:
                XCTFail(file: file, line: line)
            case .failure(let error):
                XCTAssertEqual(error.detailedErrorMessage, expectedErrorMessage, file: file, line: line)
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 60, handler: nil)
        
    }
    
    private func assertError( request: URLRequest, apiLabel: String, operationLabel: String, errorMessageInterpreter: @escaping (Any) -> String?, data: Data?, response: URLResponse?, error: Error?, expectedErrorMessage: String, file: StaticString, line: UInt ) {
        
        let expectation = self.expectation(description: "test")
        self.urlSession.ghs_completionHandler(request: request, apiLabel: apiLabel, operationLabel: operationLabel, data: data, response: response, error: error, jsonResponseInterpreter: URLSession.self.ghs_voidJsonInterpreter, errorMessageInterpreter: errorMessageInterpreter) { (result) in
            switch result {
            case .success:
                XCTFail(file: file, line: line)
            case .failure(let error):
                XCTAssertEqual(error.detailedErrorMessage, expectedErrorMessage, file: file, line: line)
            }
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 60, handler: nil)
        
    }
    
    func testSuccess() {
        
        let successfulResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
        
        // Successful case
        let successfulExpectation = self.expectation(description: "success")
        
        self.urlSession.ghs_completionHandler(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: successfulResponse, error: nil, jsonResponseInterpreter: self.simpleSuccessfulParser, errorMessageInterpreter: self.errorMessageInterpreterReturningNil) { (result) in
            switch result {
            case .success:
                break
            case .failure(let error):
                XCTFail(error.combinedErrorMessage)
            }
            successfulExpectation.fulfill()
        }
        self.waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testSuccessNoBody() {
        for statusCode in [200, 201, 202, 204] {
            let successfulResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)
            
            // Successful case
            let successfulExpectation = self.expectation(description: "success")
            
            self.urlSession.ghs_completionHandler(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: successfulResponse, error: nil, jsonResponseInterpreter: URLSession.self.ghs_voidJsonInterpreter, errorMessageInterpreter: self.errorMessageInterpreterReturningNil) { (result) in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail(error.combinedErrorMessage)
                }
                successfulExpectation.fulfill()
            }
            
            self.waitForExpectations(timeout: 1, handler: nil)
        }
    }
    
    func testSuccessNoBodyEmptyData() {
        for statusCode in [200, 201, 202, 204] {
            let successfulResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)
            
            // Successful case
            let successfulExpectation = self.expectation(description: "success")
            
            self.urlSession.ghs_completionHandler(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", data: nil, response: successfulResponse, error: nil, jsonResponseInterpreter: URLSession.self.ghs_voidJsonInterpreter, errorMessageInterpreter: self.errorMessageInterpreterReturningNil) { (result) in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail(error.combinedErrorMessage)
                }
                successfulExpectation.fulfill()
            }
            
            self.waitForExpectations(timeout: 1, handler: nil)
        }
    }
    
    func testError() {
        let error = NSError(domain: "test", code: 35, userInfo: [NSLocalizedDescriptionKey: "framework error"])
        self.assertError(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", jsonResponseInterpreter: self.shouldNotBeCalledParser, errorMessageInterpreter: self.errorMessageInterpreterReturningNil, data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: nil, error: error, expectedErrorMessage: "Could not connect to Gmail. framework error", file: #file, line: #line)
    }
    
    func testErrorNoBody() {
        let error = NSError(domain: "test", code: 35, userInfo: [NSLocalizedDescriptionKey: "framework error"])
        self.assertError(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", errorMessageInterpreter: self.errorMessageInterpreterReturningNil, data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: nil, error: error, expectedErrorMessage: "Could not connect to Gmail. framework error", file: #file, line: #line)
    }
    
    func testBadJson() {
        let successfulResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
        
        self.assertError(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", jsonResponseInterpreter: self.shouldNotBeCalledParser, errorMessageInterpreter: self.errorMessageInterpreterReturningNil, data: "{\"a\" \"b\"}".data(using: String.Encoding.utf8), response: successfulResponse, error: nil, expectedErrorMessage: "Gmail returned a response that could not be parsed.", file: #file, line: #line)
        
    }
    
    func testBadParseResult() {
        let successfulResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
        
        self.assertError(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", jsonResponseInterpreter: self.simpleFailedParser, errorMessageInterpreter: self.errorMessageInterpreterReturningNil, data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: successfulResponse, error: nil, expectedErrorMessage: "Gmail returned a response that could not be parsed.", file: #file, line: #line)
    }
    
    func testUnexpectedResponseCode() {
        let failedResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: nil)
        
        self.assertError(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", jsonResponseInterpreter: self.shouldNotBeCalledParser, errorMessageInterpreter: self.errorMessageInterpreterReturningNil, data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: failedResponse, error: nil, expectedErrorMessage: "Gmail rejected the request (status code 404).", file: #file, line: #line)
    }
    
    func testUnexpectedResponseCodeNoBody() {
        let failedResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: nil)
        
        self.assertError(request: request, apiLabel: "Gmail", operationLabel: "get user profile", errorMessageInterpreter: self.errorMessageInterpreterReturningNil, data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: failedResponse, error: nil, expectedErrorMessage: "Gmail rejected the request (status code 404).", file: #file, line: #line)
    }
    
    func testServerErrorMessage() {
        var failedResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "application/json"])
        
        self.assertError(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", jsonResponseInterpreter: self.shouldNotBeCalledParser, errorMessageInterpreter: self.returnServerError, data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: failedResponse, error: nil, expectedErrorMessage: "My custom server error.", file: #file, line: #line)

        self.assertError(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", errorMessageInterpreter: self.returnServerError, data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: failedResponse, error: nil, expectedErrorMessage: "My custom server error.", file: #file, line: #line)
        
        // If the errorMessageInterpreter returns null
        self.assertError(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", jsonResponseInterpreter: self.shouldNotBeCalledParser, errorMessageInterpreter: self.errorMessageInterpreterReturningNil, data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: failedResponse, error: nil, expectedErrorMessage: "Gmail rejected the request (status code 404).", file: #file, line: #line)

        self.assertError(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", errorMessageInterpreter: self.errorMessageInterpreterReturningNil, data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: failedResponse, error: nil, expectedErrorMessage: "Gmail rejected the request (status code 404).", file: #file, line: #line)

        // Without the Content-Type: application/json
        failedResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: ["Content-Type": "text/html"])
        self.assertError(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", jsonResponseInterpreter: self.shouldNotBeCalledParser, errorMessageInterpreter: self.returnServerError, data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: failedResponse, error: nil, expectedErrorMessage: "Gmail rejected the request (status code 404).", file: #file, line: #line)
        self.assertError(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", errorMessageInterpreter: self.returnServerError, data: "{\"a\": \"b\"}".data(using: String.Encoding.utf8), response: failedResponse, error: nil, expectedErrorMessage: "Gmail rejected the request (status code 404).", file: #file, line: #line)
    }
    
    func testNoData() {
        let successfulResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)
        
        self.assertError(request: self.request, apiLabel: "Gmail", operationLabel: "get user profile", jsonResponseInterpreter: self.shouldNotBeCalledParser, errorMessageInterpreter: self.errorMessageInterpreterReturningNil, data: nil, response: successfulResponse, error: nil, expectedErrorMessage: "Gmail returned a response that could not be parsed.", file: #file, line: #line)
    }
    
    class ParsedResponse {
        var prop: Int?
    }

    
}
