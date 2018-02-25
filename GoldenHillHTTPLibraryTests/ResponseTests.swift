//
//  ResponseTests.swift
//  Unit Tests
//
//  Created by John Brayton on 2/25/18.
//  Copyright © 2018 John Brayton. All rights reserved.
//

import XCTest

class ResponseTests: XCTestCase {
    
    func testExample() {
        let linkHeaderValue = "<https://api.feedbin.com/v2/saved_searches/5122.json?page=2>; rel=\"next\", <💩>; rel=\"notaurl\", <https://api.feedbin.com/v2/saved_searches/5122.json?page=196>; rel=\"last\""
        let response = HTTPURLResponse(url: URL(string: "https://www.foobar.com/")!, statusCode: 200, httpVersion: "1.1", headerFields: ["Link": linkHeaderValue])!
        
        self.assert(response: response, linkHeaderName: "foo", linkName: "bar", hasURLString: nil, file: #file, line: #line)
        self.assert(response: response, linkHeaderName: "Link", linkName: "bar", hasURLString: nil, file: #file, line: #line)
        self.assert(response: response, linkHeaderName: "Link", linkName: "next", hasURLString: "https://api.feedbin.com/v2/saved_searches/5122.json?page=2", file: #file, line: #line)
        self.assert(response: response, linkHeaderName: "Link", linkName: "last", hasURLString: "https://api.feedbin.com/v2/saved_searches/5122.json?page=196", file: #file, line: #line)
        self.assert(response: response, linkHeaderName: "Link", linkName: "notaurl", hasURLString: nil, file: #file, line: #line)

        // case-insensitivity
        self.assert(response: response, linkHeaderName: "LINK", linkName: "NEXT", hasURLString: "https://api.feedbin.com/v2/saved_searches/5122.json?page=2", file: #file, line: #line)
        self.assert(response: response, linkHeaderName: "LINK", linkName: "LAST", hasURLString: "https://api.feedbin.com/v2/saved_searches/5122.json?page=196", file: #file, line: #line)
 
        self.assert(response: response, linkHeaderName: "z", linkName: "LAST", hasURLString: nil, file: #file, line: #line)
    }
    
    private func assert( response: HTTPURLResponse, linkHeaderName: String, linkName: String, hasURLString expectedUrlString: String?, file: StaticString, line: UInt ) {
        let url = response.ghs_link(forHeaderNamed: linkHeaderName, linkNamed: linkName)
        if let expected = expectedUrlString {
            XCTAssertEqual(url?.absoluteString, expected, file: file, line: line)
        } else {
            XCTAssert(url == nil, file: file, line: line)
        }
    }
    
}
