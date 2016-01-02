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

func succeed<T>(value: T) -> Parser<T, T> {
    return Parser { .Success(value, $0) }
}

func fail<T>(error: String) -> Parser<T, T> {
    return Parser { _ in .Failure(ParserError.Error(error)) }
}

/*
satisfy  :: (* -> bool) -> parser * *
satisfy p []     = fail []
satisfy p (x:xs) = succeed x xs , p x
= fail xs      , otherwise
*/
/// Recognise single symbol
/// - Returns: symbol if matches `condition`, otherwise failure
func satisfy<T: EmptyCheckable>(error: String, _ condition: (T) -> Bool) -> Parser<T,T> {
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
func expect<T: Equatable>(value: T) -> Parser<T, T>{
    return satisfy("expected \(value)") {
        $0 == value
    }
}

