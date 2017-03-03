//
//  CommonURLSessionDelegate.swift
//  GoldenHillFoundationAdditions
//
//  Created by John Brayton on 10/17/16.
//
//

import Foundation

public class CommonURLSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    public enum FollowRedirects {
        case always
        case never
        case httpsOnly
    }
    
    let followRedirects: FollowRedirects
    let certificateUrls: [URL]?
    
    public init( followRedirects: FollowRedirects ) {
        self.followRedirects = followRedirects
        self.certificateUrls = nil
    }
    
    public init( followRedirects: FollowRedirects, certificateUrls: [URL]? ) {
        self.followRedirects = followRedirects
        self.certificateUrls = certificateUrls
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Swift.Void) {
        
        if self.followRedirect(toUrl: request.url) {
            completionHandler(request)
        } else {
            completionHandler(nil)
        }
    }
    
    func followRedirect( toUrl url: URL? ) -> Bool {
        switch self.followRedirects {
        case .always:
            return true
        case .never:
            return false
        case .httpsOnly:
            return self.isHttps(url: url)
        }
    }
    
    func isHttps( url: URL? ) -> Bool {
        return url?.scheme?.lowercased() == "https"
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Initial version from http://stackoverflow.com/questions/34223291/ios-certificate-pinning-with-swift-and-nsurlsession
        // That was adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS
        
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {

                guard let certUrls = self.certificateUrls else {
                    completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                    return
                }
                
                if var secresult = SecTrustResultType(rawValue: SecTrustResultType.invalid.rawValue) {
                    let status = SecTrustEvaluate(serverTrust, &secresult)
                    
                    if(errSecSuccess == status) {
                        if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                            let serverCertificateData = SecCertificateCopyData(serverCertificate) as CFData
                            let data = CFDataGetBytePtr(serverCertificateData);
                            let size = CFDataGetLength(serverCertificateData);
                            let cert1 = Data(bytes: UnsafePointer<UInt8>(data!), count: size)
                            for certificateUrl in certUrls {
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
