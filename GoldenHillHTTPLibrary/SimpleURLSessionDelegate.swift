//
//  CommonURLSessionDelegate.swift
//  GoldenHillFoundationAdditions
//
//  Created by John Brayton on 10/17/16.
//
//

import Foundation

public class SimpleURLSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    let followRedirects: FollowRedirects
    
    public init( followRedirects: FollowRedirects ) {
        self.followRedirects = followRedirects
    }
    
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Swift.Void) {
        
        if self.followRedirect(fromUrl: response.url, toUrl: request.url) {
            completionHandler(request)
        } else {
            completionHandler(nil)
        }
    }
    
    func followRedirect( fromUrl source: URL?, toUrl dest: URL? ) -> Bool {
        switch self.followRedirects {
        case .always:
            return true
        case .never:
            return false
        case .httpsOnly:
            if let destUrl = dest {
                return self.isHttps(url: destUrl)
            } else {
                return false
            }
        case .httpsOnlyWhenFromHttps:
            
            if let destUrl = dest, self.isHttps(url: destUrl) {
                return true
            }
            if let sourceUrl = source, !self.isHttps(url: sourceUrl) {
                return true
            }
            return false
        }
    }
    
    func isHttps( url: URL ) -> Bool {
        return url.scheme?.lowercased() == "https"
    }

}
