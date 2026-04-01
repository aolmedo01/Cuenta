import UIKit

final class HistorySectionView: UIView {
    
    // MARK: - UI Components
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 15, weight: .bold)
        label.textColor = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.6) // rgba(60, 60, 67, 0.6)
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        addSubview(headerLabel)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            // Header with 16px left padding
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // Stack
            stackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(title: String, items: [String]) {
        headerLabel.text = title
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, item) in items.enumerated() {
            let row = HistoryRowView(title: item)
            row.showSeparator = index < items.count - 1
            stackView.addArrangedSubview(row)
        }
    }
}
