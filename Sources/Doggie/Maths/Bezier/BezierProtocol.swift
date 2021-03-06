//
//  BezierProtocol.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public protocol BezierProtocol : ScalarMultiplicative, MapReduceArithmetic, RandomAccessCollection, MutableCollection where Element : ScalarMultiplicative, Scalar == Element.Scalar {
    
    init()
    
    var degree: Int { get }
    
    func split(_ t: Scalar) -> (Self, Self)
    
    func eval(_ t: Scalar) -> Element
}

extension BezierProtocol {
    
    @_transparent
    public static var zero: Self {
        return Self()
    }
}

extension BezierProtocol {
    
    @_transparent
    public var degree: Int {
        return count - 1
    }
}

extension BezierProtocol {
    
    @inlinable
    public func split(_ t: [Scalar]) -> [Self] {
        var result: [Self] = []
        result.reserveCapacity(t.count + 1)
        var remain = self
        var last_t: Scalar = 0
        for _t in t.sorted() {
            let split = remain.split((_t - last_t) / (1 - last_t))
            result.append(split.0)
            remain = split.1
            last_t = _t
        }
        result.append(remain)
        return result
    }
}
