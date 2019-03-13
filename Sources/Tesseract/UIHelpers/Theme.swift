//
//  Theme.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/13/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Material

extension Theme {
    public static let tesseract: Theme = {
        var theme = Theme()
        
        theme.primary = UIColor(red: 74/255, green: 148/255, blue: 227/255, alpha: 1.0)
        theme.secondary = UIColor(red: 74/255, green: 148/255, blue: 227/255, alpha: 1.0)
        theme.background = UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0)
        theme.surface = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1.0)
        theme.error = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        theme.onPrimary = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        theme.onSecondary = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
        theme.onBackground =  UIColor(red: 62/255, green: 62/255, blue: 62/255, alpha: 1.0)
        theme.onSurface = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
        theme.onError = Color.white
        
        return theme
    }()
}
