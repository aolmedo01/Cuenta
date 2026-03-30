import Testing
@testable import Cuenta

struct CuentaTests {
    
    @Test func testAccountFormattedBalance() async throws {
        let account = Account(accountNumber: "12788373662", accountType: "AHO", balance: 1482000.00)
        #expect(account.formattedBalance == "$1,482,000.00")
    }
    
    @Test func testTransactionPositiveAmount() async throws {
        let transaction = Transaction(
            id: UUID(),
            name: "Test",
            description: "Test",
            amount: 100.00,
            balance: 500.00,
            date: Date(),
            type: .deposit
        )
        #expect(transaction.isPositive == true)
        #expect(transaction.formattedAmount == "+$100.00")
    }
    
    @Test func testTransactionNegativeAmount() async throws {
        let transaction = Transaction(
            id: UUID(),
            name: "Test",
            description: "Test",
            amount: -50.00,
            balance: 450.00,
            date: Date(),
            type: .withdrawal
        )
        #expect(transaction.isPositive == false)
        #expect(transaction.formattedAmount == "-$50.00")
    }
}
