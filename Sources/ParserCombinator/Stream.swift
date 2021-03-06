//
//  Stream.swift
//  ParserCombinator
//
//  Created by Stefan Urbanek on 01/01/16.
//  Copyright © 2016 Stefan Urbanek. All rights reserved.
//
//  Source token stream
//

/// Stream
//  Inspired by Swiftz
public struct Stream<Element>: CustomStringConvertible {
    /// Get next element in the stream and the stream representing rest of the
    /// elements
    let step: () -> (head: Element, tail: Stream<Element>)

    /// Initializes the stream with a function `step()` which fetches elements
    /// from the wrapped stream
    init(_ step: @escaping () -> (head: Element, tail: Stream<Element>)) {
        self.step = step
    }

    /// Current element in the front of the stream
    public var head: Element {
        return self.step().head
    }

    /// Stream for elements after the first one
    public var tail: Stream<Element> {
        let (_, tail) = self.step()
        return tail
    }

    public var description: String {
        // TODO: Can't have this here while in Playground, results in infinite recursion
        return "[\(self.head), ...]"
    }
}


/// Wrapper for a collection to provide streaming context
public struct CollectionStreamer<T: Collection>: CustomStringConvertible {
    // TODO: make Element:EmptyCheckable
    typealias Element = T.Iterator.Element
    let index: T.Index
    let collection: T
    let empty: Element

    /// Initializes the streamer with a collection.
    /// - Parameters:
    ///     - collection: collection to be wrapped by the stream
    ///     - empty: value representing an empty element. This value is yielded
    ///       when end of the collection is reached.
    ///     - index: optional startin index for streaming
    init(_ collection: T, empty: Element,index: T.Index?=nil){
        self.index = index ?? collection.startIndex
        self.collection = collection
        self.empty = empty
    }

    /// Returns "tail" of the streamer – streamer that represents rest of the
    /// collection.
    func next() -> CollectionStreamer {
        if index == collection.endIndex {
            return CollectionStreamer(collection,
                                      empty: empty,
                                      index: index)
        }
        else {
            return CollectionStreamer(collection,
                                      empty: empty,
   									  index: collection.index(index, offsetBy: 1))
        }
    }

    /// Method for the `Stream`
    func step() -> (head:Element, tail:Stream<Element>) {
        if index == collection.endIndex {
            return (head:empty, tail:Stream(step))
        }
        else {
            let head: Element = collection[index]
            return (head:head, tail:Stream(next().step))
        }
    }

    /// Create a stream from teh collection streamer
    /// - Returns: Stream wrappign the receiver.
    func stream() -> Stream<Element> {
        return Stream(step)
    }

    public var description: String {
        if self.index == self.collection.endIndex {
            return "[\(self.index)->END]"
        }
        else {
            return "[\(self.index)->\(self.collection[self.index])]"
        }
    }
}

/// Objects conforming to the `Streamable` protocol can be converted to a stream.
public protocol StreamConvertible {
    associatedtype StreamElement
    func stream() -> Stream<StreamElement>
}

extension Collection where Iterator.Element: EmptyCheckable {
    public typealias StreamElement = Iterator.Element
    public func stream() -> Stream<StreamElement> {
        return CollectionStreamer(self, 
                                  empty: StreamElement.emptyValue).stream()
    }
}
