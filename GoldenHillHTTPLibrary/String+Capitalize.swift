//
//  String+Capitalize.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/1/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import Foundation

extension String {
    
    func ghs_capitalizingFirstLetter() -> String {
        let first = String(self.prefix(1)).capitalized
        let other = String(self.dropFirst())
        return first + other
    }

}
