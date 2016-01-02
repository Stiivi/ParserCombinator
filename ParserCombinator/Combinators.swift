//
//  Combinators.swift
//  ParserCombinator
//
//  Created by Stefan Urbanek on 01/01/16.
//  Copyright © 2016 Stefan Urbanek. All rights reserved.
//

//===----------------------------------------------------------------------===//
//
// Combinators
//
//===----------------------------------------------------------------------===//

/// Represents alternation. If the first parser is not successful, then the
/// result of the right one is returned.
func alternate<T,O>(left: Parser<T,O>, _ right: Parser<T,O>) -> Parser<T,O> {
    return Parser {
        input in
        let result = left.parse(input)
        if case .Success = result {
            return result
        }
        else {
            return right.parse(input)
        }
    }
}

// TODO: it would be nice if we can combine the two
func combineTo<T,O> (left: Parser<T,[O]>, _ right: Parser<T,O>) -> Parser<T,[O]> {
    return Parser {
        input in

        switch left.parse(input) {
        case .Success(let lval):
            let (lhead, ltail) = lval

            // Parse stream advanced to the next item
            switch right.parse(ltail) {
            case .Success(let rval):
                let (rhead, rtail) = rval
                let combined = lhead + [rhead]

                let out = Result.Success(combined, rtail)
                return out

            case .Failure(let error):
                return Result.Failure(error)
            }

        case .Failure(let error):
            return Result.Failure(error)
        }

    }
}

func combine<T,O>(left: Parser<T,O>, _ right: Parser<T,O>) -> Parser<T,[O]> {
    return Parser {
        input in

        switch left.parse(input) {
        case .Success(let lval):
            let (lhead, ltail) = lval

            // Parse stream advanced to the next item
            switch right.parse(ltail) {
            case .Success(let rval):
                let (rhead, rtail) = rval
                let combined = [lhead, rhead]
                return Result.Success(combined, rtail)

            case .Failure(let error):
                return Result.Failure(error)
            }

        case .Failure(let error):
            return Result.Failure(error)
        }
    }
}