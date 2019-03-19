//
//  EthereumKeychainSignTypedDataViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/19/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import MaterialTextField
import ReactiveKit
import Bond
import TesSDK
import BigInt

private protocol DataValue {
    var parent: DataType? { get }
    var field: String { get }
    
    func path() -> [DataType]
}

private struct DataPrimitive: DataValue {
    weak var parent: DataType?
    
    let field: String
    let value: String
    
    init(field: String, value: String, parent: DataType? = nil) {
        self.parent = parent
        self.field = field
        self.value = value
    }
    
    func path() -> [DataType] {
        return parent?.path() ?? []
    }
}

private class DataType: DataValue {
    weak var parent: DataType?
    
    let type: String
    let field: String
    var items: [DataValue]
    
    init(type: String, field: String, parent: DataType? = nil) {
        self.type = type
        self.field = field
        self.items = []
        self.parent = parent
    }
    
    func path() -> [DataType] {
        return (parent?.path() ?? []) + [self]
    }
}


private class DataSectionHeaderView: UIView {
    private var path: Array<DataType> = []
    
    var buttonFont: UIFont = UIFont.systemFont(ofSize: 18)
    var spacerFont: UIFont = UIFont(name: "Material-Design-Icons", size: 32)!
    
    var buttonTextColor: UIColor = UIColor.white
    var spacerTextColor: UIColor = UIColor.white
    
    var distance: CGFloat = 8
    
    var onClick: ((DataType) -> Void)!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        let count = subviews.count
        var maxHeight: CGFloat = 0
        for index in 0..<count {
            let view = subviews[index]
            if index == 0 {
                view.frame.origin = CGPoint(x: distance, y: distance)
                maxHeight = view.frame.maxY + distance
            } else {
                let prev = subviews[index-1]
                view.frame.origin = CGPoint(
                    x: prev.frame.maxX + 8,
                    y: prev.frame.minY
                )
                if view.frame.maxX > bounds.maxX - distance {
                    view.frame.origin.y += view.frame.height + distance
                    maxHeight = view.frame.maxY + distance
                }
            }
        }
        if abs(bounds.maxY - maxHeight) > 0.1  {
            frame.size.height = maxHeight
        }
    }
    
    @objc private func buttonClicked(sender: UIButton) {
        onClick(path[sender.tag])
    }
    
    private func createButton(type: DataType) -> UIButton {
        let button = UIButton(frame: .zero)
        let name = type.field != "" ? "\(type.field): \(type.type)" : type.type
        button.setTitle(name, for: .normal)
        button.titleLabel?.font = buttonFont
        button.titleLabel?.textColor = buttonTextColor
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        return button
    }
    
    private func createSpacer() -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = ""
        label.font = spacerFont
        label.textColor = spacerTextColor
        label.sizeToFit()
        return label
    }
    
    fileprivate func setPath(path: Array<DataType>) {
        self.path = path
        for view in subviews {
            view.removeFromSuperview()
        }
        let count = path.count
        for index in 0..<count {
            let button = createButton(type: path[index])
            button.tag = index
            button.isEnabled = index < count - 1
            addSubview(button)
            if count > 1 && index < count - 1 {
                addSubview(createSpacer())
            }
        }
        self.setNeedsLayout()
    }
}

class EthereumKeychainSignTypedDataViewController: EthereumKeychainViewController<OpenWalletEthereumSignTypedDataKeychainRequest>, EthereumKeychainViewControllerBaseControls, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var passwordField: MFTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSectionHeader: DataSectionHeaderView?
    
    fileprivate let account = Property<Account?>(nil)
    fileprivate let selectedItem = Property<DataType?>(nil)
    fileprivate var domainInfo = Array<Any>()
    
    fileprivate var topDataItem: DataType? = nil
    fileprivate var tableData = Array<(Int, DataValue)>()
    
    private let accountSection = 0
    private let domainSection = 1
    private let dataSection = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign Data"
        
        let request = self.request!
        
        domainInfo.append((0, DataPrimitive(field: "domain", value: request.domain.name)))
        domainInfo.append(request.domain.verifyingContract)
        
        setupTable()
        
        topDataItem = parseTypedData()
        
        ensureDataSectionHeader().onClick = { [weak self] item in
            self?.selectedItem.next(item)
        }
        
        selectedItem.observeIn(.immediateOnMain).observeNext { [weak self] item in
            let header = self?.ensureDataSectionHeader()
            header?.setPath(path: item?.path() ?? [])
            header?.layoutSubviews()
        }.dispose(in: reactive.bag)
        
        selectedItem.next(topDataItem)
        
        let ethAcc = request.account
        context.wallet
            .map {
                $0?.accounts.first{
                    ethAcc.lowercased() == (try? $0.eth_address().hex(eip55: false))
                }
            }
            .bind(to: account)
            .dispose(in: reactive.bag)

        account.with(weak: self).observeNext { (_, sself) in
            sself.tableView.reloadSections(
                IndexSet(integer: sself.accountSection), with: .automatic
            )
        }.dispose(in: reactive.bag)
        
        
        runWalletOperation
            .with(latestFrom: context.wallet)
            .with(latestFrom: account)
            .flatMapLatest { (arg, account) -> ResultSignal<Data, AnyError> in
                let (_, wallet) = arg
                return wallet!.eth_signTypedData(
                    account: try! account!.eth_address(),
                    data: EIP712TypedData(
                        primaryType: request.primaryType,
                        types: request.types,
                        domain: request.domain,
                        message: request.message
                    ),
                    networkId: request.networkId
                ).signal
            }
            .pourError(into: context.errors)
            .with(weak: self)
            .observeNext { data, sself in
                sself.succeed(response: "0x" + data.toHexString())
            }.dispose(in: reactive.bag)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case accountSection: return account.value != nil ? 1 : 0
        case domainSection: return domainInfo.count
        case dataSection: return tableData.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: Any
        switch indexPath.section {
        case accountSection:
            item = account.value!
        case domainSection:
            item = domainInfo[indexPath.row]
        case dataSection:
            item = tableData[indexPath.row]
        default:
            fatalError("Wrong section")
        }
        
        switch item {
        case let account as Account:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "AddressCell", for: indexPath
            ) as! EthereumAddressTableViewCell
            cell.setAccount(account: account, header: "Account")
            return cell
        case let address as EthereumAddress:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "AddressCell", for: indexPath
            ) as! EthereumAddressTableViewCell
            cell.setAddress(
                address: address,
                header: "Contract",
                icon: UIImage(named: "Contract")!
            )
            return cell
        case let tuple as (Int, DataType):
            let (level, dataType) = tuple
            let cell = tableView.dequeueReusableCell(withIdentifier: "DataHeaderCell", for: indexPath) as! EthereumDataTypeTableViewCell
            cell.setData(type: dataType.type, field: dataType.field)
            cell.setIndent(level: level)
            return cell
        case let tuple as (Int, DataPrimitive):
            let (level, primitive) = tuple
            let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! TextWithHeaderTableViewCell
            cell.setData(header: primitive.field, data: primitive.value)
            cell.selectionStyle = .none
            cell.setIndent(level: level)
            return cell
        default:
            break
        }
        fatalError("Wrong data type")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2, let item = tableData[indexPath.row].1 as? DataType {
            selectedItem.next(item)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return ensureDataSectionHeader().frame.height
        }
        return 16
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            return ensureDataSectionHeader()
        }
        return nil
    }
}

// Table methods
extension EthereumKeychainSignTypedDataViewController {
    fileprivate func setupTable() {
        tableView.register(
            UINib(nibName:"EthereumAddressTableViewCell", bundle: nil),
            forCellReuseIdentifier: "AddressCell"
        )
        tableView.register(
            UINib(nibName:"EthereumDataTypeTableViewCell", bundle: nil),
            forCellReuseIdentifier: "DataHeaderCell"
        )
        tableView.register(UINib(nibName: "TextWithHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "DataCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        selectedItem.with(weak: self).observeIn(.immediateOnMain).observeNext { item, sself in
            sself.updateTableData(item: item)
        }.dispose(in: reactive.bag)
    }
    
    fileprivate func ensureDataSectionHeader() -> DataSectionHeaderView {
        if dataSectionHeader == nil {
            dataSectionHeader = DataSectionHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
        }
        return dataSectionHeader!
    }
    
    fileprivate func updateTableData(item: DataType?) {
        tableData.removeAll()
        if let item = item {
            for child1 in item.items {
                tableData.append((0, child1))
                if let type = child1 as? DataType {
                    for child2 in type.items {
                        tableData.append((1, child2))
                    }
                }
            }
        }
        
        tableView.reloadSections(IndexSet(integer: dataSection), with: .automatic)
    }
}


// Typed Data Parsing
extension EthereumKeychainSignTypedDataViewController {
    fileprivate func parseTypedData() -> DataType? {
        return createForValue(
            type: request.primaryType,
            field: "",
            obj: .object(request.message)
        ) as? DataType
    }
    
    fileprivate func createForValue(type: String, field: String, obj: SerializableValue, parent: DataType? = nil) -> DataValue? {
        if let fields = request.types[type] { // Complex type
            guard case .object(let object) = obj else { return nil }
            let dataType = DataType(type: type, field: field, parent: parent)
            for field in fields {
                if let value = object[field.name] {
                    if let item = createForValue(type: field.type, field: field.name, obj: value, parent: dataType) {
                        dataType.items.append(item)
                    } else {
                        dataType.items.append(DataPrimitive(field: field.name, value: "null", parent: dataType))
                    }
                } else {
                    dataType.items.append(DataPrimitive(field: field.name, value: "null", parent: dataType))
                }
            }
            return dataType
        }
        if let parent = parent { // Primitive type. Can't be without parent type
            return primitiveType(type: type, field: field, val: obj, parent: parent)
        }
        return nil
    }
    
    fileprivate func primitiveType(type: String, field: String, val: SerializableValue, parent: DataType) -> DataPrimitive {
        switch type {
        case "string": fallthrough
        case "bytes":
            return DataPrimitive(field: field, value: val.string ?? "null", parent: parent)
        case "bool":
            if let bool = val.bool {
                return DataPrimitive(field: field, value: "\(bool)", parent: parent)
            }
        case "address":
            if let address = val.string {
                return DataPrimitive(field: field, value: address, parent: parent)
            }
        case let uint where uint.starts(with: "uint"):
            if let int = val.int {
                return DataPrimitive(field: field, value: "\(int)", parent: parent)
            }
            if let str = val.string {
                let big = str.starts(with: "0x") ? BigUInt(String(str.dropFirst(2)), radix: 16) : BigUInt(str)
                return DataPrimitive(field: field, value: "\(big ?? "null")", parent: parent)
            }
        case let int where int.starts(with: "uint"):
            if let int = val.int {
                return DataPrimitive(field: field, value: "\(int)", parent: parent)
            }
            if let str = val.string {
                let big = str.starts(with: "0x") ? BigInt(String(str.dropFirst(2)), radix: 16) : BigInt(str)
                return DataPrimitive(field: field, value: "\(big ?? "null")", parent: parent)
            }
        case let bytes where bytes.starts(with: "bytes"):
            if let str = val.string {
                return DataPrimitive(field: field, value: str, parent: parent)
            }
        default: break
        }
        return DataPrimitive(field: field, value: "null", parent: parent)
    }
}
