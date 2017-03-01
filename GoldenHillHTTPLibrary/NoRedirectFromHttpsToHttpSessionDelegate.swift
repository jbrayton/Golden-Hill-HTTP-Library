//
//  NoRedirectFromHttpsToHttpSessionDelegate.swift
//  Subscribe
//
//  Created by John Brayton on 8/26/16.
//  Copyright © 2016 Golden Hill Software. All rights reserved.
//

import Foundation

/*
    Allows redirects unless an HTTPS URL is redirecting to an HTTP URL.
*/
public class NoRedirectFromHttpsToHttpSessionDelegate: NSObject, URLSessionDelegate {

    public static let delegate = NoRedirectFromHttpsToHttpSessionDelegate()
    
    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: (URLRequest?) -> Void) {
        
        let oldIsHttps = self.isHttps(url: response.url)
        let newIsHttps = self.isHttps(url: request.url)
        if ((oldIsHttps) && (!newIsHttps)) {
            completionHandler(nil)
        } else {
            completionHandler(request)
        }
    }
    
    fileprivate func isHttps( url: URL? ) -> Bool {
        return url?.scheme?.lowercased() == "https"
    }

}

