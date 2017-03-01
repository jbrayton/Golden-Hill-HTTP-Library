//
//  PinningURLSessionDelegate.swift
//  GoldenHillFoundationAdditions
//
//  Created by John Brayton on 10/17/16.
//
//

import Foundation

public class PinningURLSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    let followRedirects: Bool
    let certificateUrls: [URL]
    
    public init( followRedirects: Bool, certificateUrls: [URL] ) {
        self.followRedirects = followRedirects
        self.certificateUrls = certificateUrls
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Swift.Void) {
        if (self.followRedirects) {
            completionHandler(request)
        } else {
            completionHandler(nil)
        }
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Taken from http://stackoverflow.com/questions/34223291/ios-certificate-pinning-with-swift-and-nsurlsession
        // That was adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS
        
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                if var secresult = SecTrustResultType(rawValue: SecTrustResultType.invalid.rawValue) {
                    let status = SecTrustEvaluate(serverTrust, &secresult)
                    
                    if(errSecSuccess == status) {
                        if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                            let serverCertificateData = SecCertificateCopyData(serverCertificate) as CFData
                            let data = CFDataGetBytePtr(serverCertificateData);
                            let size = CFDataGetLength(serverCertificateData);
                            let cert1 = Data(bytes: UnsafePointer<UInt8>(data!), count: size)
                            for certificateUrl in self.certificateUrls {
                                if let cert2 = try? Data(contentsOf: certificateUrl) {
                                    if cert1 == cert2 {
                                        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        // Pinning failed
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }
}
