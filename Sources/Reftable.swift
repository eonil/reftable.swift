




struct Refkey: Hashable {
    fileprivate var indexInReftable: Int
    var hashValue: Int { return indexInReftable }
}
func == (_ a: Refkey, _ b: Refkey) -> Bool {
    return a.indexInReftable == b.indexInReftable
}

/// A key-value table which provides strict O(1) referencing time, but you cannot use arbitrary key.
///
/// Read by ref-key: strictly O(1).
/// Write by ref-key: strictly O(1) in most cases. But you can only replace existing value.
/// Write can take up to O(n) due to internal array reallocation if it needs to increase capacity.
///
/// Take care about ref-key invalidation. If you use invalidated
/// ref-key, program will crash.
///
struct Reftable<Element>: Sequence {
    typealias Iterator = AnyIterator<(key: Refkey, value: Element)>

    private var slots = [Element?]()
    private var freeSlotIndexes = [Int]()

    private mutating func increaseSlotCapacityIfNeeded() {
        guard freeSlotIndexes.count == 0 else { return }
        func getNewSlotCap() -> Int {
            if slots.capacity <= 0 { return 1 }
            if slots.count < slots.capacity { return slots.capacity }
            if slots.count <= 0 { return 1 }
            return slots.count * 2
        }
        let newSlotCap = getNewSlotCap()
        while slots.count < newSlotCap {
            slots.append(nil)
            let newSlotIndex = slots.count - 1
            freeSlotIndexes.append(newSlotIndex)
        }
    }
    private mutating func decreaseSlotCapacityIfPossible() {
        if freeSlotIndexes.count == slots.count {
            slots = []
            freeSlotIndexes = []
        }
    }
    private func validateKey(refkey: Refkey) {
        precondition(slots.count > refkey.indexInReftable, "The key is invalid.")
    }

    /// O(1).
    var isEmpty: Bool {
        return count == 0
    }
    /// O(1).
    var count: Int {
        return slots.count - freeSlotIndexes.count
    }
    /// O(1).
    func contains(refkey: Refkey) -> Bool {
        validateKey(refkey: refkey)
        return slots[refkey.indexInReftable] != nil
    }
    /// O(1).
    /// You can replace element for a key, but no add or remove.
    subscript(refkey: Refkey) -> Element {
        get {
            validateKey(refkey: refkey)
            return slots[refkey.indexInReftable]!
        }
        set {
            validateKey(refkey: refkey)
            precondition(slots[refkey.indexInReftable] != nil)
            slots[refkey.indexInReftable] = newValue
        }
    }

    mutating func insert(newElement: Element) -> Refkey {
        increaseSlotCapacityIfNeeded()
        precondition(freeSlotIndexes.count > 0)
        if let freeSlotIndex = freeSlotIndexes.popLast() {
            assert(slots[freeSlotIndex] == nil)
            slots[freeSlotIndex] = newElement
            return Refkey(indexInReftable: freeSlotIndex)
        }
        fatalError()
    }
    mutating func remove(for refkey: Refkey) {
        precondition(slots[refkey.indexInReftable] != nil)
        slots[refkey.indexInReftable] = nil
        assert(freeSlotIndexes.contains(refkey.indexInReftable) == false)
        freeSlotIndexes.append(refkey.indexInReftable)
    }
    mutating func removeAll() {
        slots.removeAll()
        freeSlotIndexes.removeAll()
    }

    /// Creates an interator which copies source reftable.
    /// Returned iterator will iterate all values in the reftable
    /// in no order.
    func makeIterator() -> Iterator {
        let copy = slots
        let entireRange = copy.startIndex..<copy.endIndex
        var indexIterator = entireRange.makeIterator()
        return AnyIterator {
            while true {
                guard let nextIndex = indexIterator.next() else { return nil } // End of iteration.
                if let nextValue = copy[nextIndex] {
                    let k = Refkey(indexInReftable: nextIndex)
                    let v = nextValue
                    return (k, v)
                }
            }
        }
    }
}

extension Reftable {
    var keys: LazyMapSequence<Iterator,Refkey> {
        return makeIterator().lazy.map({ $0.key })
    }
    var values: LazyMapSequence<Iterator,Element> {
        return makeIterator().lazy.map({ $0.value })
    }
}






























