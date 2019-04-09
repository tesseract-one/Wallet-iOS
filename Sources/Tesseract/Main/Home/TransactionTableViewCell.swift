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
        let addressTrunced = "\(address.prefix(7))...\(address.suffix(4))"
        
        if model!.from == address {
            titleLabel.text = "Sent Transaction"
            descriptionLabel.text = "Sent to \(addressTrunced)."
            amountETHLabel.textColor = .white
            amountSymbol = "-"
        } else {
            titleLabel.text = "Received Transaction"
            descriptionLabel.text = "\(addressTrunced) sent you."
            amountETHLabel.textColor = UIColor(red: 0.3, green: 0.85, blue: 0.39, alpha: 1)
            amountSymbol = "+"
        }
        
        let amount = BigUInt(model!.value, radix: 10)!.ethValue()
        amountETHLabel.text = "\(amountSymbol)\(amount.rounded(toPlaces: 6)) ETH"
        dateLabel.text = TransactionTableViewCell.dateFormatter.string(from: Date(timeIntervalSince1970: Double(UInt64(model!.timeStamp)!)))
        
        rate.filter { $0 != nil }
            .map { "\(amountSymbol)\((amount * $0!).rounded(toPlaces: 2)) USD" }
            .bind(to: amountUSDLabel.reactive.text)
            .dispose(in: bag)
    }
    
    func setValues(address: String, rate: Property<Double>) {
        self.address = address
        rate.bind(to: self.rate).dispose(in: Bag)
    }
    
    func unadvise() {
        Bag.dispose()
    }
    
    deinit {
        Bag.dispose()
    }
}
