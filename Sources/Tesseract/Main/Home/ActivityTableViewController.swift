//
//  ActivityTableViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class ActivityTableViewController: UITableViewController {
  
    // MARK: Properties
    //
    let activeCellHeight: CGFloat = 60
    
    // MARK: Lifecycle
    //
    override func viewDidLoad() {
      super.viewDidLoad()
      
      loadAssets()
      setUpSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .bottom)
      tableView.beginUpdates()
      tableView.endUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
    }
    
    // MARK: - Table view data source
    //
    override func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return 1 // transactions count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      // Table view cells are reused and should be dequeued using a cell identifier.
      let cellIdentifier = NSStringFromClass(C.self).components(separatedBy: ".").last! as String
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as? C else {
        fatalError("The dequeued cell is not an instance of \(cellIdentifier).")
      }
      
      return cell
    }
  
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      let cell = tableView.cellForRow(at: indexPath) as? C
      return cell?.currentHeight ?? activeCellHeight
    }
}

