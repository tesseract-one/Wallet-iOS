//
//  NSTextAlignment+Convert.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/23/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

extension NSTextAlignment {
    func convertToCATextLayerAlignmentMode() -> CATextLayerAlignmentMode {
        switch self {
        case .left: return .left
        case .center: return .center
        case .right: return .right
        case .justified: return .justified
        case .natural: return .natural
        default: return .natural
        }
    }
}
