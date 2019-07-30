//
//  Constants.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/6/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

private let INFURA_ID: String = "717a1437a0b441f09e058c8349ffbabe"

public let TESSERACT_ETHEREUM_ENDPOINTS: Dictionary<UInt64, String> = [
    1: "https://mainnet.infura.io/v3/\(INFURA_ID)",
    2: "https://ropsten.infura.io/v3/\(INFURA_ID)",
    4: "https://rinkeby.infura.io/v3/\(INFURA_ID)",
    42: "https://kovan.infura.io/v3/\(INFURA_ID)",
]

public let TESSERACT_ETHEREUM_ENDPOINTS_SECRET: String = "52b4cda8a5d64521b7c5ceb031446e96"

public let SHARED_GROUP: String = "group.one.tesseract.wallet.shared"

public let DATABASE_NAME: String = "walletdb.sqlite"

public let TESSERACT_URL_SCHEME: String = "tesseract-one"
