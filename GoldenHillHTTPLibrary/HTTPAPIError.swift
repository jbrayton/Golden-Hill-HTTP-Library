//
//  HTTPAPIError.swift
//  Subscribe
//
//  Created by John Brayton on 2/10/16.
//  Copyright © 2016 Golden Hill Software. All rights reserved.
//

import Foundation

public enum HTTPAPIError: Error {
    case connection(apiLabel: String, operationLabel: String, error: Error)
    case statusCode(apiLabel: String, operationLabel: String, statusCode: Int)
    case interpretResponse(apiLabel: String, operationLabel: String)
    case errorMessageFromServer(apiLabel: String, operationLabel: String, message: String?)
    case urlSessionUnexpectedResponse(apiLabel: String, operationLabel: String)
    case retrieveRefreshTokenFromKeychain(apiLabel: String, operationLabel: String)
    case incorrectPassword(apiLabel: String, operationLabel: String, usernameType: UsernameType)
    case responseNotJson(apiLabel: String, operationLabel: String, contentType: String?)
    
    public var shortErrorMessage: String {
        
        switch self {
        case .connection(_, let operationLabel, _):
            return self.getShortErrorMessage(operationLabel: operationLabel)
        case .statusCode(_, let operationLabel, _):
            return self.getShortErrorMessage(operationLabel: operationLabel)
        case .interpretResponse(_, let operationLabel):
            return self.getShortErrorMessage(operationLabel: operationLabel)
        case .errorMessageFromServer(_, let operationLabel, _):
            return self.getShortErrorMessage(operationLabel: operationLabel)
        case .urlSessionUnexpectedResponse(_, let operationLabel):
            return self.getShortErrorMessage(operationLabel: operationLabel)
        case .retrieveRefreshTokenFromKeychain(_, let operationLabel):
            return self.getShortErrorMessage(operationLabel: operationLabel)
        case .incorrectPassword(_, let operationLabel, _):
            return self.getShortErrorMessage(operationLabel: operationLabel)
        case .responseNotJson(_, let operationLabel, _):
            return self.getShortErrorMessage(operationLabel: operationLabel)
        }
    }
    
    public var detailedErrorMessage: String {
        return self.getDetailedErrorMessageInternal()
    }
    
    public var combinedErrorMessage: String {
        return String.localizedStringWithFormat("%@. %@", self.shortErrorMessage, self.detailedErrorMessage)
    }
    
    public var operationLabel: String {
        switch self {
        case .connection(_, let operationLabel, _):
            return operationLabel
        case .statusCode(_, let operationLabel, _):
            return operationLabel
        case .interpretResponse(_, let operationLabel):
            return operationLabel
        case .errorMessageFromServer(_, let operationLabel, _):
            return operationLabel
        case .urlSessionUnexpectedResponse(_, let operationLabel):
            return operationLabel
        case .retrieveRefreshTokenFromKeychain(_, let operationLabel):
            return operationLabel
        case .incorrectPassword(_, let operationLabel, _):
            return operationLabel
        case .responseNotJson(_, let operationLabel, _):
            return operationLabel
        }
    }
    
    private func getDetailedErrorMessageInternal() -> String {
        switch self {
        case .connection(let apiLabel, _, let error):
            return String.localizedStringWithFormat("Could not connect to %@. %@", apiLabel, error.localizedDescription)
        case .statusCode(let apiLabel, _, let statusCode):
            if ((statusCode == 420) || (statusCode == 429)) {
                return String.localizedStringWithFormat("%@ rejected the request because too many requests have been sent within a short period of time.", apiLabel)
            }
            if (statusCode == 404) {
                return String.localizedStringWithFormat("%@ rejected the request (not found).", apiLabel)
            }
            if ((statusCode >= 400) && (statusCode < 500)) {
                return String.localizedStringWithFormat("%@ rejected the request (status code %d).", apiLabel, statusCode)
            }
            if (statusCode >= 500) {
                return String.localizedStringWithFormat("%@ reported an internal server error (status code %d).", apiLabel, statusCode)
            }
            if ([301, 303, 308, 302, 307].contains(statusCode)) {
                return String.localizedStringWithFormat("%@ responded with a redirect.", apiLabel)
            }
            return String.localizedStringWithFormat("%@ returned an unexpected status code (%d).", apiLabel, statusCode)
        case .interpretResponse(let apiLabel, _):
            return String.localizedStringWithFormat("%@ returned a response that could not be parsed.", apiLabel)
        case .errorMessageFromServer(let apiLabel, _, let message):
            if let m = convertToSentence(serverError: message) {
                return m
            } else {
                return String.localizedStringWithFormat("%@ did not provide an error message.", apiLabel)
            }
        case .urlSessionUnexpectedResponse(let apiLabel, _):
            return String.localizedStringWithFormat("An unexpected NSURLSession-level error occurred when communicating with %@.", apiLabel)
        case .retrieveRefreshTokenFromKeychain(_, _):
            return String.localizedStringWithFormat("The keychain did not return the refresh token.")
        case .incorrectPassword(let apiLabel, _, let usernameType):
            var usernameString = String.localizedStringWithFormat("username")
            if usernameType == UsernameType.emailAddress {
                usernameString = String.localizedStringWithFormat("email address")
            }
            return String.localizedStringWithFormat("%@ rejected the %@ and password combination.", apiLabel, usernameString)
        case .responseNotJson(let apiLabel, _, let contentType):
            var appName = "App"
            if let nonNullAppName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
                appName = nonNullAppName
            }
            if let ct = contentType {
                return String.localizedStringWithFormat("%@ returned a response with a MIME type of %@. %@ expected JSON.", apiLabel, ct, appName)
            } else {
                return String.localizedStringWithFormat("%@ returned a response without a Content-Type header. %@ expected JSON.", apiLabel, appName)
            }
        }
        
    }
    
    private func getShortErrorMessage( operationLabel: String) -> String {
        return String.localizedStringWithFormat("Unable to %@", operationLabel)
    }
    
    func convertToSentence( serverError: String? ) -> String? {
        if var serverErrorMessage = serverError {
            if (serverErrorMessage.count == 0) {
                return nil
            }
            
            var startsWithLink = false
            var entirelyLink = false
            let linkType: NSTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
            if let dataDetector = try? NSDataDetector(types: linkType) {
                dataDetector.enumerateMatches(in: serverErrorMessage, options: [], range: NSMakeRange(0, (serverErrorMessage as NSString).length)) { (result, flags, _) in
                    if (result?.range.location == 0) {
                        startsWithLink = true
                        if (result?.range.length == serverErrorMessage.count) {
                            entirelyLink = true
                        }
                    }
                }
            }
            
            if (entirelyLink) {
                return serverErrorMessage
            }
            
            let endPunctuation = [".", "?", "!"]
            var endsWithPunctuation = false
            for endChar in endPunctuation {
                if serverErrorMessage.hasSuffix(endChar) {
                    endsWithPunctuation = true
                    break
                }
            }
            if (!endsWithPunctuation) {
                serverErrorMessage.append("." as Character)
            }
            // From http://stackoverflow.com/questions/26306326/swift-apply-uppercasestring-to-only-the-first-letter-of-a-string
            if (!startsWithLink) {
                serverErrorMessage = serverErrorMessage.ghs_capitalizingFirstLetter()
            }
            return serverErrorMessage
        } else {
            return nil
        }
    }
    
}
