//
//  conversationalUITests.swift
//  conversationalUITests
//
//  Created by Gregory on 8/18/25.
//

import XCTest

final class conversationalUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testURLInputFieldExists() throws {
        let app = XCUIApplication()
        app.launch()
        
        let urlTextField = app.textFields["Enter URL"]
        XCTAssertTrue(urlTextField.exists)
    }
    
    @MainActor
    func testGoButtonExists() throws {
        let app = XCUIApplication()
        app.launch()
        
        let goButton = app.buttons["Go"]
        XCTAssertTrue(goButton.exists)
    }
    
    @MainActor
    func testURLInputAndNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        let urlTextField = app.textFields["Enter URL"]
        XCTAssertTrue(urlTextField.exists)
        
        // Clear and enter a new URL
        urlTextField.click()
        urlTextField.typeKey("a", modifierFlags: .command) // Select all
        urlTextField.typeText("www.github.com")
        
        // Press Enter to navigate
        urlTextField.typeKey(.enter, modifierFlags: [])
        
        // Verify the text field contains the expected URL
        XCTAssertTrue(urlTextField.value as? String == "www.github.com")
    }
    
    @MainActor
    func testGoButtonNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        let urlTextField = app.textFields["Enter URL"]
        let goButton = app.buttons["Go"]
        
        // Enter URL and click Go button
        urlTextField.click()
        urlTextField.typeKey("a", modifierFlags: .command)
        urlTextField.typeText("www.apple.com")
        goButton.click()
        
        // Verify URL was entered
        XCTAssertTrue(urlTextField.value as? String == "www.apple.com")
    }
    
    @MainActor
    func testURLPredictionInput() throws {
        let app = XCUIApplication()
        app.launch()
        
        let urlTextField = app.textFields["Enter URL"]
        XCTAssertTrue(urlTextField.exists)
        
        // Type a partial URL that should trigger predictions
        urlTextField.click()
        urlTextField.typeKey("a", modifierFlags: .command)
        urlTextField.typeText("github")
        
        // Wait a moment for potential predictions (this test may need Ollama running)
        sleep(1)
        
        // Verify the input was entered
        XCTAssertTrue(urlTextField.value as? String == "github")
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
