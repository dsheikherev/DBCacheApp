//
//  Observable.swift
//  DBCacheTest
//
//  Created by Denis Sheikherev on 22.05.2021.
//

import Foundation

public final class Observable<Val> {
    
    struct Observer<Val> {
        weak var observer: AnyObject?
        let block: (Val) -> Void
    }
    
    private var observers = [Observer<Val>]()
    
    public var value: Val {
        didSet { notify() }
    }
    
    init(_ value: Val) {
        self.value = value
    }
    
    public func observe(on observer: AnyObject, observerBlock: @escaping (Val) -> Void) {
        observers.append(Observer(observer: observer, block: observerBlock))
        observerBlock(self.value)
    }
    
    public func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer}
    }
    
    private func notify() {
        for observer in observers {
            DispatchQueue.main.async { observer.block(self.value) }
        }
    }
    
}
