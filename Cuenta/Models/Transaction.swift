import Foundation

// MARK: - Transaction Type
enum TransactionType: String {
    case transfer = "transfer"
    case withdrawal = "withdrawal"
    case deposit = "deposit"
    case payment = "payment"
    case goal = "goal"
    case cardPurchase = "cardPurchase"
    case salary = "salary"
}

// MARK: - Transaction Model
struct Transaction {
    let id: UUID
    let name: String
    let description: String
    let amount: Double
    let balance: Double
    let date: Date
    let type: TransactionType
    
    var isPositive: Bool {
        return amount >= 0
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        let prefix = amount >= 0 ? "+" : ""
        return prefix + (formatter.string(from: NSNumber(value: abs(amount))) ?? "$0.00")
    }
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: balance)) ?? "$0.00"
    }
}

// MARK: - Transaction Section
struct TransactionSection {
    let title: String
    let transactions: [Transaction]
}

// MARK: - History Item
struct HistoryItem {
    let title: String
    let type: HistoryType
    
    enum HistoryType {
        case month
        case year
    }
}

// MARK: - Account Model
struct Account {
    let accountNumber: String
    let accountType: String
    var balance: Double
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return "$" + (formatter.string(from: NSNumber(value: balance)) ?? "0.00")
    }
    
    var formattedAccountNumber: String {
        return "\(accountType) \(accountNumber)"
    }
}
