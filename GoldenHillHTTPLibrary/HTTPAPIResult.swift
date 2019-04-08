//
//  HTTPAPIResult.swift
//  Filters
//
//  Created by John Brayton on 10/2/16.
//  Copyright © 2016 John Brayton. All rights reserved.
//

import Foundation

public typealias HTTPAPIResult<T> = Result<T,HTTPAPIError>

public typealias HTTPAPIResultHandler<T> = (Result<T,HTTPAPIError>) -> Void
