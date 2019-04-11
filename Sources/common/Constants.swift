//
//  Constants.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/6/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

public let TESSERACT_ETHEREUM_ENDPOINTS: Dictionary<UInt64, String> = [
    1: "https://mainnet.infura.io/v3/f20390fe230e46608572ac4378b70668",
    2: "https://ropsten.infura.io/v3/f20390fe230e46608572ac4378b70668",
    3: "https://kovan.infura.io/v3/f20390fe230e46608572ac4378b70668",
    4: "https://rinkeby.infura.io/v3/f20390fe230e46608572ac4378b70668"
]

public let SHARED_GROUP: String = "group.one.tesseract.wallet.shared"

public let DATABASE_NAME: String = "walletdb.sqlite"
