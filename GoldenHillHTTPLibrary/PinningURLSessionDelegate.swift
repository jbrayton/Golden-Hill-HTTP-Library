//
//  PinningURLSessionDelegate.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/8/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import Foundation



public class PinningURLSessionDelegate: SimpleURLSessionDelegate {
    
    let certificateUrls: [URL]

    public init( followRedirects: FollowRedirects, certificateUrls: [URL] ) {
        self.certificateUrls = certificateUrls
        super.init(followRedirects: followRedirects)
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Initial version from http://stackoverflow.com/questions/34223291/ios-certificate-pinning-with-swift-and-nsurlsession
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
