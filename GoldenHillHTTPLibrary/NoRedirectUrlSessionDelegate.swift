//
//  NoRedirectUrlSessionDelegate.swift
//  Subscribe
//
//  Created by John Brayton on 2/28/16.
//  Copyright © 2016 Golden Hill Software. All rights reserved.
//

import Foundation

public class NoRedirectUrlSessionDelegate: NSObject, URLSessionDelegate {
    
    public static let delegate = NoRedirectUrlSessionDelegate()

    func URLSession(_ session: Foundation.URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: (URLRequest?) -> Void) {
        completionHandler(nil)
    }

}
