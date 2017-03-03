//
//  HTTPURLResponse+RedirectType.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/3/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import Foundation


public enum RedirectType {
    case temporary
    case permanent
    case none
}

public extension HTTPURLResponse {
    
    public func ghs_value(forHeaderNamed x: String) -> String? {
        for (name, value) in self.allHeaderFields {
            if let headerName = name as? String, let headerValue = value as? String {
                if headerName.lowercased() == x.lowercased() {
                    return headerValue
                }
            }
        }
        return nil
    }
    
    public var ghs_redirectType: RedirectType {
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
