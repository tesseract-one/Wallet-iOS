//
//  TransactionTableViewCell.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/5/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK

class TransactionTableViewCell: UITableViewCell {

    private static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        fmt.timeStyle = .short
        return fmt
    }()
    
    //MARK: Properties
    //
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setModel(model: EthereumTransactionLog, address: String) {
        if model.from == address {
            titleLabel.text = "Transaction Sent"
            descriptionLabel.text = "Horay"
        } else {
            titleLabel.text = "Transaction Received"
            descriptionLabel.text = "Horay"
        }
        
        amountLabel.text = String(Double(UInt64(model.value)!) / pow(10.0, 18)) + " ETH"
        dateLabel.text = TransactionTableViewCell.dateFormatter.string(from: Date(timeIntervalSince1970: Double(UInt64(model.timeStamp)!)))
    }
}
