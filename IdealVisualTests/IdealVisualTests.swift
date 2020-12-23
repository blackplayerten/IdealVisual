//
//  IdealVisualTests.swift
//  IdealVisualTests
//
//  Created by a.kurganova on 02/09/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import XCTest
@testable import IdealVisual

class IdealVisualTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

class ValidationTests: XCTestCase {
    let wrongEmailLabelText = "Неверный формат почты"
    
    func testOKEmail() {
        let field = InputFields(tag: 0)
        field.textField.text = "kurganova06.1998@gmail.com"
        let label = CheckMistakeLabel()
        let ok = checkValidEmail(field: field, mistake: label)
        XCTAssertTrue(ok)

        XCTAssertEqual(field.layer.borderColor, Colors.lightBlue.cgColor) // OK.

        XCTAssertTrue(label.isHidden)
        XCTAssertTrue(label.text?.isEmpty ?? true)
    }
    
    func testWrongDomain() {
        let field = InputFields(tag: 0)
        field.textField.text = "kurganova06.1998@gmail.c"
        let label = CheckMistakeLabel()
        let ok = checkValidEmail(field: field, mistake: label)
        XCTAssertFalse(ok)

        XCTAssertEqual(field.layer.borderColor, UIColor.red.cgColor) // Failed.

        XCTAssertFalse(label.isHidden)
        XCTAssertEqual(label.text, wrongEmailLabelText)
    }
    
    func testNotEmail() {
        let field = InputFields(tag: 0)
        field.textField.text = "kurganova06.1998"
        let label = CheckMistakeLabel()
        let ok = checkValidEmail(field: field, mistake: label)
        XCTAssertFalse(ok)

        XCTAssertEqual(field.layer.borderColor, UIColor.red.cgColor) // Failed.

        XCTAssertFalse(label.isHidden)
        XCTAssertEqual(label.text, wrongEmailLabelText)
    }
}
