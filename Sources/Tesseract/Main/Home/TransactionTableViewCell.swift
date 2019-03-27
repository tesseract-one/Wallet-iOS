//
//  TransactionTableViewCell.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/5/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK
import BigInt

class TransactionTableViewCell: UITableViewCell {

    private static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
//        fmt.timeStyle = .short
//        fmt.dateStyle = .short
        fmt.dateFormat = "h:mm a, MMM d"
        return fmt
    }()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setModel(model: EthereumTransactionLog, address: String) {
        if model.from == model.to && model.from == address {
            titleLabel.text = "Transaction"
            descriptionLabel.text = "From: me, to: me. 🙃"
        } else if model.from == address {
            titleLabel.text = "Transaction Sent"
            descriptionLabel.text = "To: " + model.to
        } else {
            titleLabel.text = "Transaction Received"
            descriptionLabel.text = "From: " + model.from
            amountLabel.textColor = UIColor(red: 0.3, green: 0.85, blue: 0.39, alpha: 1)
        }
        
        amountLabel.text = String(BigUInt(model.value, radix: 10)!.ethValue()) + " ETH"
        dateLabel.text = TransactionTableViewCell.dateFormatter.string(from: Date(timeIntervalSince1970: Double(UInt64(model.timeStamp)!)))
    }
}
