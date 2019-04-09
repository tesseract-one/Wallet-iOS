//
//  Bundle+Version.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/9/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var fullVersion: String {
        return "v. \(releaseVersionNumber ?? "") (\(buildVersionNumber ?? ""))"
    }
}
