//
//  UIViewController+Extension.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 25.05.2021.
//

import Foundation
import UIKit

extension UIViewController {
    func showInputDialog(title: String,
                         message: String,
                         actionTitle: String,
                         cancelTitle: String = "Cancel",
                         cancelHandler: ((UIAlertAction) -> Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField ()
        
        alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
                guard let textField =  alert.textFields?.first else {
                    actionHandler?(nil)
                    return
                }
                actionHandler?(textField.text)
            }
        )
        
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
}
