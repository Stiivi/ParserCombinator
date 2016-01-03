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

/// Parsing result wrapper.
public enum Result<V>: CustomStringConvertible, ResultType {
    public typealias Value = V

    /// Holds the parser result value if the parser succeeded
    case OK(Value)
    /// Parser failed to match an expected input. Other parsers might continue
    /// parsing if their predecessors failed.
    case Fail(String)
    /// Unrecoverable error
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

/// The Parser – structure wrapping a function that reads a symbol from the input
/// stream and produces a parser result `Result` with output value and next
/// stream state
public struct Parser<I: EmptyCheckable, O>: ParserType {
    public typealias Input = I
    public typealias Output = O

    public var parse: Stream<Input> -> Result<(Output,Stream<Input>)>

    /// Initializes the parser with a fuction `parse` which takes an input stream
    /// and produces a parser result wit the output value and advanced stream
    /// state.
    public init(_ parse: Stream<Input> -> Result<(Output,Stream<Input>)>) {
        self.parse = parse
    }
}
