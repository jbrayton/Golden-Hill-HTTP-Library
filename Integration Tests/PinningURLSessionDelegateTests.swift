//
//  PinningURLSessionDelegateTests.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/8/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import XCTest
import GoldenHillHTTPLibrary

class PinningURLSessionDelegateTests: XCTestCase {
    
    let validPinHashes = ["foobar", "7w4E+8JiJam+EcU5XK8lIPI1qyOtqhwetESyii8GYXs=", "yo"]
    
    func testPinning() {
        
        let testUrlString = "https://unreadapi.goldenhillsoftware.com/test.txt"
        
        let delegate = PinningURLSessionDelegate( followRedirects: FollowRedirects.always, publicKeyHashes: validPinHashes )
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: delegate, delegateQueue: nil)
        let url = URL(string: testUrlString)!
        
        // Validate that we can access unreadapi.goldenhillsoftware.com as expected.
        var expectation = self.expectation(description: "test")
        var dataTask = session.dataTask(with: url) { (data, response, error) in
            if let httpUrlResponse = response as? HTTPURLResponse {
                XCTAssertTrue(httpUrlResponse.statusCode == 200)
                XCTAssertEqual(httpUrlResponse.url?.absoluteString, testUrlString)
            } else if let e = error {
                XCTFail(e.localizedDescription)
            } else {
                XCTFail()
            }
            expectation.fulfill()
        }
        dataTask.resume()
        self.waitForExpectations(timeout: 60, handler: nil)

        // The pinned certificate should *not* work for www.goldenhillsoftware.com
        expectation = self.expectation(description: "test")
        dataTask = session.dataTask(with: URL(string: "https://www.goldenhillsoftware.com/")!) { (data, response, error) in
            guard let e = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(e.localizedDescription, "cancelled")
            expectation.fulfill()
        }
        dataTask.resume()
        self.waitForExpectations(timeout: 60, handler: nil)
    }
    
    /*
        Verify that this fails.
     */
    func testBadPinning() {
        
        let testUrlString = "https://unreadapi.goldenhillsoftware.com/test.txt"
        
        let delegate = PinningURLSessionDelegate( followRedirects: FollowRedirects.always, publicKeyHashes: ["foobar", "8w4E+8JiJam+EcU5XK8lIPI1qyOtqhwetESyii8GYXs=", "yo"] )
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: delegate, delegateQueue: nil)
        let url = URL(string: testUrlString)!
        
        // Validate that we can access unreadapi.goldenhillsoftware.com as expected.
        var expectation = self.expectation(description: "test")
        var dataTask = session.dataTask(with: url) { (data, response, error) in
            XCTAssert(data == nil && response == nil && error != nil)
            expectation.fulfill()
        }
        dataTask.resume()
        self.waitForExpectations(timeout: 60, handler: nil)

        // The pinned certificate should *not* work for www.goldenhillsoftware.com
        expectation = self.expectation(description: "test")
        dataTask = session.dataTask(with: URL(string: "https://www.goldenhillsoftware.com/")!) { (data, response, error) in
            guard let e = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(e.localizedDescription, "cancelled")
            expectation.fulfill()
        }
        dataTask.resume()
        self.waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testShouldFollowRedirects() {
        
        let delegate = PinningURLSessionDelegate(followRedirects: .always, publicKeyHashes: validPinHashes )
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: delegate, delegateQueue: nil)
        let url = URL(string: "https://unreadapi.goldenhillsoftware.com/redirecttest")!
        
        let expectation = self.expectation(description: "test")
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let httpUrlResponse = response as? HTTPURLResponse {
                XCTAssertTrue(httpUrlResponse.statusCode == 200)
                XCTAssertEqual(httpUrlResponse.url?.absoluteString, "https://unreadapi.goldenhillsoftware.com/test.txt")
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
        
        let delegate = PinningURLSessionDelegate( followRedirects: FollowRedirects.never, publicKeyHashes: validPinHashes )

        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: delegate, delegateQueue: nil)
        let url = URL(string: "https://unreadapi.goldenhillsoftware.com/redirecttest")!
        
        let expectation = self.expectation(description: "test")
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let httpUrlResponse = response as? HTTPURLResponse {
                XCTAssertTrue(httpUrlResponse.statusCode == 301)
                XCTAssertEqual(httpUrlResponse.url?.absoluteString, "https://unreadapi.goldenhillsoftware.com/redirecttest")
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
