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
        case .OK(let value):
            let (head, _) = value
            return head
        case .Fail(let error):
            debugPrint("FAIL: \(error)")
            return nil
        case .Error(let error):
            debugPrint("ERROR: \(error)")
            return nil
        }
    }

    func testSucceed() {
        let parser: Parser<String, String> = succeed("hello")
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

    func testAlternate() {
        let parser = alternate(expect("left"), expect("right"))
        var source = ["left"]
        var result = self.parse(source, parser)

        XCTAssertEqual(result, "left")

        source = ["right"]
        result = self.parse(source, parser)
        XCTAssertEqual(result, "right")

        source = ["up"]
        result = self.parse(source, parser)
        XCTAssertNil(result)
    }

    func testThen() {
        let parser = then(expect("left"), expect("right"))
        let source = ["left", "right"]
        let result = self.parse(source, parser)

        XCTAssertEqual(result!.0, "left")
        XCTAssertEqual(result!.1, "right")
    }

    func testMany() {
        let parser = many(expect("la"))
        var source = ["la", "la", "la"]

        var result = self.parse(source, parser)
        XCTAssertEqual(result!, ["la", "la", "la"])

        source = ["la", "la", "bum"]
        result = self.parse(source, parser)
        XCTAssertEqual(result!, ["la", "la"])

        source = ["bum"]
        result = self.parse(source, parser)
        XCTAssertEqual(result!, [])
    }

    func testSome() {
        let parser = some(expect("la"))
        var source = ["la", "la", "la"]

        var result = self.parse(source, parser)
        XCTAssertEqual(result!, ["la", "la", "la"])

        source = ["la", "la", "bum"]
        result = self.parse(source, parser)
        XCTAssertEqual(result!, ["la", "la"])

        source = ["bum"]
        result = self.parse(source, parser)
        XCTAssertNil(result)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
