import UIKit

final class TransactionCell: UIView {
    
    // MARK: - UI Components
    private let iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .textNavy
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .transactionTitle
        label.textColor = .textDark
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .transactionSubtitle
        label.textColor = .textSecondary
        return label
    }()
    
    private let statusBadge: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.906, green: 0.937, blue: 1.0, alpha: 1) // #E7EFFF
        view.layer.cornerRadius = 10
        view.isHidden = true
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = UIColor(red: 0.047, green: 0.306, blue: 0.796, alpha: 1) // #0C4ECB
        label.textAlignment = .center
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .transactionAmount
        label.textAlignment = .right
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .transactionBalance
        label.textColor = .textSecondary
        label.textAlignment = .right
        return label
    }()
    
    private let labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()
    
    private let amountStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .trailing
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
        
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(subtitleLabel)
        labelsStack.addArrangedSubview(statusBadge)
        statusBadge.addSubview(statusLabel)
        
        amountStack.addArrangedSubview(amountLabel)
        amountStack.addArrangedSubview(balanceLabel)
        
        addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        addSubview(labelsStack)
        addSubview(amountStack)
        
        NSLayoutConstraint.activate([
            // Status Badge
            statusBadge.heightAnchor.constraint(equalToConstant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -8),
            statusLabel.centerYAnchor.constraint(equalTo: statusBadge.centerYAnchor),
            
            // Icon Container
            iconContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            
            // Icon Image
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Labels Stack
            labelsStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            labelsStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: amountStack.leadingAnchor, constant: -12),
            
            // Amount Stack
            amountStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            amountStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Height
            heightAnchor.constraint(equalToConstant: 72)
        ])
    }
    
    // MARK: - Configuration
    func configure(with transaction: Transaction) {
        titleLabel.text = transaction.name
        subtitleLabel.text = transaction.description
        amountLabel.text = transaction.formattedAmount
        balanceLabel.text = transaction.formattedBalance
        
        // Amount color
        amountLabel.textColor = transaction.isPositive ? .amountPositive : .amountNegative
        
        // Status badge
        switch transaction.status {
        case .toWithdraw:
            statusBadge.isHidden = false
            statusLabel.text = "Por retirar"
            subtitleLabel.isHidden = true
        case .pending:
            statusBadge.isHidden = false
            statusLabel.text = "Pendiente"
            subtitleLabel.isHidden = true
        case .completed:
            statusBadge.isHidden = true
            subtitleLabel.isHidden = false
        }
        
        // Icon based on type
        let iconName: String
        switch transaction.type {
        case .transfer:
            iconName = "arrow.left.arrow.right"
        case .withdrawal:
            iconName = "banknote"
        case .deposit:
            iconName = "arrow.down"
        case .payment:
            iconName = "drop"
        case .goal:
            iconName = "arrow.turn.up.left"
        case .cardPurchase:
            iconName = "creditcard"
        case .salary:
            iconName = "arrow.down"
        case .electricity:
            iconName = "lightbulb"
        }
        
        iconImageView.image = UIImage(systemName: iconName)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
    }
}
