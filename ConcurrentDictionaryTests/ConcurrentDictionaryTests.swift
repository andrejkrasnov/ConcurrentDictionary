//
//  ConcurrentDictionaryTests.swift
//  ConcurrentDictionaryTests
//
//  Created by Krasnov Andrey on 03.11.2020.
//

import XCTest
@testable import ConcurrentDictionary

class ConcurrentDictionaryTests: XCTestCase {

    func test_Multiple_Queue_recording() {
        let expectation = XCTestExpectation(description: "Incremet age by 5 in 5 task")
        
        let sourceDictionary = [ "John": 17, "Andrey": 20, "Oleg": 27 ]
        let expectedDictionary = [ "John": 22, "Andrey": 25, "Oleg": 32 ]
        
        let concurrentDictionary = ConcurrentDictionary<String, Int>.init(dictionary: sourceDictionary)
        let queue = DispatchQueue.global()
        DispatchQueue.global().async {
            for i in 0...4 {
                queue.async {
                    for key in concurrentDictionary.keys() {
                        if let value = concurrentDictionary[key] {
                            concurrentDictionary[key] = value + 1
                            print("[\(i)] \(key): \(String(describing: concurrentDictionary[key]))")
                        }
                    }
                }
            }
            
            queue.async(flags:.barrier) {
                print("all done ")
                for key in concurrentDictionary.keys() {
                    if let value = concurrentDictionary[key] {
                        if value != expectedDictionary[key] {
                            XCTAssertEqual(value, expectedDictionary[key])
                        }
                    }
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_Writing_Reading_Queues() {
        let firstWritterQueue = DispatchQueue.global()
        let secondWritterQueue = DispatchQueue.global()
        let key = "testKey"
        let expectation = XCTestExpectation(description: "calc in 2 theads")
        let concurrentDictionary = ConcurrentDictionary<String, Int>()
        concurrentDictionary[key] = 0
        let expectedValue = 10
        
        DispatchQueue.global().async {
            for i in 0 ... 4 {
                firstWritterQueue.async {
                    if let value = concurrentDictionary[key] {
                        concurrentDictionary[key] = value + 1
                        print("first writter \(String(describing: concurrentDictionary[key]))")
                    }
                }
                secondWritterQueue.async {
                    if let value = concurrentDictionary[key] {
                        concurrentDictionary[key] = value + 1
                        print("second writter \(String(describing: concurrentDictionary[key]))")
                    }
                }
            }
            DispatchQueue.global().async(flags: .barrier) {
                XCTAssertEqual(concurrentDictionary[key], expectedValue)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
