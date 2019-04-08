//
//  HTTPURLResponse+RedirectType.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/3/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import Foundation


public extension HTTPURLResponse {
    
    func ghs_value(forHeaderNamed requestedHeaderName: String) -> String? {
        for (name, value) in self.allHeaderFields {
            if let headerName = name as? String, let headerValue = value as? String {
                if headerName.lowercased() == requestedHeaderName.lowercased() {
                    return headerValue
                }
            }
        }
        return nil
    }
    
    func ghs_link(forHeaderNamed requestedHeaderName: String, linkNamed requestedLinkName: String ) -> URL? {
        guard let headerValue = self.ghs_value(forHeaderNamed: requestedHeaderName) else {
            return nil
        }
        let components = headerValue.components(separatedBy: ",")
        for component in components {
            let mutableComponent = NSMutableString(string: component)
            let patternString = String(format: " *<(.*)>; rel=\"?%@\"? *", requestedLinkName)
            if let pattern = try? NSRegularExpression(pattern: patternString, options: [.caseInsensitive]) {
                if let firstMatch = pattern.firstMatch(in: component, options: [], range: NSMakeRange(0, component.utf16.count)) {
                    let urlString = mutableComponent.substring(with: firstMatch.range(at: 1))
                    return URL(string: urlString)
                }
            }
        }
        return nil
    }
    
    var ghs_redirectType: RedirectType {
        switch self.statusCode {
        case 301, 303, 308:
            return .permanent
        case 302, 307:
            return .temporary
        default:
            return .none
        }
    }

}
