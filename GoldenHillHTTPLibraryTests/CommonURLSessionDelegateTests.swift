//
//  CommonURLSessionDelegateTests.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/3/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import XCTest
@testable import GoldenHillHTTPLibrary

class CommonURLSessionDelegateTests: XCTestCase {
    
    func testIsHttps() {
        let delegate = CommonURLSessionDelegate(followRedirects: .always, certificateUrls: nil)
        
        XCTAssertTrue(delegate.isHttps(url: URL(string: "https://www.goldenhillsoftware.com/")!))
        XCTAssertTrue(delegate.isHttps(url: URL(string: "htTPS://www.goldenhillsoftware.com/")!))
        
        XCTAssertFalse(delegate.isHttps(url: URL(string: "http://www.goldenhillsoftware.com/")!))
        XCTAssertFalse(delegate.isHttps(url: URL(string: "FTP://www.goldenhillsoftware.com/")!))
        XCTAssertFalse(delegate.isHttps(url: nil))
    }
    
    func testFollowRedirect() {
        
        let httpUrl = URL(string: "http://www.goldenhillsoftware.com/")!
        let httpsUrl = URL(string: "https://www.goldenhillsoftware.com/")!
        let nilUrl: URL? = nil
        
        var delegate = CommonURLSessionDelegate(followRedirects: .always, certificateUrls: nil)
        XCTAssertTrue(delegate.followRedirect(toUrl: httpUrl))
        XCTAssertTrue(delegate.followRedirect(toUrl: httpsUrl))
        XCTAssertTrue(delegate.followRedirect(toUrl: nilUrl))
        
        delegate = CommonURLSessionDelegate(followRedirects: .never, certificateUrls: nil)
        XCTAssertFalse(delegate.followRedirect(toUrl: httpUrl))
        XCTAssertFalse(delegate.followRedirect(toUrl: httpsUrl))
        XCTAssertFalse(delegate.followRedirect(toUrl: nilUrl))
        
        delegate = CommonURLSessionDelegate(followRedirects: .httpsOnly, certificateUrls: nil)
        XCTAssertFalse(delegate.followRedirect(toUrl: httpUrl))
        XCTAssertTrue(delegate.followRedirect(toUrl: httpsUrl))
        XCTAssertFalse(delegate.followRedirect(toUrl: nilUrl))
    }
    
}
