//
//  ColorModel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

public protocol ColorModelProtocol : Hashable, Tensor where Scalar == Double {
    
    static func rangeOfComponent(_ i: Int) -> ClosedRange<Double>
    
    func blended(source: Self, blending: (Double, Double) -> Double) -> Self
}

extension ColorModelProtocol {
    
    @_inlineable
    public mutating func blend(source: Self, blending: (Double, Double) -> Double) {
        self = self.blended(source: source, blending: blending)
    }
}

extension ColorModelProtocol {
    
    @_transparent
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return Self.rangeOfComponent(i)
    }
}

extension ColorModelProtocol {
    
    @_transparent
    public func normalizedComponent(_ index: Int) -> Double {
        let range = Self.rangeOfComponent(index)
        return (self[index] - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
    
    @_transparent
    public mutating func setNormalizedComponent(_ index: Int, _ value: Double) {
        let range = Self.rangeOfComponent(index)
        self[index] = value * (range.upperBound - range.lowerBound) + range.lowerBound
    }
}

extension ColorModelProtocol {
    
    @_transparent
    public var hashValue: Int {
        var hash = 0
        for i in 0..<Self.numberOfComponents {
            hash = hash_combine(seed: hash, self[i])
        }
        return hash
    }
}

