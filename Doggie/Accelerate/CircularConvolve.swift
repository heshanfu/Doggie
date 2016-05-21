//
//  CircularConvolve.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

public func Radix2CircularConvolve(level: Int, _ signal: UnsafePointer<Float>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Float>, _ kernel_stride: Int, _ kernel_count: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    let length = 1 << level
    let half = length >> 1
    
    if signal_count == 0 || kernel_count == 0 {
        var output = output
        for _ in 0..<length {
            output.memory = 0
            output += out_stride
        }
        return
    }
    
    var _sreal = temp
    var _simag = temp + temp_stride
    var _kreal = output
    var _kimag = output + out_stride
    
    let s_stride = temp_stride << 1
    let k_stride = out_stride << 1
    
    HalfRadix2CooleyTukey(level, signal, signal_stride, signal_count, _sreal, _simag, s_stride)
    HalfRadix2CooleyTukey(level, kernel, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / Float(length)
    _sreal.memory *= m * _kreal.memory
    _simag.memory *= m * _kimag.memory
    for _ in 1..<half {
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
    }
    
    HalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, k_stride, output, out_stride, temp, temp + temp_stride, k_stride)
}

public func Radix2CircularConvolve(level: Int, _ signal: UnsafePointer<Double>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Double>, _ kernel_stride: Int, _ kernel_count: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    let length = 1 << level
    let half = length >> 1
    
    if signal_count == 0 || kernel_count == 0 {
        var output = output
        for _ in 0..<length {
            output.memory = 0
            output += out_stride
        }
        return
    }
    
    var _sreal = temp
    var _simag = temp + temp_stride
    var _kreal = output
    var _kimag = output + out_stride
    
    let s_stride = temp_stride << 1
    let k_stride = out_stride << 1
    
    HalfRadix2CooleyTukey(level, signal, signal_stride, signal_count, _sreal, _simag, s_stride)
    HalfRadix2CooleyTukey(level, kernel, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / Double(length)
    _sreal.memory *= m * _kreal.memory
    _simag.memory *= m * _kimag.memory
    for _ in 1..<half {
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
    }
    
    HalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, k_stride, output, out_stride, temp, temp + temp_stride, k_stride)
}

public func Radix2CircularConvolve(level: Int, _ sreal: UnsafePointer<Float>, _ simag: UnsafePointer<Float>, _ signal_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<Float>, _ kimag: UnsafePointer<Float>, _ kernel_stride: Int, _ kernel_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    let length = 1 << level
    
    if signal_count == 0 || kernel_count == 0 {
        var _real = _real
        var _imag = _imag
        for _ in 0..<length {
            _real.memory = 0
            _imag.memory = 0
            _real += out_stride
            _imag += out_stride
        }
        return
    }
    
    var _sreal = treal
    var _simag = timag
    var _kreal = _real
    var _kimag = _imag
    
    let s_stride = temp_stride
    let k_stride = out_stride
    
    Radix2CooleyTukey(level, sreal, simag, signal_stride, signal_count, _sreal, _simag, s_stride)
    Radix2CooleyTukey(level, kreal, kimag, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / Float(length)
    for _ in 0..<length {
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
    }
    
    InverseRadix2CooleyTukey(level, treal, timag, temp_stride, length, _real, _imag, out_stride)
}

public func Radix2CircularConvolve(level: Int, _ sreal: UnsafePointer<Double>, _ simag: UnsafePointer<Double>, _ signal_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<Double>, _ kimag: UnsafePointer<Double>, _ kernel_stride: Int, _ kernel_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    let length = 1 << level
    
    if signal_count == 0 || kernel_count == 0 {
        var _real = _real
        var _imag = _imag
        for _ in 0..<length {
            _real.memory = 0
            _imag.memory = 0
            _real += out_stride
            _imag += out_stride
        }
        return
    }
    
    var _sreal = treal
    var _simag = timag
    var _kreal = _real
    var _kimag = _imag
    
    let s_stride = temp_stride
    let k_stride = out_stride
    
    Radix2CooleyTukey(level, sreal, simag, signal_stride, signal_count, _sreal, _simag, s_stride)
    Radix2CooleyTukey(level, kreal, kimag, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / Double(length)
    for _ in 0..<length {
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
    }
    
    InverseRadix2CooleyTukey(level, treal, timag, temp_stride, length, _real, _imag, out_stride)
}

public func DispatchRadix2CircularConvolve(level: Int, _ signal: UnsafePointer<Float>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Float>, _ kernel_stride: Int, _ kernel_count: Int, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    let length = 1 << level
    let half = length >> 1
    
    if signal_count == 0 || kernel_count == 0 {
        var output = output
        for _ in 0..<length {
            output.memory = 0
            output += out_stride
        }
        return
    }
    
    var _sreal = temp
    var _simag = temp + temp_stride
    var _kreal = output
    var _kimag = output + out_stride
    
    let s_stride = temp_stride << 1
    let k_stride = out_stride << 1
    
    DispatchHalfRadix2CooleyTukey(level, signal, signal_stride, signal_count, _sreal, _simag, s_stride)
    DispatchHalfRadix2CooleyTukey(level, kernel, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / Float(length)
    _sreal.memory *= m * _kreal.memory
    _simag.memory *= m * _kimag.memory
    for _ in 1..<half {
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
    }
    
    DispatchHalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, k_stride, output, out_stride, temp, temp + temp_stride, k_stride)
}

public func DispatchRadix2CircularConvolve(level: Int, _ signal: UnsafePointer<Double>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<Double>, _ kernel_stride: Int, _ kernel_count: Int, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    let length = 1 << level
    let half = length >> 1
    
    if signal_count == 0 || kernel_count == 0 {
        var output = output
        for _ in 0..<length {
            output.memory = 0
            output += out_stride
        }
        return
    }
    
    var _sreal = temp
    var _simag = temp + temp_stride
    var _kreal = output
    var _kimag = output + out_stride
    
    let s_stride = temp_stride << 1
    let k_stride = out_stride << 1
    
    DispatchHalfRadix2CooleyTukey(level, signal, signal_stride, signal_count, _sreal, _simag, s_stride)
    DispatchHalfRadix2CooleyTukey(level, kernel, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / Double(length)
    _sreal.memory *= m * _kreal.memory
    _simag.memory *= m * _kimag.memory
    for _ in 1..<half {
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
    }
    
    DispatchHalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, k_stride, output, out_stride, temp, temp + temp_stride, k_stride)
}

public func DispatchRadix2CircularConvolve(level: Int, _ sreal: UnsafePointer<Float>, _ simag: UnsafePointer<Float>, _ signal_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<Float>, _ kimag: UnsafePointer<Float>, _ kernel_stride: Int, _ kernel_count: Int, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    let length = 1 << level
    
    if signal_count == 0 || kernel_count == 0 {
        var _real = _real
        var _imag = _imag
        for _ in 0..<length {
            _real.memory = 0
            _imag.memory = 0
            _real += out_stride
            _imag += out_stride
        }
        return
    }
    
    var _sreal = treal
    var _simag = timag
    var _kreal = _real
    var _kimag = _imag
    
    let s_stride = temp_stride
    let k_stride = out_stride
    
    DispatchRadix2CooleyTukey(level, sreal, simag, signal_stride, signal_count, _sreal, _simag, s_stride)
    DispatchRadix2CooleyTukey(level, kreal, kimag, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / Float(length)
    for _ in 0..<length {
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, treal, timag, temp_stride, length, _real, _imag, out_stride)
}

public func DispatchRadix2CircularConvolve(level: Int, _ sreal: UnsafePointer<Double>, _ simag: UnsafePointer<Double>, _ signal_stride: Int, _ signal_count: Int, _ kreal: UnsafePointer<Double>, _ kimag: UnsafePointer<Double>, _ kernel_stride: Int, _ kernel_count: Int, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    let length = 1 << level
    
    if signal_count == 0 || kernel_count == 0 {
        var _real = _real
        var _imag = _imag
        for _ in 0..<length {
            _real.memory = 0
            _imag.memory = 0
            _real += out_stride
            _imag += out_stride
        }
        return
    }
    
    var _sreal = treal
    var _simag = timag
    var _kreal = _real
    var _kimag = _imag
    
    let s_stride = temp_stride
    let k_stride = out_stride
    
    DispatchRadix2CooleyTukey(level, sreal, simag, signal_stride, signal_count, _sreal, _simag, s_stride)
    DispatchRadix2CooleyTukey(level, kreal, kimag, kernel_stride, kernel_count, _kreal, _kimag, k_stride)
    
    let m = 1 / Double(length)
    for _ in 0..<length {
        let _sr = _sreal.memory
        let _si = _simag.memory
        let _kr = m * _kreal.memory
        let _ki = m * _kimag.memory
        _sreal.memory = _sr * _kr - _si * _ki
        _simag.memory = _sr * _ki + _si * _kr
        _sreal += s_stride
        _simag += s_stride
        _kreal += k_stride
        _kimag += k_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, treal, timag, temp_stride, length, _real, _imag, out_stride)
}

public func Radix2PowerCircularConvolve(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ n: Float, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    let length = 1 << level
    let half = length >> 1
    
    if in_count == 0 {
        var output = output
        for _ in 0..<length {
            output.memory = 0
            output += out_stride
        }
        return
    }
    
    var _treal = temp
    var _timag = temp + temp_stride
    let t_stride = temp_stride << 1
    HalfRadix2CooleyTukey(level, input, in_stride, in_count, _treal, _timag, t_stride)
    
    let m = 1 / Float(length)
    _treal.memory = m * pow(_treal.memory, n)
    _timag.memory = m * pow(_timag.memory, n)
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
    }
    
    HalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, t_stride, output, out_stride, temp, temp + temp_stride, t_stride)
}

public func Radix2PowerCircularConvolve(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ n: Double, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    let length = 1 << level
    let half = length >> 1
    
    if in_count == 0 {
        var output = output
        for _ in 0..<length {
            output.memory = 0
            output += out_stride
        }
        return
    }
    
    var _treal = temp
    var _timag = temp + temp_stride
    let t_stride = temp_stride << 1
    HalfRadix2CooleyTukey(level, input, in_stride, in_count, _treal, _timag, t_stride)
    
    let m = 1 / Double(length)
    _treal.memory = m * pow(_treal.memory, n)
    _timag.memory = m * pow(_timag.memory, n)
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
    }
    
    HalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, t_stride, output, out_stride, temp, temp + temp_stride, t_stride)
}

public func Radix2PowerCircularConvolve(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ n: Float, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    let length = 1 << level
    
    if in_count == 0 {
        var _real = _real
        var _imag = _imag
        for _ in 0..<length {
            _real.memory = 0
            _imag.memory = 0
            _real += out_stride
            _imag += out_stride
        }
        return
    }
    
    Radix2CooleyTukey(level, real, imag, in_stride, in_count, treal, timag, temp_stride)
    
    var _treal = treal
    var _timag = timag
    let m = 1 / Float(length)
    for _ in 0..<length {
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
        _treal += temp_stride
        _timag += temp_stride
    }
    
    InverseRadix2CooleyTukey(level, treal, timag, temp_stride, length, _real, _imag, out_stride)
}

public func Radix2PowerCircularConvolve(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ n: Double, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    let length = 1 << level
    
    if in_count == 0 {
        var _real = _real
        var _imag = _imag
        for _ in 0..<length {
            _real.memory = 0
            _imag.memory = 0
            _real += out_stride
            _imag += out_stride
        }
        return
    }
    
    Radix2CooleyTukey(level, real, imag, in_stride, in_count, treal, timag, temp_stride)
    
    var _treal = treal
    var _timag = timag
    let m = 1 / Double(length)
    for _ in 0..<length {
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
        _treal += temp_stride
        _timag += temp_stride
    }
    
    InverseRadix2CooleyTukey(level, treal, timag, temp_stride, length, _real, _imag, out_stride)
}

public func DispatchRadix2PowerCircularConvolve(level: Int, _ input: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ n: Float, _ output: UnsafeMutablePointer<Float>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    let length = 1 << level
    let half = length >> 1
    
    if in_count == 0 {
        var output = output
        for _ in 0..<length {
            output.memory = 0
            output += out_stride
        }
        return
    }
    
    var _treal = temp
    var _timag = temp + temp_stride
    let t_stride = temp_stride << 1
    DispatchHalfRadix2CooleyTukey(level, input, in_stride, in_count, _treal, _timag, t_stride)
    
    let m = 1 / Float(length)
    _treal.memory = m * pow(_treal.memory, n)
    _timag.memory = m * pow(_timag.memory, n)
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
    }
    
    DispatchHalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, t_stride, output, out_stride, temp, temp + temp_stride, t_stride)
}

public func DispatchRadix2PowerCircularConvolve(level: Int, _ input: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ n: Double, _ output: UnsafeMutablePointer<Double>, _ out_stride: Int, _ temp: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    let length = 1 << level
    let half = length >> 1
    
    if in_count == 0 {
        var output = output
        for _ in 0..<length {
            output.memory = 0
            output += out_stride
        }
        return
    }
    
    var _treal = temp
    var _timag = temp + temp_stride
    let t_stride = temp_stride << 1
    DispatchHalfRadix2CooleyTukey(level, input, in_stride, in_count, _treal, _timag, t_stride)
    
    let m = 1 / Double(length)
    _treal.memory = m * pow(_treal.memory, n)
    _timag.memory = m * pow(_timag.memory, n)
    for _ in 1..<half {
        _treal += t_stride
        _timag += t_stride
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
    }
    
    DispatchHalfInverseRadix2CooleyTukey(level, temp, temp + temp_stride, t_stride, output, out_stride, temp, temp + temp_stride, t_stride)
}

public func DispatchRadix2PowerCircularConvolve(level: Int, _ real: UnsafePointer<Float>, _ imag: UnsafePointer<Float>, _ in_stride: Int, _ in_count: Int, _ n: Float, _ _real: UnsafeMutablePointer<Float>, _ _imag: UnsafeMutablePointer<Float>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Float>, _ timag: UnsafeMutablePointer<Float>, _ temp_stride: Int) {
    
    let length = 1 << level
    
    if in_count == 0 {
        var _real = _real
        var _imag = _imag
        for _ in 0..<length {
            _real.memory = 0
            _imag.memory = 0
            _real += out_stride
            _imag += out_stride
        }
        return
    }
    
    DispatchRadix2CooleyTukey(level, real, imag, in_stride, in_count, treal, timag, temp_stride)
    
    var _treal = treal
    var _timag = timag
    let m = 1 / Float(length)
    for _ in 0..<length {
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
        _treal += temp_stride
        _timag += temp_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, treal, timag, temp_stride, length, _real, _imag, out_stride)
}

public func DispatchRadix2PowerCircularConvolve(level: Int, _ real: UnsafePointer<Double>, _ imag: UnsafePointer<Double>, _ in_stride: Int, _ in_count: Int, _ n: Double, _ _real: UnsafeMutablePointer<Double>, _ _imag: UnsafeMutablePointer<Double>, _ out_stride: Int, _ treal: UnsafeMutablePointer<Double>, _ timag: UnsafeMutablePointer<Double>, _ temp_stride: Int) {
    
    let length = 1 << level
    
    if in_count == 0 {
        var _real = _real
        var _imag = _imag
        for _ in 0..<length {
            _real.memory = 0
            _imag.memory = 0
            _real += out_stride
            _imag += out_stride
        }
        return
    }
    
    DispatchRadix2CooleyTukey(level, real, imag, in_stride, in_count, treal, timag, temp_stride)
    
    var _treal = treal
    var _timag = timag
    let m = 1 / Double(length)
    for _ in 0..<length {
        let _r = _treal.memory
        let _i = _timag.memory
        let _pow = m * pow(_r * _r + _i * _i, 0.5 * n)
        let _arg = n * atan2(_i, _r)
        _treal.memory = _pow * cos(_arg)
        _timag.memory = _pow * sin(_arg)
        _treal += temp_stride
        _timag += temp_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, treal, timag, temp_stride, length, _real, _imag, out_stride)
}

public func Radix2CircularConvolve<U: UnsignedIntegerType>(level: Int, _ signal: UnsafePointer<U>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<U>, _ kernel_stride: Int, _ kernel_count: Int, _ alpha: U, _ mod: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int, _ temp: UnsafeMutablePointer<U>, _ temp_stride: Int) {
    
    let length = 1 << level
    
    if signal_count == 0 || kernel_count == 0 {
        var output = output
        for _ in 0..<length {
            output.memory = 0
            output += out_stride
        }
        return
    }
    
    var _signal = output
    var _kernel = temp
    
    Radix2CooleyTukey(level, signal, signal_stride, signal_count, alpha, mod, _signal, out_stride)
    Radix2CooleyTukey(level, kernel, kernel_stride, kernel_count, alpha, mod, _kernel, temp_stride)
    
    let _n = modinv(U(UIntMax(length)), mod)
    for _ in 0..<length {
        let _s = _signal.memory
        let _k = mulmod(_kernel.memory, _n, mod)
        _kernel.memory = mulmod(_s, _k, mod)
        _signal += out_stride
        _kernel += temp_stride
    }
    
    InverseRadix2CooleyTukey(level, temp, temp_stride, length, alpha, mod, output, out_stride)
}

public func DispatchRadix2CircularConvolve<U: UnsignedIntegerType>(level: Int, _ signal: UnsafePointer<U>, _ signal_stride: Int, _ signal_count: Int, _ kernel: UnsafePointer<U>, _ kernel_stride: Int, _ kernel_count: Int, _ alpha: U, _ mod: U, _ output: UnsafeMutablePointer<U>, _ out_stride: Int, _ temp: UnsafeMutablePointer<U>, _ temp_stride: Int) {
    
    let length = 1 << level
    
    if signal_count == 0 || kernel_count == 0 {
        var output = output
        for _ in 0..<length {
            output.memory = 0
            output += out_stride
        }
        return
    }
    
    var _signal = output
    var _kernel = temp
    
    DispatchRadix2CooleyTukey(level, signal, signal_stride, signal_count, alpha, mod, _signal, out_stride)
    DispatchRadix2CooleyTukey(level, kernel, kernel_stride, kernel_count, alpha, mod, _kernel, temp_stride)
    
    let _n = modinv(U(UIntMax(length)), mod)
    for _ in 0..<length {
        let _s = _signal.memory
        let _k = mulmod(_kernel.memory, _n, mod)
        _kernel.memory = mulmod(_s, _k, mod)
        _signal += out_stride
        _kernel += temp_stride
    }
    
    DispatchInverseRadix2CooleyTukey(level, temp, temp_stride, length, alpha, mod, output, out_stride)
}
