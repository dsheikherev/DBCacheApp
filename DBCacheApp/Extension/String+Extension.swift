//
//  String+Extension.swift
//  DBCacheApp
//
//  Created by Denis Sheikherev on 26.05.2021.
//

import Foundation

import Foundation
import UIKit

extension String {
    func strikethrough() -> NSAttributedString {
        let strokeEffect: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.strikethroughColor: UIColor.systemRed]
        
        return NSAttributedString(string: self, attributes: strokeEffect)
    }
}
