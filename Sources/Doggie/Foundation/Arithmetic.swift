//
//  Arithmetic.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

public protocol Additive : Equatable {
    
    static func + (lhs: Self, rhs: Self) -> Self
    
    static func += (lhs: inout Self, rhs: Self)
    
    static prefix func + (x: Self) -> Self
}

extension Additive {
    
    @_inlineable
    public static prefix func + (x: Self) -> Self {
        return x
    }
}

public protocol Subtractive : Additive {
    
    static func - (lhs: Self, rhs: Self) -> Self
    
    static func -= (lhs: inout Self, rhs: Self)
    
    static prefix func - (x: Self) -> Self
}

public protocol Multiplicative : Equatable {
    
    static func * (lhs: Self, rhs: Self) -> Self
    
    static func *= (lhs: inout Self, rhs: Self)
}

public protocol Divisive : Multiplicative {
    
    static func / (lhs: Self, rhs: Self) -> Self
    
    static func /= (lhs: inout Self, rhs: Self)
}

extension Int8 : Additive, Subtractive, Multiplicative, Divisive {
    
}

extension Int16 : Additive, Subtractive, Multiplicative, Divisive {
    
}

extension Int32 : Additive, Subtractive, Multiplicative, Divisive {
    
}

extension Int64 : Additive, Subtractive, Multiplicative, Divisive {
    
}

extension Int : Additive, Subtractive, Multiplicative, Divisive {
    
}

extension Float : Additive, Subtractive, Multiplicative, Divisive {
    
}

extension Double : Additive, Subtractive, Multiplicative, Divisive {
    
}