//
//  ColorPixel.swift
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

public protocol ColorPixelProtocol : Hashable {
    
    associatedtype Model : ColorModelProtocol
    
    init()
    
    init(color: Model, opacity: Double)
    
    init(color: Model.FloatComponents, opacity: Float)
    
    init<C : ColorPixelProtocol>(_ color: C) where Model == C.Model
    
    var numberOfComponents: Int { get }
    
    func rangeOfComponent(_ i: Int) -> ClosedRange<Double>
    
    func component(_ index: Int) -> Double
    
    mutating func setComponent(_ index: Int, _ value: Double)
    
    func normalizedComponent(_ index: Int) -> Double
    
    mutating func setNormalizedComponent(_ index: Int, _ value: Double)
    
    var color: Model { get set }
    
    var opacity: Double { get set }
    
    var isOpaque: Bool { get }
    
    func with(opacity: Double) -> Self
    
    func blended<C : ColorPixelProtocol>(source: C, compositingMode: ColorCompositingMode, blending: (Double, Double) -> Double) -> Self where C.Model == Model
    
    func blended<C : ColorPixelProtocol>(source: C, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) -> Self where C.Model == Model
}

extension ColorPixelProtocol where Self : ScalarMultiplicative {
    
    @_transparent
    public static var zero: Self {
        return Self()
    }
}

extension ColorPixelProtocol {
    
    @inlinable
    @inline(__always)
    public init(_ color: Color<Model>) {
        self.init(color: color.color, opacity: color.opacity)
    }
}

extension ColorPixelProtocol {
    
    @inlinable
    @inline(__always)
    public init() {
        self.init(color: Model(), opacity: 0)
    }
    
    @inlinable
    @inline(__always)
    public init<C : ColorPixelProtocol>(_ color: C) where Model == C.Model {
        self = color as? Self ?? Self(color: color.color, opacity: color.opacity)
    }
}

extension ColorPixelProtocol {
    
    @inlinable
    @inline(__always)
    public init(color: Model.FloatComponents, opacity: Float = 1) {
        self.init(color: Model(floatComponents: color), opacity: Double(opacity))
    }
}

extension ColorPixelProtocol {
    
    @inlinable
    @inline(__always)
    public func with(opacity: Double) -> Self {
        return Self(color: color, opacity: opacity)
    }
}

extension ColorPixelProtocol {
    
    @_transparent
    public static var numberOfComponents: Int {
        return Model.numberOfComponents + 1
    }
    
    @_transparent
    public var numberOfComponents: Int {
        return Self.numberOfComponents
    }
    
    @inlinable
    @inline(__always)
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        if i < Model.numberOfComponents {
            return Model.rangeOfComponent(i)
        } else if i == Model.numberOfComponents {
            return 0...1
        } else {
            fatalError()
        }
    }
    
    @inlinable
    @inline(__always)
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return Self.rangeOfComponent(i)
    }
    
    @inlinable
    @inline(__always)
    public func component(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            return color[index]
        } else if index == Model.numberOfComponents {
            return opacity
        } else {
            fatalError()
        }
    }
    
    @inlinable
    @inline(__always)
    public mutating func setComponent(_ index: Int, _ value: Double) {
        if index < Model.numberOfComponents {
            color[index] = value
        } else if index == Model.numberOfComponents {
            opacity = value
        } else {
            fatalError()
        }
    }
}

extension ColorPixelProtocol {
    
    @inlinable
    @inline(__always)
    public func normalizedComponent(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            return color.normalizedComponent(index)
        } else if index == Model.numberOfComponents {
            return opacity
        } else {
            fatalError()
        }
    }
    
    @inlinable
    @inline(__always)
    public mutating func setNormalizedComponent(_ index: Int, _ value: Double) {
        if index < Model.numberOfComponents {
            color.setNormalizedComponent(index, value)
        } else if index == Model.numberOfComponents {
            opacity = value
        } else {
            fatalError()
        }
    }
}

extension ColorPixelProtocol {
    
    @_transparent
    public var isOpaque: Bool {
        return opacity >= 1
    }
}

extension ColorPixelProtocol {
    
    @inlinable
    @inline(__always)
    public mutating func blend<C : ColorPixelProtocol>(source: C, compositingMode: ColorCompositingMode = .default, blending: (Double, Double) -> Double) where C.Model == Model {
        self = self.blended(source: source, compositingMode: compositingMode, blending: blending)
    }
    @inlinable
    @inline(__always)
    public mutating func blend<C : ColorPixelProtocol>(source: C, compositingMode: ColorCompositingMode = .default, blendMode: ColorBlendMode = .default) where C.Model == Model {
        self = self.blended(source: source, compositingMode: compositingMode, blendMode: blendMode)
    }
}

extension ColorPixelProtocol where Model == XYZColorModel {
    
    @inlinable
    @inline(__always)
    public init(x: Double, y: Double, z: Double, opacity: Double = 1) {
        self.init(color: XYZColorModel(x: x, y: y, z: z), opacity: opacity)
    }
    
    @inlinable
    @inline(__always)
    public init(luminance: Double, point: Point, opacity: Double = 1) {
        self.init(color: XYZColorModel(luminance: luminance, point: point), opacity: opacity)
    }
    
    @inlinable
    @inline(__always)
    public init(luminance: Double, x: Double, y: Double, opacity: Double = 1) {
        self.init(color: XYZColorModel(luminance: luminance, x: x, y: y), opacity: opacity)
    }
}

extension ColorPixelProtocol where Model == YxyColorModel {
    
    @inlinable
    @inline(__always)
    public init(luminance: Double, point: Point, opacity: Double = 1) {
        self.init(color: YxyColorModel(luminance: luminance, point: point), opacity: opacity)
    }
    
    @inlinable
    @inline(__always)
    public init(luminance: Double, x: Double, y: Double, opacity: Double = 1) {
        self.init(color: YxyColorModel(luminance: luminance, x: x, y: y), opacity: opacity)
    }
}

extension ColorPixelProtocol where Model == LabColorModel {
    
    @inlinable
    @inline(__always)
    public init(lightness: Double, a: Double, b: Double, opacity: Double = 1) {
        self.init(color: LabColorModel(lightness: lightness, a: a, b: b), opacity: opacity)
    }
    
    @inlinable
    @inline(__always)
    public init(lightness: Double, chroma: Double, hue: Double, opacity: Double = 1) {
        self.init(color: LabColorModel(lightness: lightness, chroma: chroma, hue: hue), opacity: opacity)
    }
}

extension ColorPixelProtocol where Model == LuvColorModel {
    
    @inlinable
    @inline(__always)
    public init(lightness: Double, u: Double, v: Double, opacity: Double = 1) {
        self.init(color: LuvColorModel(lightness: lightness, u: u, v: v), opacity: opacity)
    }
    
    @inlinable
    @inline(__always)
    public init(lightness: Double, chroma: Double, hue: Double, opacity: Double = 1) {
        self.init(color: LuvColorModel(lightness: lightness, chroma: chroma, hue: hue), opacity: opacity)
    }
}

extension ColorPixelProtocol where Model == GrayColorModel {
    
    @inlinable
    @inline(__always)
    public init(white: Double, opacity: Double = 1) {
        self.init(color: GrayColorModel(white: white), opacity: opacity)
    }
}

extension ColorPixelProtocol where Model == RGBColorModel {
    
    @inlinable
    @inline(__always)
    public init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.init(color: RGBColorModel(red: red, green: green, blue: blue), opacity: opacity)
    }
    
    @inlinable
    @inline(__always)
    public init(hue: Double, saturation: Double, brightness: Double, opacity: Double = 1) {
        self.init(color: RGBColorModel(hue: hue, saturation: saturation, brightness: brightness), opacity: opacity)
    }
}

extension ColorPixelProtocol where Model == CMYColorModel {
    
    @inlinable
    @inline(__always)
    public init(cyan: Double, magenta: Double, yellow: Double, opacity: Double = 1) {
        self.init(color: CMYColorModel(cyan: cyan, magenta: magenta, yellow: yellow), opacity: opacity)
    }
}

extension ColorPixelProtocol where Model == CMYKColorModel {
    
    @inlinable
    @inline(__always)
    public init(cyan: Double, magenta: Double, yellow: Double, black: Double, opacity: Double = 1) {
        self.init(color: CMYKColorModel(cyan: cyan, magenta: magenta, yellow: yellow, black: black), opacity: opacity)
    }
}

extension ColorPixelProtocol where Model == GrayColorModel {
    
    @_transparent
    public var white: Double {
        get {
            return color.white
        }
        set {
            color.white = newValue
        }
    }
}

extension ColorPixelProtocol where Model == RGBColorModel {
    
    @_transparent
    public var red: Double {
        get {
            return color.red
        }
        set {
            color.red = newValue
        }
    }
    
    @_transparent
    public var green: Double {
        get {
            return color.green
        }
        set {
            color.green = newValue
        }
    }
    
    @_transparent
    public var blue: Double {
        get {
            return color.blue
        }
        set {
            color.blue = newValue
        }
    }
}

extension ColorPixelProtocol where Model == RGBColorModel {
    
    @_transparent
    public var hue: Double {
        get {
            return color.hue
        }
        set {
            color.hue = newValue
        }
    }
    
    @_transparent
    public var saturation: Double {
        get {
            return color.saturation
        }
        set {
            color.saturation = newValue
        }
    }
    
    @_transparent
    public var brightness: Double {
        get {
            return color.brightness
        }
        set {
            color.brightness = newValue
        }
    }
}

extension ColorPixelProtocol where Model == CMYColorModel {
    
    @_transparent
    public var cyan: Double {
        get {
            return color.cyan
        }
        set {
            color.cyan = newValue
        }
    }
    
    @_transparent
    public var magenta: Double {
        get {
            return color.magenta
        }
        set {
            color.magenta = newValue
        }
    }
    
    @_transparent
    public var yellow: Double {
        get {
            return color.yellow
        }
        set {
            color.yellow = newValue
        }
    }
}

extension ColorPixelProtocol where Model == CMYKColorModel {
    
    @_transparent
    public var cyan: Double {
        get {
            return color.cyan
        }
        set {
            color.cyan = newValue
        }
    }
    
    @_transparent
    public var magenta: Double {
        get {
            return color.magenta
        }
        set {
            color.magenta = newValue
        }
    }
    
    @_transparent
    public var yellow: Double {
        get {
            return color.yellow
        }
        set {
            color.yellow = newValue
        }
    }
    
    @_transparent
    public var black: Double {
        get {
            return color.black
        }
        set {
            color.black = newValue
        }
    }
}

public protocol _FloatComponentPixel : ColorPixelProtocol, ScalarMultiplicative {
    
}

public struct ColorPixel<Model : ColorModelProtocol> : _FloatComponentPixel {
    
    public typealias Scalar = Double
    
    public var color: Model
    public var opacity: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.color = Model()
        self.opacity = 0
    }
    
    @inlinable
    @inline(__always)
    public init(color: Model, opacity: Double = 1) {
        self.color = color
        self.opacity = opacity
    }
    
    @inlinable
    @inline(__always)
    public init<C : ColorPixelProtocol>(_ color: C) where Model == C.Model {
        self.color = color.color
        self.opacity = color.opacity
    }
}

@inlinable
@inline(__always)
public prefix func +<Model>(val: ColorPixel<Model>) -> ColorPixel<Model> {
    return val
}
@inlinable
@inline(__always)
public prefix func -<Model>(val: ColorPixel<Model>) -> ColorPixel<Model> {
    return ColorPixel(color: -val.color, opacity: -val.opacity)
}
@inlinable
@inline(__always)
public func +<Model>(lhs: ColorPixel<Model>, rhs: ColorPixel<Model>) -> ColorPixel<Model> {
    return ColorPixel(color: lhs.color + rhs.color, opacity: lhs.opacity + rhs.opacity)
}
@inlinable
@inline(__always)
public func -<Model>(lhs: ColorPixel<Model>, rhs: ColorPixel<Model>) -> ColorPixel<Model> {
    return ColorPixel(color: lhs.color - rhs.color, opacity: lhs.opacity - rhs.opacity)
}

@inlinable
@inline(__always)
public func *<Model>(lhs: Double, rhs: ColorPixel<Model>) -> ColorPixel<Model> {
    return ColorPixel(color: lhs * rhs.color, opacity: lhs * rhs.opacity)
}
@inlinable
@inline(__always)
public func *<Model>(lhs: ColorPixel<Model>, rhs: Double) -> ColorPixel<Model> {
    return ColorPixel(color: lhs.color * rhs, opacity: lhs.opacity * rhs)
}

@inlinable
@inline(__always)
public func /<Model>(lhs: ColorPixel<Model>, rhs: Double) -> ColorPixel<Model> {
    return ColorPixel(color: lhs.color / rhs, opacity: lhs.opacity / rhs)
}

@inlinable
@inline(__always)
public func *=<Model> (lhs: inout ColorPixel<Model>, rhs: Double) {
    lhs.color *= rhs
    lhs.opacity *= rhs
}
@inlinable
@inline(__always)
public func /=<Model> (lhs: inout ColorPixel<Model>, rhs: Double) {
    lhs.color /= rhs
    lhs.opacity /= rhs
}
@inlinable
@inline(__always)
public func +=<Model> (lhs: inout ColorPixel<Model>, rhs: ColorPixel<Model>) {
    lhs.color += rhs.color
    lhs.opacity += rhs.opacity
}
@inlinable
@inline(__always)
public func -=<Model> (lhs: inout ColorPixel<Model>, rhs: ColorPixel<Model>) {
    lhs.color -= rhs.color
    lhs.opacity -= rhs.opacity
}

@_fixed_layout
public struct FloatColorPixel<Model : ColorModelProtocol> : _FloatComponentPixel {
    
    public typealias Scalar = Float
    
    public var floatColor: Model.FloatComponents
    public var floatOpacity: Float
    
    @inlinable
    @inline(__always)
    public init() {
        self.floatColor = Model.FloatComponents()
        self.floatOpacity = 0
    }
    
    @inlinable
    @inline(__always)
    public init(color: Model.FloatComponents, opacity: Float = 1) {
        self.floatColor = color
        self.floatOpacity = opacity
    }
    
    @inlinable
    @inline(__always)
    public init(color: Model, opacity: Double = 1) {
        self.floatColor = color.floatComponents
        self.floatOpacity = Float(opacity)
    }
    
    @_transparent
    public var color: Model {
        get {
            return Model(floatComponents: floatColor)
        }
        set {
            self.floatColor = newValue.floatComponents
        }
    }
    
    @_transparent
    public var opacity: Double {
        get {
            return Double(floatOpacity)
        }
        set {
            self.floatOpacity = Float(newValue)
        }
    }
    
    @inlinable
    @inline(__always)
    public func component(_ index: Int) -> Double {
        if index < Model.numberOfComponents {
            return Double(floatColor[index])
        } else if index == Model.numberOfComponents {
            return Double(floatOpacity)
        } else {
            fatalError()
        }
    }
    
    @inlinable
    @inline(__always)
    public mutating func setComponent(_ index: Int, _ value: Double) {
        if index < Model.numberOfComponents {
            floatColor[index] = Float(value)
        } else if index == Model.numberOfComponents {
            floatOpacity = Float(value)
        } else {
            fatalError()
        }
    }
}

@inlinable
@inline(__always)
public prefix func +<Model>(val: FloatColorPixel<Model>) -> FloatColorPixel<Model> {
    return val
}
@inlinable
@inline(__always)
public prefix func -<Model>(val: FloatColorPixel<Model>) -> FloatColorPixel<Model> {
    return FloatColorPixel(color: -val.floatColor, opacity: -val.floatOpacity)
}
@inlinable
@inline(__always)
public func +<Model>(lhs: FloatColorPixel<Model>, rhs: FloatColorPixel<Model>) -> FloatColorPixel<Model> {
    return FloatColorPixel(color: lhs.floatColor + rhs.floatColor, opacity: lhs.floatOpacity + rhs.floatOpacity)
}
@inlinable
@inline(__always)
public func -<Model>(lhs: FloatColorPixel<Model>, rhs: FloatColorPixel<Model>) -> FloatColorPixel<Model> {
    return FloatColorPixel(color: lhs.floatColor - rhs.floatColor, opacity: lhs.floatOpacity - rhs.floatOpacity)
}

@inlinable
@inline(__always)
public func *<Model>(lhs: Float, rhs: FloatColorPixel<Model>) -> FloatColorPixel<Model> {
    return FloatColorPixel(color: lhs * rhs.floatColor, opacity: lhs * rhs.floatOpacity)
}
@inlinable
@inline(__always)
public func *<Model>(lhs: FloatColorPixel<Model>, rhs: Float) -> FloatColorPixel<Model> {
    return FloatColorPixel(color: lhs.floatColor * rhs, opacity: lhs.floatOpacity * rhs)
}

@inlinable
@inline(__always)
public func /<Model>(lhs: FloatColorPixel<Model>, rhs: Float) -> FloatColorPixel<Model> {
    return FloatColorPixel(color: lhs.floatColor / rhs, opacity: lhs.floatOpacity / rhs)
}

@inlinable
@inline(__always)
public func *=<Model> (lhs: inout FloatColorPixel<Model>, rhs: Float) {
    lhs.floatColor *= rhs
    lhs.floatOpacity *= rhs
}
@inlinable
@inline(__always)
public func /=<Model> (lhs: inout FloatColorPixel<Model>, rhs: Float) {
    lhs.floatColor /= rhs
    lhs.floatOpacity /= rhs
}
@inlinable
@inline(__always)
public func +=<Model> (lhs: inout FloatColorPixel<Model>, rhs: FloatColorPixel<Model>) {
    lhs.floatColor += rhs.floatColor
    lhs.floatOpacity += rhs.floatOpacity
}
@inlinable
@inline(__always)
public func -=<Model> (lhs: inout FloatColorPixel<Model>, rhs: FloatColorPixel<Model>) {
    lhs.floatColor -= rhs.floatColor
    lhs.floatOpacity -= rhs.floatOpacity
}

