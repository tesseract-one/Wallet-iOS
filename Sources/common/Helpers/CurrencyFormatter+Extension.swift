//
//  CurrencyFormatter+Extension.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/10/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

extension NumberFormatter {
    public static let usd: NumberFormatter = {
        let usdFormatter = NumberFormatter()
        usdFormatter.numberStyle = .currencyISOCode
        usdFormatter.locale = Locale(identifier: "de_DE")
        usdFormatter.internationalCurrencySymbol = " USD"
        return usdFormatter
    }()
    
    public static let eth: NumberFormatter = {
        let usdFormatter = NumberFormatter()
        usdFormatter.numberStyle = .currencyISOCode
        usdFormatter.maximumFractionDigits = 6
        usdFormatter.locale = Locale(identifier: "de_DE")
        usdFormatter.internationalCurrencySymbol = " ETH"
        return usdFormatter
    }()
    
    public static let decimal: NumberFormatter = {
        let decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = .decimal
        return decimalFormatter
    }()
}
