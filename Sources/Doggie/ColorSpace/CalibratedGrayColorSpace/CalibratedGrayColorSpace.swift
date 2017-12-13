//
//  CalibratedGrayColorSpace.swift
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

extension ColorSpace where Model == GrayColorModel {
    
    @_inlineable
    public static func calibratedGray<C>(from colorSpace: ColorSpace<C>, gamma: Double = 1) -> ColorSpace {
        return ColorSpace(base: CalibratedGrayColorSpace(colorSpace.base.cieXYZ, gamma: gamma))
    }
    
    @_inlineable
    public static func calibratedGray(white: Point, gamma: Double = 1) -> ColorSpace {
        return ColorSpace(base: CalibratedGrayColorSpace(CIEXYZColorSpace(white: white), gamma: gamma))
    }
}

@_versioned
@_fixed_layout
struct CalibratedGrayColorSpace : ColorSpaceBaseProtocol {
    
    typealias Model = GrayColorModel
    
    @_versioned
    let cieXYZ: CIEXYZColorSpace
    
    @_versioned
    let gamma: Double
    
    @_versioned
    @_inlineable
    init(_ cieXYZ: CIEXYZColorSpace, gamma: Double) {
        self.cieXYZ = cieXYZ
        self.gamma = gamma
    }
}

extension CalibratedGrayColorSpace {
    
    @_versioned
    @_inlineable
    func iccCurve() -> iccCurve {
        return .gamma(gamma)
    }
}

extension CalibratedGrayColorSpace {
    
    @_versioned
    @_inlineable
    var localizedName: String? {
        return "Doggie Calibrated Gray Color Space (white = \(cieXYZ.white.point), gamma = \(gamma))"
    }
}

extension CalibratedGrayColorSpace {
    
    @_versioned
    @_inlineable
    static func ==(lhs: CalibratedGrayColorSpace, rhs: CalibratedGrayColorSpace) -> Bool {
        return lhs.cieXYZ == rhs.cieXYZ && lhs.gamma == rhs.gamma
    }
}

extension CalibratedGrayColorSpace {
    
    @_versioned
    @_inlineable
    var linearTone: CalibratedGrayColorSpace {
        return CalibratedGrayColorSpace(cieXYZ, gamma: 1)
    }
}

extension CalibratedGrayColorSpace {
    
    @_versioned
    @_inlineable
    func convertToLinear(_ color: GrayColorModel) -> GrayColorModel {
        return GrayColorModel(white: exteneded(color.white) { pow($0, gamma) })
    }
    
    @_versioned
    @_inlineable
    func convertFromLinear(_ color: GrayColorModel) -> GrayColorModel {
        return GrayColorModel(white: exteneded(color.white) { pow($0, 1 / gamma) })
    }
    
    @_versioned
    @_inlineable
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        let normalizeMatrix = cieXYZ.normalizeMatrix
        let _white = cieXYZ.white * normalizeMatrix
        return XYZColorModel(luminance: color.white, point: _white.point) * normalizeMatrix.inverse
    }
    
    @_versioned
    @_inlineable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        let normalized = color * cieXYZ.normalizeMatrix
        return Model(white: normalized.luminance)
    }
}

