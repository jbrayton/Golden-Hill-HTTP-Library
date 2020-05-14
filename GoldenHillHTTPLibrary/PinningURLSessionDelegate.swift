//
//  PinningURLSessionDelegate.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/8/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import Foundation

@objc
public class PinningURLSessionDelegate: SimpleURLSessionDelegate {
    
    let publicKeyHashes: [String]

    /*
        The certificateUrls should be an array of URL objects from the app bundle. The certificates
        must be in DER format.
    */
    @objc
    public init( followRedirects: Bool, publicKeyHashes: [String] ) {
        self.publicKeyHashes = publicKeyHashes
        let followRedirectsEnum: FollowRedirects = followRedirects ? FollowRedirects.always : FollowRedirects.never
        super.init(followRedirects: followRedirectsEnum)
    }
    
   public init( followRedirects: FollowRedirects, publicKeyHashes: [String] ) {
        self.publicKeyHashes = publicKeyHashes
        super.init(followRedirects: followRedirects)
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {

        // Adapted from OWASP https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS

        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)

                if(isServerTrusted) {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        // Server public key
                        let serverPublicKey = SecCertificateCopyKey(serverCertificate)
                        let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil )!
                        let data:Data = serverPublicKeyData as Data
                        // Server Hash key
                        let serverHashKey = sha256(data: data)
                        // Local Hash Key
                        if (self.publicKeyHashes.contains(where: { (str) -> Bool in
                            str == serverHashKey
                        })) {
                            // Success! This is our server
                            print("Public key pinning is successfully completed")
                            completionHandler(.useCredential, URLCredential(trust:serverTrust))
                            return
                        }
                    }
                }
            }
        }

        // Pinning failed
        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
    }

    let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]

    private func sha256(data : Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = keyWithHeader.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> Void in
            _ = CC_SHA256(ptr.baseAddress, CC_LONG(keyWithHeader.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }

}
