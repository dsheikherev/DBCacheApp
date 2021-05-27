//
//  ViewController.swift
//  DBCacheApp
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
    @IBOutlet weak var copyToCacheButton: UIButton!
    
    // We are sure it will be initialized
    // Or we are not interested to run app without ViewModel
    var viewModel: DbViewModel!
          
    override func viewDidLoad() {
        super.viewDidLoad()
        // for UI tests purpose
        dbTableView.accessibilityIdentifier = "dbTableViewIdentifier"
        cacheTableView.accessibilityIdentifier = "cacheTableViewIdentifier"
        // Do any additional setup after loading the view.
        
        initialStyle()
        
        cacheTableView.delegate = self
        cacheTableView.dataSource = self
        dbTableView.delegate = self
        dbTableView.dataSource = self
        
        cacheTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CacheTableViewCell")
        dbTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DbTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        //FIXME
        viewModel = DefaultDbViewModel(database: DefaultDatabase())
        
        bind(to: viewModel)
        viewModel.onViewDidLoad()
    }
       
    func initialStyle() {
        addNodeButton.isEnabled = false
        removeNodeButton.isEnabled = false
        alterNodeButton.isEnabled = false
        applyChangesButton.isEnabled = false
        copyToCacheButton.isEnabled = false
    }
    
    @objc func appMovedToBackground() {
        if let selectedIndexPath = cacheTableView.indexPathForSelectedRow {
            cacheTableView.deselectRow(at: selectedIndexPath, animated: false)
            enableAlterButtons(false)
        }
        if let selectedIndexPath = dbTableView.indexPathForSelectedRow {
            dbTableView.deselectRow(at: selectedIndexPath, animated: false)
            enableCopyToCacheButton(false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }

}

// MARK: Methods to observe changes in ViewModel properties
extension ViewController {
    private func bind(to viewModel: DbViewModel) {
        viewModel.dbTableEntries.observe(on: self) { [weak self] _ in self?.updateDbTable() }
        viewModel.cacheTableEntries.observe(on: self) { [weak self] _ in self?.updateCacheTable() }
        
        viewModel.isCacheChangesAllowed.observe(on: self) { [weak self] enable in self?.enableAlterButtons(enable) }
        viewModel.isCopyToCacheAllowed.observe(on: self) { [weak self] enable in self?.enableCopyToCacheButton(enable) }
        viewModel.isApplyChangesAllowed.observe(on: self) { [weak self] enable in self?.enableApplyChangesButton(enable) }
        
        viewModel.loading.observe(on: self) { [weak self] in self?.updateLoading($0) }
    }
    
    private func updateCacheTable() {
        cacheTableView.reloadData()
    }
    
    private func updateDbTable() {
        dbTableView.reloadData()
    }
    
    func enableAlterButtons(_ shouldEnable: Bool) {
        addNodeButton.isEnabled = shouldEnable
        removeNodeButton.isEnabled = shouldEnable
        alterNodeButton.isEnabled = shouldEnable
    }
    
    func enableCopyToCacheButton(_ shouldEnable: Bool) {
        copyToCacheButton.isEnabled = shouldEnable
    }
    
    func enableApplyChangesButton(_ shouldEnable: Bool) {
        applyChangesButton.isEnabled = shouldEnable
    }
    
    func updateLoading(_ loading: DbViewModelLoadingType?) {
        switch loading {
            case .dbLoading:
                LoadingView.show(in: dbTableView.frame)
            case .none:
                LoadingView.hide()
        }
    }
}

// MARK: Buttons' action methods
extension ViewController {
    @IBAction func onAddButton(_ sender: UIButton) {
        if let indexpath = cacheTableView.indexPathForSelectedRow {
            let index = indexpath.row
            showInputDialog(title: "Add new entry",
                            message: "Enter value",
                            actionTitle: "Add",
                            actionHandler: { [weak self] (input: String?) in
                                guard let self = self,
                                      let input = input,
                                      !input.isEmpty else { return }
                                
                                self.viewModel.onAddNewEntry(with: input, after: index)
                            })
            cacheTableView.deselectRow(at: indexpath, animated: true)
        }
    }
    
    @IBAction func onRemoveButton(_ sender: UIButton) {
        if let indexpath = cacheTableView.indexPathForSelectedRow {
            let index = indexpath.row
            viewModel.onRemoveEntry(index)
            cacheTableView.deselectRow(at: indexpath, animated: true)
        }
    }
    
    @IBAction func onAlterButton(_ sender: UIButton) {
        if let indexpath = cacheTableView.indexPathForSelectedRow {
            let index = indexpath.row
            showInputDialog(title: "Change entry",
                            message: "New value",
                            actionTitle: "Change",
                            actionHandler: { [weak self] (input: String?) in
                                guard let self = self,
                                      let input = input,
                                      !input.isEmpty else { return }
                                
                                self.viewModel.onChangeCacheEntry(index, value: input)
                            })
            cacheTableView.deselectRow(at: indexpath, animated: true)
        }
    }
    
    @IBAction func onApplyButton(_ sender: UIButton) {
        viewModel.onApplyChanges()
    }
    
    @IBAction func onCopyButton(_ sender: UIButton) {
        if let indexpath = dbTableView.indexPathForSelectedRow {
            let index = indexpath.row
            viewModel.onCopyEntry(with: index)
            dbTableView.deselectRow(at: indexpath, animated: true)
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
            return viewModel.cacheTableEntries.value.count
        } else {
            return viewModel.dbTableEntries.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let node: TableViewEntry
        
        if tableView == cacheTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "CacheTableViewCell", for: indexPath)
            node = viewModel.cacheTableEntries.value[indexPath.row]
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "DbTableViewCell", for: indexPath)
            node = viewModel.dbTableEntries.value[indexPath.row]
        }
        
        cell.textLabel?.attributedText = nil
        cell.textLabel?.text = nil
        
        if node.isRemoved {
            cell.textLabel?.attributedText = node.value.strikethrough()
        } else {
            cell.textLabel?.text = node.value
        }
        cell.indentationLevel = 2 * node.indentation
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == cacheTableView {
            viewModel.onCacheEntrySelected(index: indexPath.row)
        } else {
            viewModel.onDbEntrySelected(index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow,
           indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: false)
            
            if tableView == cacheTableView {
                enableAlterButtons(false)
            } else {
                enableCopyToCacheButton(false)
            }
            return nil
        }
        return indexPath
    }
    
}
