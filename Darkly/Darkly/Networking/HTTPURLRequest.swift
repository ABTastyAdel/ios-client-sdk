//
//  HTTPURLRequest.swift
//  Darkly_iOS
//
//  Created by Mark Pokorny on 2/8/18. +JMJ
//  Copyright © 2018 LaunchDarkly. All rights reserved.
//

import Foundation

extension URLRequest {
    struct HTTPMethods {
        //swiftlint:disable:next identifier_name
        static let get = "GET"
        static let post = "POST"
        static let report = "REPORT"
    }
}
