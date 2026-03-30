import UIKit

extension UIFont {
    
    // MARK: - Manrope Font (Primary)
    static func manrope(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let fontName: String
        switch weight {
        case .bold:
            fontName = "Manrope-Bold"
        case .semibold:
            fontName = "Manrope-SemiBold"
        case .medium:
            fontName = "Manrope-Medium"
        case .light:
            fontName = "Manrope-Light"
        default:
            fontName = "Manrope-Regular"
        }
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
    
    // MARK: - App Typography
    
    /// Balance amount - 32pt Regular
    static var balanceTitle: UIFont {
        return manrope(size: 32, weight: .regular)
    }
    
    /// Account number subtitle - 13pt Semibold uppercase
    static var accountSubtitle: UIFont {
        return manrope(size: 13, weight: .semibold)
    }
    
    /// Button label - 17pt Semibold
    static var buttonLabel: UIFont {
        return manrope(size: 17, weight: .semibold)
    }
    
    /// Transaction name - 16pt Semibold
    static var transactionTitle: UIFont {
        return manrope(size: 16, weight: .semibold)
    }
    
    /// Transaction description - 14pt Regular
    static var transactionSubtitle: UIFont {
        return manrope(size: 14, weight: .regular)
    }
    
    /// Transaction amount - 16pt Semibold
    static var transactionAmount: UIFont {
        return manrope(size: 16, weight: .semibold)
    }
    
    /// Transaction balance - 14pt Regular
    static var transactionBalance: UIFont {
        return manrope(size: 14, weight: .regular)
    }
    
    /// Section header - 14pt Regular
    static var sectionHeader: UIFont {
        return manrope(size: 14, weight: .regular)
    }
    
    /// Search placeholder - 16pt Regular
    static var searchPlaceholder: UIFont {
        return manrope(size: 16, weight: .regular)
    }
    
    /// History row - 16pt Regular
    static var historyRow: UIFont {
        return manrope(size: 16, weight: .regular)
    }
}
