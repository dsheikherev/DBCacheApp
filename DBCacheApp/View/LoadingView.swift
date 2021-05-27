//
//  LoadingView.swift
//  DBCacheApp
//
//  Created by Denis Sheikherev on 25.05.2021.
//

import UIKit

public class LoadingView {
    
    private static var spinner: UIActivityIndicatorView?
    
    public static func show(in frame: CGRect) {
        DispatchQueue.main.async {
            if spinner == nil, let window = UIApplication.shared.windows.last {
                let frame = frame
                let spinner = UIActivityIndicatorView(frame: frame)
                spinner.style = .large
                window.addSubview(spinner)
                spinner.startAnimating()
                self.spinner = spinner
            }
        }
    }
    
    public static func hide() {
        DispatchQueue.main.async {
            if let spinner = spinner {
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                self.spinner = nil
            }
        }
    }
}
