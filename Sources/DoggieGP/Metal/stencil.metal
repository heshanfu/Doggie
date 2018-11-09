//
//  stencil.metal
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

#include <metal_stdlib>
using namespace metal;

constant int countOfComponents [[function_constant(0)]];

const float cross(const float2 a, const float2 b);
const float3 Barycentric(const float2 p0, const float2 p1, const float2 p2, const float2 q);
const bool inTriangle(const float2 p0, const float2 p1, const float2 p2, const float2 position);

struct stencil_parameter {
    
    const packed_uint2 offset;
    const uint width;
};

struct stencil_triangle_struct {
    
    const packed_float2 p0, p1, p2;
};

struct stencil_quadratic_struct {
    
    const packed_float2 p0, p1, p2;
};

struct stencil_cubic_struct {
    
    const packed_float2 p0, p1, p2;
    const packed_float3 v0, v1, v2;
};

struct fill_stencil_parameter {
    
    const packed_uint2 offset;
    const uint width;
    const uint antialias;
    const float color[16];
};

kernel void stencil_triangle(const device stencil_parameter &parameter [[buffer(0)]],
                             const device stencil_triangle_struct *triangles [[buffer(1)]],
                             device int16_t *out [[buffer(2)]],
                             uint3 id [[thread_position_in_grid]]) {
    
    const int width = parameter.width;
    const int2 position = int2(id[0] + parameter.offset[0], id[1] + parameter.offset[1]);
    const int idx = width * position[1] + position[0];
    
    const stencil_triangle_struct triangle = triangles[id[2]];
    
    const float2 p0 = triangle.p0;
    const float2 p1 = triangle.p1;
    const float2 p2 = triangle.p2;
    
    if (inTriangle(p0, p1, p2, (float2)position)) {
        if (signbit(cross(p1 - p0, p2 - p0))) {
            --out[idx];
        } else {
            ++out[idx];
        }
    }
}

kernel void stencil_quadratic(const device stencil_parameter &parameter [[buffer(0)]],
                              const device stencil_quadratic_struct *triangles [[buffer(1)]],
                              device int16_t *out [[buffer(2)]],
                              uint3 id [[thread_position_in_grid]]) {
    
    const int width = parameter.width;
    const int2 position = int2(id[0] + parameter.offset[0], id[1] + parameter.offset[1]);
    const int idx = width * position[1] + position[0];
    
    const stencil_quadratic_struct triangle = triangles[id[2]];
    
    const float2 p0 = triangle.p0;
    const float2 p1 = triangle.p1;
    const float2 p2 = triangle.p2;
    
    if (inTriangle(p0, p1, p2, (float2)position)) {
        
        const float3 p = Barycentric(p0, p1, p2, (float2)position);
        const float s = 0.5 * p[1] + p[2];
        
        if (s * s < p[2]) {
            if (signbit(cross(p1 - p0, p2 - p0))) {
                --out[idx];
            } else {
                ++out[idx];
            }
        }
    }
}

kernel void stencil_cubic(const device stencil_parameter &parameter [[buffer(0)]],
                          const device stencil_cubic_struct *triangles [[buffer(1)]],
                          device int16_t *out [[buffer(2)]],
                          uint3 id [[thread_position_in_grid]]) {
    
    const int width = parameter.width;
    const int2 position = int2(id[0] + parameter.offset[0], id[1] + parameter.offset[1]);
    const int idx = width * position[1] + position[0];
    
    const stencil_cubic_struct triangle = triangles[id[2]];
    
    const float2 p0 = triangle.p0;
    const float2 p1 = triangle.p1;
    const float2 p2 = triangle.p2;
    const float3 v0 = triangle.v0;
    const float3 v1 = triangle.v1;
    const float3 v2 = triangle.v2;
    
    if (inTriangle(p0, p1, p2, (float2)position)) {
        
        const float3 p = Barycentric(p0, p1, p2, (float2)position);
        const float3 u0 = p[0] * v0;
        const float3 u1 = p[1] * v1;
        const float3 u2 = p[2] * v2;
        const float3 v = u0 + u1 + u2;
        
        if (v[0] * v[0] * v[0] < v[1] * v[2]) {
            if (signbit(cross(p1 - p0, p2 - p0))) {
                --out[idx];
            } else {
                ++out[idx];
            }
        }
    }
}

kernel void fill_nonZero_stencil(const device fill_stencil_parameter &parameter [[buffer(0)]],
                                 const device int16_t *stencil [[buffer(1)]],
                                 device float *out [[buffer(2)]],
                                 uint2 id [[thread_position_in_grid]]) {
    
    const int width = parameter.width;
    const int antialias = parameter.antialias;
    const int2 position = int2(id[0] + parameter.offset[0], id[1] + parameter.offset[1]);
    const int idx = width * position[1] + position[0];
    const int opacity_idx = countOfComponents - 1;
    
    const int stencil_width = width * antialias;
    const int2 stencil_position = position * antialias;
    
    int counter = 0;
    
    for (int i = 0; i < antialias; ++i) {
        for (int j = 0; j < antialias; ++j) {
            
            int stencil_index = stencil_width * (stencil_position[1] + i) + (stencil_position[0] + j);
            
            if (stencil[stencil_index] != 0) {
                counter += 1;
            }
        }
    }
    
    for (int i = 0; i < opacity_idx; ++i) {
        out[idx * countOfComponents + i] = parameter.color[i];
    }
    
    out[idx * countOfComponents + opacity_idx] = parameter.color[opacity_idx] * (float)counter / (float)(antialias * antialias);
}

kernel void fill_evenOdd_stencil(const device fill_stencil_parameter &parameter [[buffer(0)]],
                                 const device int16_t *stencil [[buffer(1)]],
                                 device float *out [[buffer(2)]],
                                 uint2 id [[thread_position_in_grid]]) {
    
    const int width = parameter.width;
    const int antialias = parameter.antialias;
    const int2 position = int2(id[0] + parameter.offset[0], id[1] + parameter.offset[1]);
    const int idx = width * position[1] + position[0];
    const int opacity_idx = countOfComponents - 1;
    
    const int stencil_width = width * antialias;
    const int2 stencil_position = position * antialias;
    
    int counter = 0;
    
    for (int i = 0; i < antialias; ++i) {
        for (int j = 0; j < antialias; ++j) {
            
            int stencil_index = stencil_width * (stencil_position[1] + i) + (stencil_position[0] + j);
            
            if ((stencil[stencil_index] & 1) != 0) {
                counter += 1;
            }
        }
    }
    
    for (int i = 0; i < opacity_idx; ++i) {
        out[idx * countOfComponents + i] = parameter.color[i];
    }
    
    out[idx * countOfComponents + opacity_idx] = parameter.color[opacity_idx] * (float)counter / (float)(antialias * antialias);
}