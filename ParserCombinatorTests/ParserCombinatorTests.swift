//
//  ParserCombinatorTests.swift
//  ParserCombinatorTests
//
//  Created by Stefan Urbanek on 01/01/16.
//  Copyright © 2016 Stefan Urbanek. All rights reserved.
//

import XCTest
@testable import ParserCombinator

class ParserCombinatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func parse<R>(source: [String], _ parser:Parser<String,R>) -> R? {
        let stream = source.stream("")
        let result = parser.parse(stream)

        switch result {
        case .Success(let head, _): return head
        case .Failure(let error):
            print("ERROR: \(error)")
            return nil
        }
    }

    func testSucceed() {
        let parser = succeed("hello")
        var source = ["something"]

        var result = self.parse(source, parser)

        XCTAssertEqual(result, "hello")

        source = []
        result = self.parse(source, parser)
        XCTAssertEqual(result, "hello")
    }

    func testFail() {
        let parser: Parser<String, String> = fail("parser error")
        let source = ["hello"]

        let result = self.parse(source, parser)

        XCTAssertNil(result)
    }

    func testSatisfy() {
        let parser = satisfy("parse error") { $0 == "hello" }
        let validSource = ["hello"]
        let failedSource = ["good bye"]

        var result: String?

        result = self.parse(validSource, parser)
        XCTAssertEqual(result, "hello")

        result = self.parse(failedSource, parser)
        XCTAssertNil(result)

    }

    func testExpect() {
        let parser = expect("hello")
        
        let validSource = ["hello"]
        let failedSource = ["good bye"]

        var result: String?

        result = self.parse(validSource, parser)
        XCTAssertEqual(result, "hello")

        result = self.parse(failedSource, parser)
        XCTAssertNil(result)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
