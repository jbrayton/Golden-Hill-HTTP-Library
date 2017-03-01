//
//  ApiResult.swift
//  Filters
//
//  Created by John Brayton on 10/2/16.
//  Copyright © 2016 John Brayton. All rights reserved.
//

import Foundation
import Result

public typealias ApiResult<T> = Result<T,ApiError>

public typealias ApiResultHandler<T> = (Result<T,ApiError>) -> Void
