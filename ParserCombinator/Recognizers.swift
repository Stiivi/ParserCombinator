//
//  Recognizers.swift
//  ParserCombinator
//
//  Created by Stefan Urbanek on 01/01/16.
//  Copyright © 2016 Stefan Urbanek. All rights reserved.
//

//===----------------------------------------------------------------------===//
//
// Recognizers
//
//===----------------------------------------------------------------------===//

public func succeed<T,O>(value: O) -> Parser<T, O> {
    return Parser { Result.OK(value, $0) }
}


public func fail<T,O>(error: String) -> Parser<T, O> {
    return Parser { _ in Result.Fail(error) }
}


public func nofail<T,O>(parser: Parser<T,O>) -> Parser<T,O> {
    return Parser {
        input in

        let result = parser.parse(input)

        switch result {
        case .Fail(let error):
            return Result.Error(error)
        default:
            return result
        }
    }
}


/// Recognise single symbol
/// - Returns: symbol if matches `condition`, otherwise failure
public func satisfy<T: EmptyCheckable>(error: String, _ condition: (T) -> Bool) -> Parser<T,T> {
    return Parser {
        input in
        let (head, tail) = (input.head, input.tail)
        if head.isEmpty {
            return fail("Unexpected end of input").parse(tail)
        }
        else {
            if condition(head) {
                return succeed(head).parse(tail)
            }
            else {
                return fail(error).parse(tail)
            }
        }
    }
}


/// Recognizes symbol with given text
public func expect<T: Equatable>(value: T) -> Parser<T, T>{
    return satisfy("expected \(value)") {
        $0 == value
    }
}
