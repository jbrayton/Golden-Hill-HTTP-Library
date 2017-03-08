//
//  FollowRedirects.swift
//  GoldenHillHTTPLibrary
//
//  Created by John Brayton on 3/8/17.
//  Copyright © 2017 John Brayton. All rights reserved.
//

import Foundation

public enum FollowRedirects {
    case always
    case never
    case httpsOnly
    case httpsOnlyWhenFromHttps
}
