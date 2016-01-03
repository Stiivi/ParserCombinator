//
//  Parser.swift
//  ParserCombinator
//
//  Created by Stefan Urbanek on 01/01/16.
//  Copyright © 2016 Stefan Urbanek. All rights reserved.
//

//===----------------------------------------------------------------------===//
//
// Result
//
//===----------------------------------------------------------------------===//

/// Parsing error with error message
public enum ParserError: ErrorType, CustomStringConvertible {
    case Error(String)

    public var description: String {
        switch self {
        case Error(let s): return s
        }
    }
}

public protocol ResultType {
    typealias Value
}

/// Parsing result
public enum Result<V>: CustomStringConvertible, ResultType {
    public typealias Value = V
    case OK(Value)
    case Fail(String)
    case Error(String)

    public var description: String {
        switch self {
        case .OK(let value): return String(value)
        case .Fail(let error): return "Fail: \(error)"
        case .Error(let error): return "Error: \(error)"
        }
    }
}

//===----------------------------------------------------------------------===//
//
// Parser
//
//===----------------------------------------------------------------------===//

protocol ParserType {
    typealias Input
    typealias Output
}

/// The Parser definition
public struct Parser<I: EmptyCheckable, O>: ParserType {
    public typealias Input = I
    public typealias Output = O
    public typealias Function = Stream<Input> -> Result<(Output,Stream<Input>)>

    public var parse: Function

    public init(_ parse: Function) {
        self.parse = parse
    }
}
