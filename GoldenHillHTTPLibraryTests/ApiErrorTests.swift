//
//  ApiErrorTests.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/3/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import XCTest
@testable import GoldenHillHTTPLibrary

class ApiErrorTests: XCTestCase {
    
    func testExample() {
        let nserror = NSError(domain: "foo", code: 100, userInfo: [NSLocalizedDescriptionKey: "yo"])
        var error = ApiError.connection(apiLabel: "Gmail", operationLabel: "reauthenticate", error: nserror)
        XCTAssertEqual(error.combinedErrorMessage, "Unable to reauthenticate. Could not connect to Gmail. yo")
        
        error = ApiError.statusCode(apiLabel: "Gmail", operationLabel: "get an authentication token from a code", statusCode: 201)
        XCTAssertEqual(error.combinedErrorMessage, "Unable to get an authentication token from a code. Gmail returned an unexpected status code (201).")
        
        error = ApiError.statusCode(apiLabel: "Gmail", operationLabel: "retrieve the account profile", statusCode: 401)
        XCTAssertEqual(error.combinedErrorMessage, "Unable to retrieve the account profile. Gmail did not accept the credentials. Please try logging out and logging back in.")
        
        error = ApiError.statusCode(apiLabel: "Gmail", operationLabel: "retrieve the account profile", statusCode: 403)
        XCTAssertEqual(error.combinedErrorMessage, "Unable to retrieve the account profile. Gmail did not accept the credentials. Please try logging out and logging back in.")
        
        error = ApiError.statusCode(apiLabel: "Gmail", operationLabel: "retrieve the account profile", statusCode: 400)
        XCTAssertEqual(error.combinedErrorMessage, "Unable to retrieve the account profile. Gmail rejected the request (status code 400).")
        
        error = ApiError.statusCode(apiLabel: "Gmail", operationLabel: "retrieve the account profile", statusCode: 402)
        XCTAssertEqual(error.combinedErrorMessage, "Unable to retrieve the account profile. Gmail rejected the request (status code 402).")
        
        error = ApiError.statusCode(apiLabel: "Gmail", operationLabel: "retrieve the account profile", statusCode: 500)
        XCTAssertEqual(error.combinedErrorMessage, "Unable to retrieve the account profile. Gmail reported an internal server error (status code 500).")
        
        error = ApiError.statusCode(apiLabel: "Gmail", operationLabel: "retrieve the account profile", statusCode: 501)
        XCTAssertEqual(error.combinedErrorMessage, "Unable to retrieve the account profile. Gmail reported an internal server error (status code 501).")
        
        error = ApiError.statusCode(apiLabel: "Gmail", operationLabel: "retrieve the account profile", statusCode: 429)
        XCTAssertEqual(error.combinedErrorMessage, "Unable to retrieve the account profile. Gmail rejected the request because too many requests have been sent within a short period of time.")
        
        error = ApiError.statusCode(apiLabel: "Gmail", operationLabel: "retrieve the account profile", statusCode: 302)
        XCTAssertEqual(error.combinedErrorMessage, "Unable to retrieve the account profile. Gmail responded with a redirect.")
        
        error = ApiError.interpretResponse(apiLabel: "Gmail", operationLabel: "retrieve the account profile")
        XCTAssertEqual(error.combinedErrorMessage, "Unable to retrieve the account profile. Gmail returned a response that could not be parsed.")
        
        error = ApiError.errorMessageFromServer(apiLabel: "Gmail", operationLabel: "retrieve the account profile", message: "because")
        XCTAssertEqual(error.combinedErrorMessage, "Unable to retrieve the account profile. Because.")
        
        error = ApiError.urlSessionUnexpectedResponse(apiLabel: "Gmail", operationLabel: "retrieve the account profile")
        XCTAssertEqual(error.combinedErrorMessage, "Unable to retrieve the account profile. An unexpected NSURLSession-level error occurred when communicating with Gmail.")
        
        error = ApiError.retrieveRefreshTokenFromKeychain(apiLabel: "Gmail", operationLabel: "reauthenticate")
        XCTAssertEqual(error.combinedErrorMessage, "Unable to reauthenticate. The keychain did not return the refresh token.")
        
        error = ApiError.statusCode(apiLabel: "Gmail", operationLabel: "delete filter", statusCode: 401)
        XCTAssertEqual(error.combinedErrorMessage, "Unable to delete filter. Gmail did not accept the credentials. Please try logging out and logging back in.")
        
        error = ApiError.statusCode(apiLabel: "Gmail", operationLabel: "create filter after deleting old version", statusCode: 401)
        XCTAssertEqual(error.combinedErrorMessage, "Unable to create filter after deleting old version. Gmail did not accept the credentials. Please try logging out and logging back in.")
    }
    
    func testConvertToSentence() {
        let error = ApiError.interpretResponse(apiLabel: "Gmail", operationLabel: "")
        XCTAssertTrue(error.convertToSentence(serverError: nil) == nil)
        XCTAssertTrue(error.convertToSentence(serverError: "") == nil)
        XCTAssertEqual(error.convertToSentence(serverError: "This is my car."), "This is my car.")
        XCTAssertEqual(error.convertToSentence(serverError: "This is my car?"), "This is my car?")
        XCTAssertEqual(error.convertToSentence(serverError: "This is my car!"), "This is my car!")
        XCTAssertEqual(error.convertToSentence(serverError: "This is my car"), "This is my car.")
        
        XCTAssertEqual(error.convertToSentence(serverError: "this is my car."), "This is my car.")
        XCTAssertEqual(error.convertToSentence(serverError: "this is my car"), "This is my car.")
        
        XCTAssertEqual(error.convertToSentence(serverError: "https://www.goldenhillsoftware.com/"), "https://www.goldenhillsoftware.com/")
        XCTAssertEqual(error.convertToSentence(serverError: "https://www.goldenhillsoftware.com/ is not available"), "https://www.goldenhillsoftware.com/ is not available.")
        XCTAssertEqual(error.convertToSentence(serverError: "the page at https://www.goldenhillsoftware.com/ is not available"), "The page at https://www.goldenhillsoftware.com/ is not available.")
        XCTAssertEqual(error.convertToSentence(serverError: "More details are at https://www.goldenhillsoftware.com/"), "More details are at https://www.goldenhillsoftware.com/.")
    }
    
}
