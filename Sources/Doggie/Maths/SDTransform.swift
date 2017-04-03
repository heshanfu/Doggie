//
//  SDTransform.swift
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

import Foundation

///
/// Transformation Matrix:
///
///     ⎛ a d 0 ⎞
///     ⎜ b e 0 ⎟
///     ⎝ c f 1 ⎠
///
public protocol SDTransformProtocol: Hashable {
    
    var a: Double { get }
    var b: Double { get }
    var c: Double { get }
    var d: Double { get }
    var e: Double { get }
    var f: Double { get }
    var inverse : Self { get }
    var determinant : Double { get }
}

extension SDTransformProtocol {
    
    @_inlineable
    public var tx: Double {
        return c
    }
    
    @_inlineable
    public var ty: Double {
        return f
    }
}

extension SDTransformProtocol {
    
    @_inlineable
    public var hashValue: Int {
        return hash_combine(seed: 0, a, b, c, d, e, f)
    }
}

extension SDTransformProtocol {
    
    @_inlineable
    public var determinant : Double {
        return a * e - b * d
    }
}

///
/// Transformation Matrix:
///
///     ⎛ a d 0 ⎞
///     ⎜ b e 0 ⎟
///     ⎝ c f 1 ⎠
///
public struct SDTransform: SDTransformProtocol {
    
    public var a: Double
    public var b: Double
    public var c: Double
    public var d: Double
    public var e: Double
    public var f: Double
    
    @_inlineable
    public init<T: SDTransformProtocol>(_ m: T) {
        self.a = m.a
        self.b = m.b
        self.c = m.c
        self.d = m.d
        self.e = m.e
        self.f = m.f
    }
    
    @_inlineable
    public init(a: Double, b: Double, c: Double, d: Double, e: Double, f: Double) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.e = e
        self.f = f
    }
}

extension SDTransform : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "{a: \(a), b: \(b), c: \(c), d: \(d), e: \(e), f: \(f)}"
    }
}

extension SDTransform {
    
    @_inlineable
    public init?(from p0: Point, _ p1: Point, _ p2: Point, to q0: Point, _ q1: Point, _ q2: Point) {
        
        func solve(_ a: Double, _ b: Double, _ c: Double, _ d: Double, _ e: Double, _ f: Double, _ x: Double, _ y: Double, _ z: Double) -> (Double, Double, Double)? {
            
            let _det = a * (d - f) + b * (e - c) + c * f - d * e
            
            if _det == 0 {
                return nil
            }
            
            let det = 1 / _det
            
            let _a = d - f
            let _b = f - b
            let _c = b - d
            let _d = e - c
            let _e = a - e
            let _f = c - a
            let _g = c * f - d * e
            let _h = b * e - a * f
            let _i = a * d - b * c
            
            return ((x * _a + y * _b + z * _c) * det, (x * _d + y * _e + z * _f) * det, (x * _g + y * _h + z * _i) * det)
        }
        
        guard let (a, b, c) = solve(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, q0.x, q1.x, q2.x) else { return nil }
        guard let (d, e, f) = solve(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, q0.y, q1.y, q2.y) else { return nil }
        
        self.init(a: a, b: b, c: c, d: d, e: e, f: f)
    }
}

extension SDTransform {
    
    @_inlineable
    public var inverse : SDTransform {
        let det = self.determinant
        return SDTransform(a: e / det, b: -b / det, c: (b * f - c * e) / det, d: -d / det, e: a / det, f: (c * d - a * f) / det)
    }
}

extension SDTransform {
    
    @_inlineable
    public var tx: Double {
        get {
            return c
        }
        set {
            c = newValue
        }
    }
    
    @_inlineable
    public var ty: Double {
        get {
            return f
        }
        set {
            f = newValue
        }
    }
}

extension SDTransform {
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 ⎞
    ///     ⎜ 0 1 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    public struct Identity: SDTransformProtocol {
        
        @_inlineable
        public init() {
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛  cos(a) sin(a) 0 ⎞
    ///     ⎜ -sin(a) cos(a) 0 ⎟
    ///     ⎝    0      0    1 ⎠
    ///
    public struct Rotate: SDTransformProtocol {
        
        public var angle: Double
        
        @_inlineable
        public init(_ angle: Double) {
            self.angle = angle
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛   1    0 0 ⎞
    ///     ⎜ tan(a) 1 0 ⎟
    ///     ⎝   0    0 1 ⎠
    ///
    public struct SkewX: SDTransformProtocol {
        
        public var angle: Double
        
        @_inlineable
        public init(_ angle: Double) {
            self.angle = angle
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 tan(a) 0 ⎞
    ///     ⎜ 0   1    0 ⎟
    ///     ⎝ 0   0    1 ⎠
    ///
    public struct SkewY: SDTransformProtocol {
        
        public var angle: Double
        
        @_inlineable
        public init(_ angle: Double) {
            self.angle = angle
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ x 0 0 ⎞
    ///     ⎜ 0 y 0 ⎟
    ///     ⎝ 0 0 1 ⎠
    ///
    public struct Scale: SDTransformProtocol {
        
        public var x: Double
        public var y: Double
        
        @_inlineable
        public init(_ scale: Double) {
            self.x = scale
            self.y = scale
        }
        @_inlineable
        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1 0 0 ⎞
    ///     ⎜ 0 1 0 ⎟
    ///     ⎝ x y 1 ⎠
    ///
    public struct Translate: SDTransformProtocol {
        
        public var x: Double
        public var y: Double
        
        @_inlineable
        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ -1 0 0 ⎞
    ///     ⎜  0 1 0 ⎟
    ///     ⎝ 2x 0 1 ⎠
    ///
    public struct ReflectX: SDTransformProtocol {
        
        public var x: Double
        
        @_inlineable
        public init() {
            self.x = 0
        }
        @_inlineable
        public init(_ x: Double) {
            self.x = x
        }
    }
    
    ///
    /// Transformation Matrix:
    ///
    ///     ⎛ 1  0 0 ⎞
    ///     ⎜ 0 -1 0 ⎟
    ///     ⎝ 0 2y 1 ⎠
    ///
    public struct ReflectY: SDTransformProtocol {
        
        public var y: Double
        
        @_inlineable
        public init() {
            self.y = 0
        }
        @_inlineable
        public init(_ y: Double) {
            self.y = y
        }
    }
}

extension SDTransform.Identity {
    
    @_inlineable
    public var a: Double {
        return 1
    }
    @_inlineable
    public var b: Double {
        return 0
    }
    @_inlineable
    public var c: Double {
        return 0
    }
    @_inlineable
    public var d: Double {
        return 0
    }
    @_inlineable
    public var e: Double {
        return 1
    }
    @_inlineable
    public var f: Double {
        return 0
    }
    
    @_inlineable
    public var inverse : SDTransform.Identity {
        return self
    }
}

@_inlineable
public func == (_: SDTransform.Identity, _: SDTransform.Identity) -> Bool {
    return true
}
@_inlineable
public func != (_: SDTransform.Identity, _: SDTransform.Identity) -> Bool {
    return false
}

@_inlineable
public func * (_: SDTransform.Identity, _: SDTransform.Identity) -> SDTransform.Identity {
    return SDTransform.Identity()
}

@_inlineable
public func * <T: SDTransformProtocol>(_: SDTransform.Identity, rhs: T) -> T {
    return rhs
}

@_inlineable
public func * <S: SDTransformProtocol>(lhs: S, _: SDTransform.Identity) -> S {
    return lhs
}

@_inlineable
public func *= <S: SDTransformProtocol>(_: inout S, _: SDTransform.Identity) {
}

extension SDTransform.Rotate {
    
    @_inlineable
    public var a: Double {
        return cos(angle)
    }
    @_inlineable
    public var b: Double {
        return -sin(angle)
    }
    @_inlineable
    public var c: Double {
        return 0
    }
    @_inlineable
    public var d: Double {
        return sin(angle)
    }
    @_inlineable
    public var e: Double {
        return cos(angle)
    }
    @_inlineable
    public var f: Double {
        return 0
    }
    
    @_inlineable
    public var inverse : SDTransform.Rotate {
        return SDTransform.Rotate(-angle)
    }
}

@_inlineable
public func == (lhs: SDTransform.Rotate, rhs: SDTransform.Rotate) -> Bool {
    return lhs.angle == rhs.angle
}
@_inlineable
public func != (lhs: SDTransform.Rotate, rhs: SDTransform.Rotate) -> Bool {
    return lhs.angle != rhs.angle
}

@_inlineable
public func * (lhs: SDTransform.Rotate, rhs: SDTransform.Rotate) -> SDTransform.Rotate {
    return SDTransform.Rotate(lhs.angle + rhs.angle)
}

@_inlineable
public func *= (lhs: inout SDTransform.Rotate, rhs: SDTransform.Rotate) {
    return lhs.angle += rhs.angle
}

extension SDTransform.SkewX {
    
    @_inlineable
    public var a: Double {
        return 1
    }
    @_inlineable
    public var b: Double {
        return tan(angle)
    }
    @_inlineable
    public var c: Double {
        return 0
    }
    @_inlineable
    public var d: Double {
        return 0
    }
    @_inlineable
    public var e: Double {
        return 1
    }
    @_inlineable
    public var f: Double {
        return 0
    }
    
    @_inlineable
    public var inverse : SDTransform.SkewX {
        return SDTransform.SkewX(-angle)
    }
}

@_inlineable
public func == (lhs: SDTransform.SkewX, rhs: SDTransform.SkewX) -> Bool {
    return lhs.angle == rhs.angle
}
@_inlineable
public func != (lhs: SDTransform.SkewX, rhs: SDTransform.SkewX) -> Bool {
    return lhs.angle != rhs.angle
}

@_inlineable
public func * (lhs: SDTransform.SkewX, rhs: SDTransform.SkewX) -> SDTransform.SkewX {
    return SDTransform.SkewX(atan(tan(lhs.angle) + tan(rhs.angle)))
}

@_inlineable
public func *= (lhs: inout SDTransform.SkewX, rhs: SDTransform.SkewX) {
    return lhs.angle = atan(tan(lhs.angle) + tan(rhs.angle))
}

extension SDTransform.SkewY {
    
    @_inlineable
    public var a: Double {
        return 1
    }
    @_inlineable
    public var b: Double {
        return 0
    }
    @_inlineable
    public var c: Double {
        return 0
    }
    @_inlineable
    public var d: Double {
        return tan(angle)
    }
    @_inlineable
    public var e: Double {
        return 1
    }
    @_inlineable
    public var f: Double {
        return 0
    }
    
    @_inlineable
    public var inverse : SDTransform.SkewY {
        return SDTransform.SkewY(-angle)
    }
}

@_inlineable
public func == (lhs: SDTransform.SkewY, rhs: SDTransform.SkewY) -> Bool {
    return lhs.angle == rhs.angle
}
@_inlineable
public func != (lhs: SDTransform.SkewY, rhs: SDTransform.SkewY) -> Bool {
    return lhs.angle != rhs.angle
}

@_inlineable
public func * (lhs: SDTransform.SkewY, rhs: SDTransform.SkewY) -> SDTransform.SkewY {
    return SDTransform.SkewY(atan(tan(lhs.angle) + tan(rhs.angle)))
}

@_inlineable
public func *= (lhs: inout SDTransform.SkewY, rhs: SDTransform.SkewY) {
    return lhs.angle = atan(tan(lhs.angle) + tan(rhs.angle))
}

extension SDTransform.Scale {
    
    @_inlineable
    public var a: Double {
        return x
    }
    @_inlineable
    public var b: Double {
        return 0
    }
    @_inlineable
    public var c: Double {
        return 0
    }
    @_inlineable
    public var d: Double {
        return 0
    }
    @_inlineable
    public var e: Double {
        return y
    }
    @_inlineable
    public var f: Double {
        return 0
    }
    
    @_inlineable
    public var inverse : SDTransform.Scale {
        return SDTransform.Scale(x: 1 / x, y: 1 / y)
    }
}

@_inlineable
public func == (lhs: SDTransform.Scale, rhs: SDTransform.Scale) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
@_inlineable
public func != (lhs: SDTransform.Scale, rhs: SDTransform.Scale) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y
}

@_inlineable
public func * (lhs: SDTransform.Scale, rhs: SDTransform.Scale) -> SDTransform.Scale {
    return SDTransform.Scale(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
}

@_inlineable
public func *= (lhs: inout SDTransform.Scale, rhs: SDTransform.Scale) {
    lhs.x *= rhs.x
    lhs.y *= rhs.y
}

extension SDTransform.Translate {
    
    @_inlineable
    public var a: Double {
        return 1
    }
    @_inlineable
    public var b: Double {
        return 0
    }
    @_inlineable
    public var c: Double {
        return x
    }
    @_inlineable
    public var d: Double {
        return 0
    }
    @_inlineable
    public var e: Double {
        return 1
    }
    @_inlineable
    public var f: Double {
        return y
    }
    
    @_inlineable
    public var inverse : SDTransform.Translate {
        return SDTransform.Translate(x: -x, y: -y)
    }
}

extension SDTransform.Translate {
    
    @_inlineable
    public var tx: Double {
        get {
            return x
        }
        set {
            x = newValue
        }
    }
    
    @_inlineable
    public var ty: Double {
        get {
            return y
        }
        set {
            y = newValue
        }
    }
}

@_inlineable
public func == (lhs: SDTransform.Translate, rhs: SDTransform.Translate) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
@_inlineable
public func != (lhs: SDTransform.Translate, rhs: SDTransform.Translate) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y
}

@_inlineable
public func * (lhs: SDTransform.Translate, rhs: SDTransform.Translate) -> SDTransform.Translate {
    return SDTransform.Translate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

@_inlineable
public func *= (lhs: inout SDTransform.Translate, rhs: SDTransform.Translate) {
    lhs.x += rhs.x
    lhs.y += rhs.y
}

extension SDTransform.ReflectX {
    
    @_inlineable
    public var a: Double {
        return -1
    }
    @_inlineable
    public var b: Double {
        return 0
    }
    @_inlineable
    public var c: Double {
        return 2 * x
    }
    @_inlineable
    public var d: Double {
        return 0
    }
    @_inlineable
    public var e: Double {
        return 1
    }
    @_inlineable
    public var f: Double {
        return 0
    }
    
    @_inlineable
    public var inverse : SDTransform.ReflectX {
        return self
    }
}

@_inlineable
public func == (lhs: SDTransform.ReflectX, rhs: SDTransform.ReflectX) -> Bool {
    return lhs.x == rhs.x
}
@_inlineable
public func != (lhs: SDTransform.ReflectX, rhs: SDTransform.ReflectX) -> Bool {
    return lhs.x != rhs.x
}

extension SDTransform.ReflectY {
    
    @_inlineable
    public var a: Double {
        return 1
    }
    @_inlineable
    public var b: Double {
        return 0
    }
    @_inlineable
    public var c: Double {
        return 0
    }
    @_inlineable
    public var d: Double {
        return 0
    }
    @_inlineable
    public var e: Double {
        return -1
    }
    @_inlineable
    public var f: Double {
        return 2 * y
    }
    
    @_inlineable
    public var inverse : SDTransform.ReflectY {
        return self
    }
}

@_inlineable
public func == (lhs: SDTransform.ReflectY, rhs: SDTransform.ReflectY) -> Bool {
    return lhs.y == rhs.y
}
@_inlineable
public func != (lhs: SDTransform.ReflectY, rhs: SDTransform.ReflectY) -> Bool {
    return lhs.y != rhs.y
}

@_inlineable
public func == <T: SDTransformProtocol>(lhs: T, rhs: T) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c && lhs.d == rhs.d && lhs.e == rhs.e && lhs.f == rhs.f
}
@_inlineable
public func != <T: SDTransformProtocol>(lhs: T, rhs: T) -> Bool {
    return lhs.a != rhs.a || lhs.b != rhs.b || lhs.c != rhs.c || lhs.d != rhs.d || lhs.e != rhs.e || lhs.f != rhs.f
}
@_inlineable
public func == <S: SDTransformProtocol, T: SDTransformProtocol>(lhs: S, rhs: T) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c && lhs.d == rhs.d && lhs.e == rhs.e && lhs.f == rhs.f
}
@_inlineable
public func != <S: SDTransformProtocol, T: SDTransformProtocol>(lhs: S, rhs: T) -> Bool {
    return lhs.a != rhs.a || lhs.b != rhs.b || lhs.c != rhs.c || lhs.d != rhs.d || lhs.e != rhs.e || lhs.f != rhs.f
}

@_inlineable
public func * <S: SDTransformProtocol, T: SDTransformProtocol>(lhs: S, rhs: T) -> SDTransform {
    let a = lhs.a * rhs.a + lhs.d * rhs.b
    let b = lhs.b * rhs.a + lhs.e * rhs.b
    let c = lhs.c * rhs.a + lhs.f * rhs.b + rhs.c
    let d = lhs.a * rhs.d + lhs.d * rhs.e
    let e = lhs.b * rhs.d + lhs.e * rhs.e
    let f = lhs.c * rhs.d + lhs.f * rhs.e + rhs.f
    return SDTransform(a: a, b: b, c: c, d: d, e: e, f: f)
}

@_inlineable
public func *= <T: SDTransformProtocol>(lhs: inout SDTransform, rhs: T) {
    lhs = lhs * rhs
}

@_inlineable
public func * <T: SDTransformProtocol>(lhs: Point, rhs: T) -> Point {
    return Point(x: lhs.x * rhs.a + lhs.y * rhs.b + rhs.c, y: lhs.x * rhs.d + lhs.y * rhs.e + rhs.f)
}

@_inlineable
public func *= <T: SDTransformProtocol>(lhs: inout Point, rhs: T) {
    lhs = lhs * rhs
}
