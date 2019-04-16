//
//  TransactionTableViewCell.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/5/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import BigInt
import ReactiveKit
import Bond


class TransactionTableViewCell: UITableViewCell {
    let Bag = DisposeBag()
    
    private static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a, MMM d"
        return fmt
    }()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountETHLabel: UILabel!
    @IBOutlet weak var amountUSDLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var address: String = ""
    let rate = Property<Double?>(nil)
    
    var model: EthereumTransactionLog? = nil {
        willSet {
            unadvise()
        }
        didSet {
            advice()
        }
    }
    
    func advice() {
        let amountSymbol: String

        if model!.from.lowercased() == address.lowercased() {
            titleLabel.text = "Sent Transaction"
            descriptionLabel.text = "Sent to \(truncAddress(model!.to))."
            amountETHLabel.textColor = .white
            amountSymbol = "-"
        } else {
            titleLabel.text = "Received Transaction"
            descriptionLabel.text = "\(truncAddress(model!.from)) sent you."
            amountETHLabel.textColor = UIColor(red: 0.3, green: 0.85, blue: 0.39, alpha: 1)
            amountSymbol = "+"
        }
        
        let amount = BigUInt(model!.value, radix: 10)!.ethValue()
        amountETHLabel.text = amountSymbol + NumberFormatter.eth.string(from: amount as NSNumber)!
        dateLabel.text = TransactionTableViewCell.dateFormatter.string(from: Date(timeIntervalSince1970: Double(UInt64(model!.timeStamp)!)))
        
        rate.filter { $0 != nil }
            .map { amountSymbol + NumberFormatter.usd.string(from: (amount * $0!) as NSNumber)! }
            .bind(to: amountUSDLabel.reactive.text)
            .dispose(in: bag)
    }
    
    func setValues(address: String, rate: Property<Double>) {
        self.address = address
        rate.bind(to: self.rate).dispose(in: Bag)
    }
    
    private func truncAddress(_ address: String) -> String {
        return "\(address.prefix(7))...\(address.suffix(4))"
    }
    
    func unadvise() {
        Bag.dispose()
    }
    
    deinit {
        Bag.dispose()
    }
}
