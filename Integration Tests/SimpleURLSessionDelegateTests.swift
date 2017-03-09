//
//  SimpleURLSessionDelegateTests.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/8/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import XCTest
import GoldenHillHTTPLibrary

class SimpleURLSessionDelegateTests: XCTestCase {
    
    func testShouldFollowRedirects() {
        
        let delegate = SimpleURLSessionDelegate(followRedirects: .always)
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: delegate, delegateQueue: nil)
        let url = URL(string: "https://www.goldenhillsoftware.com/feed-hawk")!
        
        let expectation = self.expectation(description: "test")
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let httpUrlResponse = response as? HTTPURLResponse {
                XCTAssertTrue(httpUrlResponse.statusCode == 200)
                XCTAssertEqual(httpUrlResponse.url?.absoluteString, "https://www.goldenhillsoftware.com/feed-hawk/")
            } else if let e = error {
                XCTFail(e.localizedDescription)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        dataTask.resume()
        self.waitForExpectations(timeout: 60, handler: nil)

    }
    
    func testShouldNotFollowRedirects() {
        
        let delegate = SimpleURLSessionDelegate(followRedirects: .never)
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: delegate, delegateQueue: nil)
        let url = URL(string: "https://www.goldenhillsoftware.com/feed-hawk")!
        
        let expectation = self.expectation(description: "test")
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let httpUrlResponse = response as? HTTPURLResponse {
                XCTAssertTrue(httpUrlResponse.statusCode == 301)
                XCTAssertEqual(httpUrlResponse.url?.absoluteString, "https://www.goldenhillsoftware.com/feed-hawk")
            } else if let e = error {
                XCTFail(e.localizedDescription)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        dataTask.resume()
        self.waitForExpectations(timeout: 60, handler: nil)

    }
    
}
