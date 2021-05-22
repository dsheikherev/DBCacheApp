//
//  ViewController.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 20.05.2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cacheTableView: UITableView!
    @IBOutlet weak var dbTableView: UITableView!
    
    @IBOutlet weak var addNodeButton: UIButton!
    @IBOutlet weak var removeNodeButton: UIButton!
    @IBOutlet weak var alterNodeButton: UIButton!
    @IBOutlet weak var applyChangesButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var moveToCacheButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cacheTableView.delegate = self
        cacheTableView.dataSource = self
        dbTableView.delegate = self
        dbTableView.dataSource = self
        
        cacheTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CacheTableViewCell")
        dbTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DbTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        if let selectedIndexPath = cacheTableView.indexPathForSelectedRow {
            cacheTableView.deselectRow(at: selectedIndexPath, animated: false)
        }
        if let selectedIndexPath = dbTableView.indexPathForSelectedRow {
            dbTableView.deselectRow(at: selectedIndexPath, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if tableView == cacheTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "CacheTableViewCell", for: indexPath)
            cell.textLabel?.text = "Cache"
            cell.indentationLevel = indexPath.row
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "DbTableViewCell", for: indexPath)
            cell.textLabel?.text = "Db"
            cell.indentationLevel = indexPath.row
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow,
           indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: false)
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    }
    
    
}

