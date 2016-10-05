//
//  Thread.swift
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
import Dispatch
import c11_atomic

public protocol SDAtomicProtocol {
    
    associatedtype Atom
    
    /// Atomic fetch the current value.
    mutating func fetchSelf() -> (current: Self, value: Atom)
    
    /// Compare and set the value.
    mutating func compareSet(old: Self, new: Atom) -> Bool
}

public extension SDAtomicProtocol {
    
    /// Atomic fetch the current value.
    public mutating func fetch() -> Atom {
        return self.fetchSelf().value
    }
    
    /// Atomic set the value.
    public mutating func store(_ new: Atom) {
        self.fetchStore { _ in new }
    }
    
    /// Set the value, and returns the previous value.
    public mutating func fetchStore(_ new: Atom) -> Atom {
        return self.fetchStore { _ in new }
    }
    
    /// Set the value, and returns the previous value. `block` is called repeatedly until result accepted.
    @discardableResult
    public mutating func fetchStore(block: (Atom) throws -> Atom) rethrows -> Atom {
        while true {
            let (old, oldVal) = self.fetchSelf()
            if self.compareSet(old: old, new: try block(oldVal)) {
                return oldVal
            }
        }
    }
}

extension Bool : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: Bool, value: Bool) {
        let val = _AtomicLoadBoolBarrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: Bool) {
        _AtomicStoreBoolBarrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: Bool, new: Bool) -> Bool {
        return _AtomicCompareAndSwapBoolBarrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: Bool) -> Bool {
        return _AtomicExchangeBoolBarrier(new, &self)
    }
}

extension Int8 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: Int8, value: Int8) {
        let val = _AtomicLoad8Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: Int8) {
        _AtomicStore8Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: Int8, new: Int8) -> Bool {
        return _AtomicCompareAndSwap8Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: Int8) -> Int8 {
        return _AtomicExchange8Barrier(new, &self)
    }
}

extension Int16 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: Int16, value: Int16) {
        let val = _AtomicLoad16Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: Int16) {
        _AtomicStore16Barrier(new, &self)
    }
    
    /// Set value with barrier.
    public mutating func compareSet(old: Int16, new: Int16) -> Bool {
        return _AtomicCompareAndSwap16Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: Int16) -> Int16 {
        return _AtomicExchange16Barrier(new, &self)
    }
}

extension Int32 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: Int32, value: Int32) {
        let val = _AtomicLoad32Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: Int32) {
        _AtomicStore32Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: Int32, new: Int32) -> Bool {
        return _AtomicCompareAndSwap32Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: Int32) -> Int32 {
        return _AtomicExchange32Barrier(new, &self)
    }
}

extension Int64 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: Int64, value: Int64) {
        let val = _AtomicLoad64Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: Int64) {
        _AtomicStore64Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: Int64, new: Int64) -> Bool {
        return _AtomicCompareAndSwap64Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: Int64) -> Int64 {
        return _AtomicExchange64Barrier(new, &self)
    }
}

extension Int : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: Int, value: Int) {
        let val = _AtomicLoadLongBarrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: Int) {
        _AtomicStoreLongBarrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: Int, new: Int) -> Bool {
        return _AtomicCompareAndSwapLongBarrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: Int) -> Int {
        return _AtomicExchangeLongBarrier(new, &self)
    }
}

extension UInt8 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UInt8, value: UInt8) {
        let val = _AtomicLoadU8Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UInt8) {
        _AtomicStoreU8Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: UInt8, new: UInt8) -> Bool {
        return _AtomicCompareAndSwapU8Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: UInt8) -> UInt8 {
        return _AtomicExchangeU8Barrier(new, &self)
    }
}

extension UInt16 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UInt16, value: UInt16) {
        let val = _AtomicLoadU16Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UInt16) {
        _AtomicStoreU16Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: UInt16, new: UInt16) -> Bool {
        return _AtomicCompareAndSwapU16Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: UInt16) -> UInt16 {
        return _AtomicExchangeU16Barrier(new, &self)
    }
}

extension UInt32 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UInt32, value: UInt32) {
        let val = _AtomicLoadU32Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UInt32) {
        _AtomicStoreU32Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: UInt32, new: UInt32) -> Bool {
        return _AtomicCompareAndSwapU32Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: UInt32) -> UInt32 {
        return _AtomicExchangeU32Barrier(new, &self)
    }
}

extension UInt64 : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UInt64, value: UInt64) {
        let val = _AtomicLoadU64Barrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UInt64) {
        _AtomicStoreU64Barrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: UInt64, new: UInt64) -> Bool {
        return _AtomicCompareAndSwapU64Barrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: UInt64) -> UInt64 {
        return _AtomicExchangeU64Barrier(new, &self)
    }
}

extension UInt : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UInt, value: UInt) {
        let val = _AtomicLoadULongBarrier(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UInt) {
        _AtomicStoreULongBarrier(new, &self)
    }
    
    /// Compare and set value with barrier.
    public mutating func compareSet(old: UInt, new: UInt) -> Bool {
        return _AtomicCompareAndSwapULongBarrier(old, new, &self)
    }
    
    /// Set value with barrier.
    public mutating func fetchStore(_ new: UInt) -> UInt {
        return _AtomicExchangeULongBarrier(new, &self)
    }
}

extension UnsafePointer : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UnsafePointer, value: UnsafePointer) {
        @_transparent
        func load(_ theVal: UnsafeMutablePointer<UnsafePointer<Pointee>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeRawPointer>.self, capacity: 1) { _AtomicLoadPtrBarrier($0) }
        }
        let val = UnsafePointer(load(&self).assumingMemoryBound(to: Pointee.self))
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UnsafePointer) {
        @_transparent
        func store(_ theVal: UnsafeMutablePointer<UnsafePointer<Pointee>>) {
            theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicStorePtrBarrier(UnsafeMutableRawPointer(mutating: new), $0) }
        }
        store(&self)
    }
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafePointer, new: UnsafePointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafePointer<Pointee>>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(mutating: old), UnsafeMutableRawPointer(mutating: new), $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(_ new: UnsafePointer) -> UnsafePointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UnsafePointer<Pointee>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(UnsafeMutableRawPointer(mutating: new), $0) }
        }
        return UnsafePointer(exchange(&self).assumingMemoryBound(to: Pointee.self))
    }
}

extension UnsafeMutablePointer : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UnsafeMutablePointer, value: UnsafeMutablePointer) {
        @_transparent
        func load(_ theVal: UnsafeMutablePointer<UnsafeMutablePointer<Pointee>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeRawPointer>.self, capacity: 1) { _AtomicLoadPtrBarrier($0) }
        }
        let val = load(&self).assumingMemoryBound(to: Pointee.self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UnsafeMutablePointer) {
        @_transparent
        func store(_ theVal: UnsafeMutablePointer<UnsafeMutablePointer<Pointee>>) {
            theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicStorePtrBarrier(UnsafeMutableRawPointer(new), $0) }
        }
        store(&self)
    }
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafeMutablePointer, new: UnsafeMutablePointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafeMutablePointer<Pointee>>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(old), UnsafeMutableRawPointer(new), $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(_ new: UnsafeMutablePointer) -> UnsafeMutablePointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UnsafeMutablePointer<Pointee>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(UnsafeMutableRawPointer(new), $0) }
        }
        return exchange(&self).assumingMemoryBound(to: Pointee.self)
    }
}
extension UnsafeRawPointer : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UnsafeRawPointer, value: UnsafeRawPointer) {
        @_transparent
        func load(_ theVal: UnsafeMutablePointer<UnsafeRawPointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeRawPointer>.self, capacity: 1) { _AtomicLoadPtrBarrier($0) }
        }
        let val = UnsafeRawPointer(load(&self))
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UnsafeRawPointer) {
        @_transparent
        func store(_ theVal: UnsafeMutablePointer<UnsafeRawPointer>) {
            theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicStorePtrBarrier(UnsafeMutableRawPointer(mutating: new), $0) }
        }
        store(&self)
    }
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafeRawPointer, new: UnsafeRawPointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafeRawPointer>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(mutating: old), UnsafeMutableRawPointer(mutating: new), $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(_ new: UnsafeRawPointer) -> UnsafeRawPointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UnsafeRawPointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(UnsafeMutableRawPointer(mutating: new), $0) }
        }
        return UnsafeRawPointer(exchange(&self))
    }
}

extension UnsafeMutableRawPointer : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: UnsafeMutableRawPointer, value: UnsafeMutableRawPointer) {
        @_transparent
        func load(_ theVal: UnsafeMutablePointer<UnsafeMutableRawPointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeRawPointer>.self, capacity: 1) { _AtomicLoadPtrBarrier($0) }
        }
        let val = load(&self)
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: UnsafeMutableRawPointer) {
        @_transparent
        func store(_ theVal: UnsafeMutablePointer<UnsafeMutableRawPointer>) {
            theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicStorePtrBarrier(new, $0) }
        }
        store(&self)
    }
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: UnsafeMutableRawPointer, new: UnsafeMutableRawPointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<UnsafeMutableRawPointer>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(old, new, $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(_ new: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<UnsafeMutableRawPointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(new, $0) }
        }
        return exchange(&self)
    }
}

extension OpaquePointer : SDAtomicProtocol {
    
    /// Atomic fetch the current value with barrier.
    public mutating func fetchSelf() -> (current: OpaquePointer, value: OpaquePointer) {
        @_transparent
        func load(_ theVal: UnsafeMutablePointer<OpaquePointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeRawPointer>.self, capacity: 1) { _AtomicLoadPtrBarrier($0) }
        }
        let val = OpaquePointer(load(&self))
        return (val, val)
    }
    
    /// Atomic sets the value with barrier.
    public mutating func store(_ new: OpaquePointer) {
        @_transparent
        func store(_ theVal: UnsafeMutablePointer<OpaquePointer>) {
            theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicStorePtrBarrier(UnsafeMutableRawPointer(new), $0) }
        }
        store(&self)
    }
    
    /// Compare and set pointers with barrier.
    public mutating func compareSet(old: OpaquePointer, new: OpaquePointer) -> Bool {
        @_transparent
        func cas(_ theVal: UnsafeMutablePointer<OpaquePointer>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(UnsafeMutableRawPointer(old), UnsafeMutableRawPointer(new), $0) }
        }
        return cas(&self)
    }
    
    /// Set pointers with barrier.
    public mutating func fetchStore(_ new: OpaquePointer) -> OpaquePointer {
        @_transparent
        func exchange(_ theVal: UnsafeMutablePointer<OpaquePointer>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(UnsafeMutableRawPointer(new), $0) }
        }
        return OpaquePointer(exchange(&self))
    }
}

private class AtomicBase<Instance> {
    
    var value: Instance!
    
    init(value: Instance! = nil) {
        self.value = value
    }
}

public struct Atomic<Instance> {
    
    fileprivate var base: AtomicBase<Instance>
    
    fileprivate init(base: AtomicBase<Instance>) {
        self.base = base
    }
    
    public init(value: Instance) {
        self.base = AtomicBase(value: value)
    }
    
    public var value : Instance {
        get {
            return base.value
        }
        set {
            _fetchStore(AtomicBase(value: newValue))
        }
    }
}

extension Atomic {
    
    @_transparent
    fileprivate mutating func _fetch() -> AtomicBase<Instance> {
        @_transparent
        func exchange(theVal: UnsafeMutablePointer<AtomicBase<Instance>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeRawPointer>.self, capacity: 1) { _AtomicLoadPtrBarrier($0) }
        }
        let _old = Unmanaged<AtomicBase<Instance>>.fromOpaque(UnsafeRawPointer(exchange(theVal: &base)))
        return _old.takeUnretainedValue()
    }
    
    @_transparent
    fileprivate mutating func _compareSet(old: AtomicBase<Instance>, new: AtomicBase<Instance>) -> Bool {
        let _old = Unmanaged.passUnretained(old)
        let _new = Unmanaged.passRetained(new)
        @_transparent
        func cas(theVal: UnsafeMutablePointer<AtomicBase<Instance>>) -> Bool {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicCompareAndSwapPtrBarrier(_old.toOpaque(), _new.toOpaque(), $0) }
        }
        let result = cas(theVal: &base)
        if result {
            _old.release()
        } else {
            _new.release()
        }
        return result
    }
    
    @_transparent
    @discardableResult
    fileprivate mutating func _fetchStore(_ new: AtomicBase<Instance>) -> AtomicBase<Instance> {
        let _new = Unmanaged.passRetained(new)
        @_transparent
        func exchange(theVal: UnsafeMutablePointer<AtomicBase<Instance>>) -> UnsafeMutableRawPointer {
            return theVal.withMemoryRebound(to: Optional<UnsafeMutableRawPointer>.self, capacity: 1) { _AtomicExchangePtrBarrier(_new.toOpaque(), $0) }
        }
        let _old = Unmanaged<AtomicBase<Instance>>.fromOpaque(UnsafeRawPointer(exchange(theVal: &base)))
        return _old.takeRetainedValue()
    }
}

extension Atomic : SDAtomicProtocol {
    
    /// Atomic fetch the current value.
    public mutating func fetchSelf() -> (current: Atomic, value: Instance) {
        let _base = _fetch()
        return (Atomic(base: _base), _base.value)
    }
    
    /// Compare and set the value.
    public mutating func compareSet(old: Atomic, new: Instance) -> Bool {
        return self._compareSet(old: old.base, new: AtomicBase(value: new))
    }
    
    /// Set the value, and returns the previous value.
    public mutating func fetchStore(_ new: Instance) -> Instance {
        return _fetchStore(AtomicBase(value: new)).value
    }
    
    /// Set the value.
    @discardableResult
    public mutating func fetchStore(block: (Instance) throws -> Instance) rethrows -> Instance {
        let new = AtomicBase<Instance>()
        while true {
            let old = self.base
            new.value = try block(old.value)
            if self._compareSet(old: old, new: new) {
                return old.value
            }
        }
    }
}

extension Atomic where Instance : Equatable {
    
    /// Compare and set the value.
    public mutating func compareSet(old: Instance, new: Instance) -> Bool {
        while true {
            let (current, currentVal) = self.fetchSelf()
            if currentVal != old {
                return false
            }
            if compareSet(old: current, new: new) {
                return true
            }
        }
    }
}

extension Atomic: CustomStringConvertible {
    
    public var description: String {
        return "Atomic(\(base.value))"
    }
}

// MARK: Lockable

public protocol Lockable : class {
    
    func lock()
    func unlock()
    func trylock() -> Bool
}

public extension Lockable {
    
    func lock() {
        while !trylock() {
            sched_yield()
        }
    }
}

public extension Lockable {
    
    @discardableResult
    func synchronized<R>(block: () throws -> R) rethrows -> R {
        self.lock()
        defer { self.unlock() }
        return try block()
    }
}

@discardableResult
public func synchronized<R>(_ obj: AnyObject, block: () throws -> R) rethrows -> R {
    objc_sync_enter(obj)
    defer { objc_sync_exit(obj) }
    return try block()
}

@discardableResult
public func synchronized<R>(_ lcks: Lockable ... , block: () throws -> R) rethrows -> R {
    if lcks.count > 1 {
        var waiting = 0
        while true {
            lcks[waiting].lock()
            if let failed = lcks.enumerated().first(where: { $0 != waiting && !$1.trylock() })?.0 {
                for (index, item) in lcks.prefix(upTo: failed).enumerated() where index != waiting {
                    item.unlock()
                }
                lcks[waiting].unlock()
                waiting = failed
            } else {
                break
            }
        }
    } else {
        lcks.first?.lock()
    }
    defer {
        for item in lcks {
            item.unlock()
        }
    }
    return try block()
}

// MARK: Lock

public class SDLock {
    
    fileprivate var _mtx = pthread_mutex_t()
    
    public init() {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        pthread_mutex_init(&_mtx, &attr)
        pthread_mutexattr_destroy(&attr)
    }
    
    deinit {
        pthread_mutex_destroy(&_mtx)
    }
}

extension SDLock : Lockable {
    
    public func lock() {
        pthread_mutex_lock(&_mtx)
    }
    public func unlock() {
        pthread_mutex_unlock(&_mtx)
    }
    public func trylock() -> Bool {
        return pthread_mutex_trylock(&_mtx) == 0
    }
}

// MARK: Condition

private extension Date {
    
    var timespec : timespec {
        let _abs_time = self.timeIntervalSince1970
        let sec = __darwin_time_t(_abs_time)
        let nsec = Int((_abs_time - Double(sec)) * 1000000000.0)
        return Foundation.timespec(tv_sec: sec, tv_nsec: nsec)
    }
}

public class SDCondition {
    
    fileprivate var _cond = pthread_cond_t()
    
    public init() {
        pthread_cond_init(&_cond, nil)
    }
    
    deinit {
        pthread_cond_destroy(&_cond)
    }
}

extension SDCondition {
    
    public func signal() {
        pthread_cond_signal(&_cond)
    }
    public func broadcast() {
        pthread_cond_broadcast(&_cond)
    }
}

extension SDLock {
    
    public func wait(_ cond: SDCondition, for predicate: @autoclosure () -> Bool) {
        while !predicate() {
            pthread_cond_wait(&cond._cond, &_mtx)
        }
    }
    @discardableResult
    public func wait(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, until date: Date) -> Bool {
        var _timespec = date.timespec
        while !predicate() {
            if pthread_cond_timedwait(&cond._cond, &_mtx, &_timespec) != 0 {
                return predicate()
            }
        }
        return true
    }
}

extension SDLock {
    
    public func lock(_ cond: SDCondition, for predicate: @autoclosure () -> Bool) {
        self.lock()
        self.wait(cond, for: predicate)
    }
    @discardableResult
    public func lock(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, until date: Date) -> Bool {
        self.lock()
        if self.wait(cond, for: predicate, until: date) {
            return true
        }
        self.unlock()
        return false
    }
    @discardableResult
    public func trylock(_ cond: SDCondition, for predicate: @autoclosure () -> Bool) -> Bool {
        if self.trylock() {
            if self.wait(cond, for: predicate, until: Date.distantPast) {
                return true
            }
            self.unlock()
        }
        return false
    }
}

extension SDLock {
    
    @discardableResult
    public func synchronized<R>(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, block: () throws -> R) rethrows -> R {
        self.lock(cond, for: predicate)
        defer { self.unlock() }
        return try block()
    }
    @discardableResult
    public func synchronized<R>(_ cond: SDCondition, for predicate: @autoclosure () -> Bool, until date: Date, block: () throws -> R) rethrows -> R? {
        if self.lock(cond, for: predicate, until: date) {
            defer { self.unlock() }
            return try block()
        }
        return nil
    }
}

// MARK: Spin Lock

public class SDSpinLock {
    
    fileprivate var flag: Bool
    fileprivate var recursion_count: Int
    fileprivate var owner_thread: pthread_t?
    
    public init() {
        self.flag = false
        self.recursion_count = 0
        self.owner_thread = nil
    }
}

extension SDSpinLock : Lockable {
    
    public func unlock() {
        guard pthread_equal(owner_thread, pthread_self()) != 0 else {
            if flag {
                fatalError("unlock() is called by different thread.")
            } else {
                fatalError("unlock() is called before lock()")
            }
        }
        if recursion_count == 0 {
            owner_thread = nil
            guard flag.fetchStore(false) else {
                fatalError("unlock() is called before lock()")
            }
        } else {
            recursion_count -= 1
        }
    }
    public func trylock() -> Bool {
        let current_thread = pthread_self()
        if flag.compareSet(old: false, new: true) {
            owner_thread = current_thread
            recursion_count = 0
            return true
        } else if pthread_equal(owner_thread, current_thread) != 0 {
            recursion_count += 1
            return true
        }
        return false
    }
}

// MARK: Condition Lock

public class SDConditionLock : SDLock {
    
    fileprivate var cond = SDCondition()
}

extension SDConditionLock {
    
    public func signal() {
        super.synchronized {
            cond.signal()
        }
    }
    public func broadcast() {
        super.synchronized {
            cond.broadcast()
        }
    }
    public func wait(for predicate: @autoclosure () -> Bool) {
        self.wait(cond, for: predicate)
    }
    @discardableResult
    public func wait(for predicate: @autoclosure () -> Bool, until date: Date) -> Bool {
        return self.wait(cond, for: predicate, until: date)
    }
}

extension SDConditionLock {
    
    public func lock(for predicate: @autoclosure () -> Bool) {
        self.lock(cond, for: predicate)
    }
    @discardableResult
    public func lock(for predicate: @autoclosure () -> Bool, until date: Date) -> Bool {
        return self.lock(cond, for: predicate, until: date)
    }
    @discardableResult
    public func trylock(for predicate: @autoclosure () -> Bool) -> Bool {
        return self.trylock(cond, for: predicate)
    }
}

extension SDConditionLock {
    
    @discardableResult
    public func synchronized<R>(for predicate: @autoclosure () -> Bool, block: () throws -> R) rethrows -> R {
        return try self.synchronized(cond, for: predicate, block: block)
    }
    @discardableResult
    public func synchronized<R>(for predicate: @autoclosure () -> Bool, until date: Date, block: () throws -> R) rethrows -> R? {
        return try self.synchronized(cond, for: predicate, until: date, block: block)
    }
}

// MARK: SDAtomic

private let SDDefaultDispatchQueue = DispatchQueue(label: "com.SusanDoggie.Thread", attributes: .concurrent)

open class SDAtomic {
    
    fileprivate let queue: DispatchQueue
    fileprivate let block: (SDAtomic) -> Void
    fileprivate var flag: Int8
    
    public init(queue: DispatchQueue = SDDefaultDispatchQueue, block: @escaping (SDAtomic) -> Void) {
        self.queue = queue
        self.block = block
        self.flag = 0
    }
}

extension SDAtomic {
    
    public func signal() {
        if flag.fetchStore(2) == 0 {
            queue.async(execute: dispatchRunloop)
        }
    }
    
    fileprivate func dispatchRunloop() {
        while true {
            flag = 1
            autoreleasepool { self.block(self) }
            if flag.compareSet(old: 1, new: 0) {
                return
            }
        }
    }
}

// MARK: SDSingleton

open class SDSingleton<Instance> {
    
    fileprivate var _value: Instance?
    fileprivate let spinlck: SDSpinLock = SDSpinLock()
    fileprivate let block: () -> Instance
    
    /// Create a SDSingleton.
    public init(block: @escaping () -> Instance) {
        self.block = block
    }
}

extension SDSingleton {
    
    public func signal() {
        if !isValue {
            synchronized(self) {
                let result = self._value ?? self.block()
                self.spinlck.synchronized { self._value = result }
            }
        }
    }
    
    public var isValue : Bool {
        return spinlck.synchronized { self._value != nil }
    }
    
    public var value: Instance {
        self.signal()
        return self._value!
    }
}

// MARK: SDTask

public class SDTask<Result> : SDAtomic {
    
    fileprivate var _notify: [(Result) -> Void] = []
    
    fileprivate let spinlck = SDSpinLock()
    fileprivate let condition = SDConditionLock()
    
    fileprivate var _result: Result?
    
    fileprivate init(queue: DispatchQueue, suspend: ((Result) -> Bool)?, block: @escaping () -> Result) {
        super.init(queue: queue, block: SDTask.createBlock(suspend, block))
    }
    
    /// Create a SDTask and compute block.
    public init(queue: DispatchQueue = SDDefaultDispatchQueue, block: @escaping () -> Result) {
        super.init(queue: queue, block: SDTask.createBlock(nil, block))
        self.signal()
    }
}

private extension SDTask {
    
    @_transparent
    static func createBlock(_ suspend: ((Result) -> Bool)?, _ block: @escaping () -> Result) -> (SDAtomic) -> Void {
        return { atomic in
            let _self = atomic as! SDTask<Result>
            if !_self.completed {
                _self.condition.synchronized {
                    let result = _self._result ?? block()
                    _self.spinlck.synchronized { _self._result = result }
                    _self.condition.broadcast()
                }
            }
            if suspend?(_self._result!) != true {
                _self._notify.forEach { $0(_self._result!) }
            }
            _self._notify = []
        }
    }
    
    @_transparent
    func _apply<R>(_ queue: DispatchQueue, suspend: ((R) -> Bool)?, block: @escaping (Result) -> R) -> SDTask<R> {
        var storage: Result!
        let task = SDTask<R>(queue: queue, suspend: suspend) { block(storage) }
        return spinlck.synchronized {
            if _result == nil {
                _notify.append {
                    storage = $0
                    task.signal()
                }
            } else {
                storage = _result
                task.signal()
            }
            return task
        }
    }
}

extension SDTask {
    
    /// Return `true` iff task is completed.
    public var completed: Bool {
        return spinlck.synchronized { _result != nil }
    }
    
    /// Result of task.
    public var result: Result {
        if self.completed {
            return self._result!
        }
        return condition.synchronized(for: self.completed) { self._result! }
    }
}

extension SDTask {
    
    /// Run `block` after `self` is completed.
    @discardableResult
    public func then<R>(block: @escaping (Result) -> R) -> SDTask<R> {
        return self.then(queue: queue, block: block)
    }
    
    /// Run `block` after `self` is completed with specific queue.
    @discardableResult
    public func then<R>(queue: DispatchQueue, block: @escaping (Result) -> R) -> SDTask<R> {
        return self._apply(queue, suspend: nil, block: block)
    }
}

extension SDTask {
    
    /// Suspend if `result` satisfies `predicate`.
    @discardableResult
    public func suspend(where predicate: @escaping (Result) -> Bool) -> SDTask<Result> {
        return self.suspend(queue: queue, where: predicate)
    }
    
    /// Suspend if `result` satisfies `predicate` with specific queue.
    @discardableResult
    public func suspend(queue: DispatchQueue, where predicate: @escaping (Result) -> Bool) -> SDTask<Result> {
        return self._apply(queue, suspend: predicate) { $0 }
    }
}

/// Create a SDTask and compute block.
@discardableResult
public func async<Result>(queue: DispatchQueue = SDDefaultDispatchQueue, _ block: @escaping () -> Result) -> SDTask<Result> {
    return SDTask(queue: queue, block: block)
}
