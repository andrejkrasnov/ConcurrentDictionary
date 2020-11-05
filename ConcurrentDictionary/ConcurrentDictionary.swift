//
//  ConcurrentDictionary.swift
//  ConcurrentDictionary
//
//  Created by Krasnov Andrey on 03.11.2020.
//

import Foundation

final class ConcurrentDictionary<Key: Hashable, Value> {

    private var dictionary: [Key: Value] = [:]
    private let lock = NSLock()
    
    init() {}
    
    init(dictionary: [Key:Value]) {
        self.dictionary = dictionary
    }
    
    subscript(key: Key) -> Value? {
        get { get(key) }
        set { set(newValue, for: key) }
    }
    
    func values() -> Dictionary<Key, Value>.Values {
        defer { lock.unlock() }
        lock.lock()
        return self.dictionary.values
    }
    
    func keys() -> Dictionary<Key, Value>.Keys {
        defer { lock.unlock() }
        lock.lock()
        return self.dictionary.keys
    }
    
    func get(_ key: Key)  -> Value? {
        defer { lock.unlock() }
        lock.lock()
        return self.dictionary[key]
    }
    
    func set(_ newValue: Value?, for key: Key) {
        defer { lock.unlock() }
        lock.lock()
        self.dictionary[key] = newValue
    }
}
