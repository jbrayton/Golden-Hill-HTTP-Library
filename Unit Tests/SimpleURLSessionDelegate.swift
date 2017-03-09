//
//  SimpleURLSessionDelegateTests.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/3/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import XCTest
@testable import GoldenHillHTTPLibrary

class SimpleURLSessionDelegateTests: XCTestCase {
    
    func testIsHttps() {
        let delegate = SimpleURLSessionDelegate(followRedirects: .always)
        
        XCTAssertTrue(delegate.isHttps(url: URL(string: "https://www.goldenhillsoftware.com/")!))
        XCTAssertTrue(delegate.isHttps(url: URL(string: "htTPS://www.goldenhillsoftware.com/")!))
        
        XCTAssertFalse(delegate.isHttps(url: URL(string: "http://www.goldenhillsoftware.com/")!))
        XCTAssertFalse(delegate.isHttps(url: URL(string: "FTP://www.goldenhillsoftware.com/")!))
    }
    
    func testFollowRedirect() {
        
        let httpUrl = URL(string: "http://www.goldenhillsoftware.com/")!
        let httpsUrl = URL(string: "https://www.goldenhillsoftware.com/")!
        let nilUrl: URL? = nil
        
        var delegate = SimpleURLSessionDelegate(followRedirects: .always)
        XCTAssertTrue(delegate.followRedirect(fromUrl: httpUrl, toUrl: httpUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: httpUrl, toUrl: httpsUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: httpUrl, toUrl: nilUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: httpsUrl, toUrl: httpUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: httpsUrl, toUrl: httpsUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: httpsUrl, toUrl: nilUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: nilUrl, toUrl: httpUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: nilUrl, toUrl: httpsUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: nilUrl, toUrl: nilUrl))
        
        delegate = SimpleURLSessionDelegate(followRedirects: .never)
        XCTAssertFalse(delegate.followRedirect(fromUrl: httpUrl, toUrl: httpUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: httpUrl, toUrl: httpsUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: httpUrl, toUrl: nilUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: httpsUrl, toUrl: httpUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: httpsUrl, toUrl: httpsUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: httpsUrl, toUrl: nilUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: nilUrl, toUrl: httpUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: nilUrl, toUrl: httpsUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: nilUrl, toUrl: nilUrl))
        
        delegate = SimpleURLSessionDelegate(followRedirects: .httpsOnly)
        XCTAssertFalse(delegate.followRedirect(fromUrl: httpUrl, toUrl: httpUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: httpUrl, toUrl: httpsUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: httpUrl, toUrl: nilUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: httpsUrl, toUrl: httpUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: httpsUrl, toUrl: httpsUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: httpsUrl, toUrl: nilUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: nilUrl, toUrl: httpUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: nilUrl, toUrl: httpsUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: nilUrl, toUrl: nilUrl))
        
        delegate = SimpleURLSessionDelegate(followRedirects: .httpsOnlyWhenFromHttps)
        XCTAssertTrue(delegate.followRedirect(fromUrl: httpUrl, toUrl: httpUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: httpUrl, toUrl: httpsUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: httpUrl, toUrl: nilUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: httpsUrl, toUrl: httpUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: httpsUrl, toUrl: httpsUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: httpsUrl, toUrl: nilUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: nilUrl, toUrl: httpUrl))
        XCTAssertTrue(delegate.followRedirect(fromUrl: nilUrl, toUrl: httpsUrl))
        XCTAssertFalse(delegate.followRedirect(fromUrl: nilUrl, toUrl: nilUrl))
    }
    
}
