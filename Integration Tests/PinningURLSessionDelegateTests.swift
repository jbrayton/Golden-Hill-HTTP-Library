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
    
    func testPinning() {
        
        let testUrlString = "https://marcato-api.goldenhillsoftware.com/test.txt"
        
        guard let certificateUrl = Bundle(for: PinningURLSessionDelegateTests.self).url(forResource: "marcato-api", withExtension: "der") else {
            XCTFail()
            return
        }
        
        let delegate = PinningURLSessionDelegate( followRedirects: FollowRedirects.always, certificateUrls: [certificateUrl] )
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: delegate, delegateQueue: nil)
        let url = URL(string: testUrlString)!
        
        // Validate that we can access marcato-api.goldenhillsoftware.com as expected.
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
    
    func testShouldFollowRedirects() {
        
        guard let certificateUrl = Bundle(for: PinningURLSessionDelegateTests.self).url(forResource: "marcato-api", withExtension: "der") else {
            XCTFail()
            return
        }
        let delegate = PinningURLSessionDelegate(followRedirects: .always, certificateUrls: [certificateUrl])
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: delegate, delegateQueue: nil)
        let url = URL(string: "https://marcato-api.goldenhillsoftware.com/redirecttest")!
        
        let expectation = self.expectation(description: "test")
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let httpUrlResponse = response as? HTTPURLResponse {
                XCTAssertTrue(httpUrlResponse.statusCode == 200)
                XCTAssertEqual(httpUrlResponse.url?.absoluteString, "https://marcato-api.goldenhillsoftware.com/test.txt")
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
        
        guard let certificateUrl = Bundle(for: PinningURLSessionDelegateTests.self).url(forResource: "marcato-api", withExtension: "der") else {
            XCTFail()
            return
        }
        
        let delegate = PinningURLSessionDelegate( followRedirects: FollowRedirects.never, certificateUrls: [certificateUrl] )

        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: delegate, delegateQueue: nil)
        let url = URL(string: "https://marcato-api.goldenhillsoftware.com/redirecttest")!
        
        let expectation = self.expectation(description: "test")
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let httpUrlResponse = response as? HTTPURLResponse {
                XCTAssertTrue(httpUrlResponse.statusCode == 301)
                XCTAssertEqual(httpUrlResponse.url?.absoluteString, "https://marcato-api.goldenhillsoftware.com/redirecttest")
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
