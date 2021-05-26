//
//  StrikethroughString.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 25.05.2021.
//

import Foundation
import UIKit

func strikethrough(_ string: String) -> NSAttributedString {
    let strokeEffect: [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
        NSAttributedString.Key.strikethroughColor: UIColor.systemRed]
    
    return NSAttributedString(string: string, attributes: strokeEffect)
}
