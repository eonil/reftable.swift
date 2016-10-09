import XCTest
import GameplayKit
@testable import Reftable

class ReftableTests: XCTestCase {
    @available(OSX 10.11, *)
    func testAll() {
        do {
            var t1 = Reftable<Int>()
            let k1 = t1.insert(newElement: 111)
            let k2 = t1.insert(newElement: 222)
            let k3 = t1.insert(newElement: 333)
            XCTAssert(t1.count == 3)
            XCTAssert(t1[k1] == 111)
            XCTAssert(t1[k2] == 222)
            XCTAssert(t1[k3] == 333)
            t1.remove(for: k3)
            XCTAssert(t1.contains(refkey: k3) == false)
            t1.remove(for: k1)
            XCTAssert(t1.contains(refkey: k1) == false)
            t1.remove(for: k2)
            XCTAssert(t1.contains(refkey: k2) == false)
            XCTAssert(t1.count == 0)
        }
        do {
            let r = GKARC4RandomSource(seed: Data([0,0,0,0]))
            var t1 = Reftable<Float>()
            var d1 = [Refkey: Float]()
            for _ in 0..<1024 {
                let v1 = r.nextUniform()
                let k1 = t1.insert(newElement: v1)
                d1[k1] = v1
            }
            XCTAssert(d1.count == t1.count)
            for k1 in d1.keys {
                XCTAssert(d1[k1] == t1[k1])
            }
            XCTAssert(Set(d1.keys) == Set(t1.keys))
            XCTAssert(Set(d1.values) == Set(t1.values))
            do {
                var ks1 = Array(d1.keys)
                let i = r.nextInt(upperBound: ks1.count)
                let k1 = ks1.remove(at: i)
                d1[k1] = nil
                t1.remove(for: k1)
                XCTAssert(d1.count == t1.count)
                for k1 in d1.keys {
                    XCTAssert(d1[k1] == t1[k1])
                }
            }
        }
    }

    @available(OSX 10.11, *)
    static var allTests : [(String, (ReftableTests) -> () throws -> Void)] {
        return [
            ("testAll", testAll),
        ]
    }
}



























