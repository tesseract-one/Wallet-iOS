//
//  ChangeRateService.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import TesSDK
import PromiseKit

private struct PResponse: Codable {
    let data: Array<PCoin>
}

private struct PCoin: Codable {
    let id: Int
    let name: String
    let symbol: String
    let quote: Dictionary<String, PQuote>
}

private struct PQuote: Codable {
    let price: Double
}

class ChangeRateService {
    private var timer: Timer!
    private static let API_KEY = "f58e5a6b-473d-422c-8284-dc92b73599d6"
    
    private static let bindings: Dictionary<String, Network> = [
        "Ethereum": .Ethereum
    ]
    
    private (set) var changeRates: Dictionary<Network, Property<Double>> = [
        .Ethereum: Property(1.0)
    ]
    
    func bootstrap() {
        timer = Timer.init(timeInterval: 300.0, repeats: true) { [weak self] _ in
            self?.updateRates()
        }
        self.updateRates()
    }
    
    private func updateRates() {
        let url = URL(string: "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(ChangeRateService.API_KEY, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        URLSession.shared.dataTask(.promise, with: request)
            .validate()
            .map { try JSONDecoder().decode(PResponse.self, from: $0.data) }
            .done { [weak self] response in
                if let sself = self {
                    for coin in response.data {
                        if let net = ChangeRateService.bindings[coin.name],
                           let price = coin.quote["USD"]?.price  {
                            sself.changeRates[net]?.next(price)
                        }
                    }
                }
            }
            .catch { err in
                print("Change Rate Error: ", err)
            }
    }
    
    deinit {
        timer.invalidate()
    }
}
