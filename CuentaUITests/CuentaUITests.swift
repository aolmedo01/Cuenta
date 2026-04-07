import XCTest

final class CuentaUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Verifica que el saldo sea visible
        XCTAssertTrue(app.staticTexts["$2,899.00"].exists)
    }
    
    @MainActor
    func testTransferButtonExists() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Verifica que el botón de transferir existe
        let transferButton = app.buttons["Transferir"]
        XCTAssertTrue(transferButton.exists)
    }
}
