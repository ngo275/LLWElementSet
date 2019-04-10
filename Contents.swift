import UIKit
import XCTest

struct Element<ValueType: Hashable>: Hashable {
    let value: ValueType
    var timestamps: [Date]
    
    init(value: ValueType) {
        self.value = value
        self.timestamps = [Date()]
    }
}

class LLWElementSet<ValueType: Hashable> {
    private var addSet: Set<Element<ValueType>> = []
    private var removeSet: Set<Element<ValueType>> = []
    
    var members: Set<ValueType> {
        let set: Set<Element<ValueType>> = addSet.filter { element -> Bool in
            let removedElements: Set<Element<ValueType>> = removeSet.filter { $0.value == element.value }
            if removedElements.count == 0 { return true }
            if removedElements.count > 0 {
                if removedElements.count != 1 { assertionFailure() }
                return element.timestamps.last! > removedElements.first!.timestamps.last!
            }
            return false
        }
        return Set(set.map { $0.value })
    }
    
    private func elementInsert(_ value: ValueType, to set: inout Set<Element<ValueType>>) {
        let sameValueElements = set.filter { $0.value == value }
        if sameValueElements.count > 0 {
            var newElement = sameValueElements.first!
            newElement.timestamps.append(Date())
            set = Set(set.map { element in
                return element.value == value ? newElement : element
            })
        } else {
            set.insert(Element(value: value))
        }
    }
    
    func add(_ value: ValueType) {
        elementInsert(value, to: &addSet)
    }
    
    func remove(_ value: ValueType) {
        elementInsert(value, to: &removeSet)
    }
}


/// Test value type is String
class LLWElementSetStringTests: XCTestCase {
    func testLLWElementSet_String_when_onlyOneElement() {
        let subject = LLWElementSet<String>()

        // member is empty at first
        XCTAssertEqual(subject.members, Set([]))

        // add `Hello`
        subject.add("Hello")
        
        // member is only `Hello`
        XCTAssertEqual(subject.members, Set(["Hello"]))

        // add `Hello` (the same value) again and again
        subject.add("Hello")
        subject.add("Hello")
        subject.add("Hello")

        // member is still only `Hello`
        XCTAssertEqual(subject.members, Set(["Hello"]))
        
        // remove `Hello`
        subject.remove("Hello")
        
        // member is empty
        XCTAssertEqual(subject.members, Set([]))
        
        // add `Hello` again
        subject.add("Hello")

        // member is only `Hello` again
        XCTAssertEqual(subject.members, Set(["Hello"]))
    }
    
    func testLLWElementSet_String_when_SomeElements() {
        let subject = LLWElementSet<String>()
        
        // member is empty
        XCTAssertEqual(subject.members, Set([]))
        
        // add `Hello`
        subject.add("Hello")
        
        // member is `Hello`
        XCTAssertEqual(subject.members, Set(["Hello"]))

        // add `Hi` (a different value)
        subject.add("Hi")
        
        // member is `Hello` & `Hi`
        XCTAssertEqual(subject.members, Set(["Hello", "Hi"]))
        
        // add the same values again
        subject.add("Hello")
        subject.add("Hi")
        
        // member doesn't change
        XCTAssertEqual(subject.members, Set(["Hello", "Hi"]))
        
        // remove an existing value `Hello`
        subject.remove("Hello")
        
        // member is only `Hi`
        XCTAssertEqual(subject.members, Set(["Hi"]))
        
        // remove an existing value again `Hi`
        subject.remove("Hi")
        
        // member is empty
        XCTAssertEqual(subject.members, Set([]))
    }
    
    func testLLWElementSet_String_when_removeElementFromEmptySets() {
        let subject = LLWElementSet<String>()
        
        // member is empty
        XCTAssertEqual(subject.members, Set([]))
        
        // remove non-existing value
        subject.remove("Hello")
        
        // member is empty
        XCTAssertEqual(subject.members, Set([]))
        
        // add the same value after removing it
        subject.add("Hello")
        
        // member is only that `Hello`
        XCTAssertEqual(subject.members, Set(["Hello"]))
    }
}

/// Test value type is Int
class LLWElementSetIntTests: XCTestCase {
    func testLLWElementSet_Int_when_onlyOneElement() {
        let subject = LLWElementSet<Int>()
        
        // member is empty at first
        XCTAssertEqual(subject.members, Set([]))
        
        // add 0
        subject.add(0)
        
        // member is only 0
        XCTAssertEqual(subject.members, Set([0]))
        
        // add the same value again and again
        subject.add(0)
        subject.add(0)
        subject.add(0)
        
        // member is still only 0
        XCTAssertEqual(subject.members, Set([0]))
        
        // remove the existing value 0
        subject.remove(0)
        
        // member is empty
        XCTAssertEqual(subject.members, Set([]))
        
        // add the same value again 0
        subject.add(0)
        
        // member is 0
        XCTAssertEqual(subject.members, Set([0]))
    }
    
    func testLLWElementSet_Int_when_SomeElements() {
        let subject = LLWElementSet<Int>()
        
        // member is empty at first
        XCTAssertEqual(subject.members, Set([]))
        
        // add 0
        subject.add(0)
        
        // member is 0
        XCTAssertEqual(subject.members, Set([0]))
        
        // add a different value 1
        subject.add(1)
        
        // member is 0 & 1
        XCTAssertEqual(subject.members, Set([0, 1]))
        
        // add existing values
        subject.add(0)
        subject.add(1)
        
        // member doesn't change
        XCTAssertEqual(subject.members, Set([0, 1]))
        
        // remove an existing value 0
        subject.remove(0)
        
        // member is 1
        XCTAssertEqual(subject.members, Set([1]))
        
        // remove an exiting value 1
        subject.remove(1)
        
        // member is empty
        XCTAssertEqual(subject.members, Set([]))
    }
    
    func testLLWElementSet_Int_when_removeElementFromEmptySets() {
        let subject = LLWElementSet<Int>()
        
        // member is empty at first
        XCTAssertEqual(subject.members, [])
        
        // remove non-existing value 0
        subject.remove(0)
        
        // member is empty
        XCTAssertEqual(subject.members, [])
        
        // add the same value after removing it
        subject.add(0)
        
        // member is 0
        XCTAssertEqual(subject.members, [0])
    }
}


LLWElementSetStringTests.defaultTestSuite.run()
LLWElementSetIntTests.defaultTestSuite.run()
