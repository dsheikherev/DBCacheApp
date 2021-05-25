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
    
    var viewModel: DbViewModel!
          
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initialStyle()
        
        cacheTableView.delegate = self
        cacheTableView.dataSource = self
        dbTableView.delegate = self
        dbTableView.dataSource = self
        
        cacheTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CacheTableViewCell")
        dbTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DbTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        viewModel = DefaultDbViewModel()
        bind(to: viewModel)
        viewModel.onViewDidLoad()
    }
       
    func initialStyle() {
        addNodeButton.isEnabled = false
        removeNodeButton.isEnabled = false
        alterNodeButton.isEnabled = false
        applyChangesButton.isEnabled = false
        moveToCacheButton.isEnabled = false
    }
    
    @objc func appMovedToBackground() {
        if let selectedIndexPath = cacheTableView.indexPathForSelectedRow {
            cacheTableView.deselectRow(at: selectedIndexPath, animated: false)
        }
        if let selectedIndexPath = dbTableView.indexPathForSelectedRow {
            dbTableView.deselectRow(at: selectedIndexPath, animated: false)
        }
        moveToCacheButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }

}

// MARK: Methods to observe changes in ViewModel properties
extension ViewController {
    private func bind(to viewModel: DbViewModel) {
        viewModel.database.observe(on: self) { [weak self] _ in self?.updateDbTable() }
        viewModel.cache.observe(on: self) { [weak self] _ in self?.updateCacheTable() }
    }
    
    private func updateCacheTable() {
        cacheTableView.reloadData()
    }
    
    private func updateDbTable() {
        dbTableView.reloadData()
    }
}

// MARK: Buttons' action methods
extension ViewController {
    @IBAction func onAddButton(_ sender: UIButton) {
        viewModel.onAddNewNodeToCache()
    }
    
    @IBAction func onRemoveButton(_ sender: UIButton) {
        viewModel.onRemoveNodeFromCache()
    }
    
    @IBAction func onAlterButton(_ sender: UIButton) {
        viewModel.onChangeValueOfNodeInCache()
    }
    
    @IBAction func onApplyButton(_ sender: UIButton) {
        viewModel.onApplyChanges()
    }
    
    @IBAction func onCopyButton(_ sender: UIButton) {
        if let indexpath = dbTableView.indexPathForSelectedRow {
            let index = indexpath.row
            viewModel.onCopyEntry(with: index)
            dbTableView.deselectRow(at: indexpath, animated: true)
            moveToCacheButton.isEnabled = false
        }
    }
    
    @IBAction func onResetButton(_ sender: UIButton) {
        initialStyle()
        viewModel.onReset()
    }
}

// MARK: TableView delegate & datasource methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == cacheTableView {
            return viewModel.cache.value.count
        } else {
            return viewModel.database.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if tableView == cacheTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "CacheTableViewCell", for: indexPath)
            let node = viewModel.cache.value[indexPath.row]
            cell.textLabel?.text = node.value
            cell.indentationLevel = node.indentation
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "DbTableViewCell", for: indexPath)
            let node = viewModel.database.value[indexPath.row]
            cell.textLabel?.text = node.value
            cell.indentationLevel = node.indentation
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cacheTableView {

        } else {
            moveToCacheButton.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow,
           indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: false)
            
            moveToCacheButton.isEnabled = false
            return nil
        }
        return indexPath
    }
    
}
