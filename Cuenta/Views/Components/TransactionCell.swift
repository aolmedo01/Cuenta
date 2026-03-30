import UIKit

final class TransactionCell: UIView {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1) // #FCFCFD
        view.layer.cornerRadius = 24
        return view
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.961, green: 0.965, blue: 0.973, alpha: 1) // #F5F6F8
        view.layer.cornerRadius = 18
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(red: 0.047, green: 0.067, blue: 0.114, alpha: 1) // #0C111D
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor(red: 0.122, green: 0.161, blue: 0.239, alpha: 1) // #1F293D
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.424, green: 0.455, blue: 0.553, alpha: 1) // #6C748D
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
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.541, green: 0.576, blue: 0.659, alpha: 1) // #8A93A8
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
        
        addSubview(containerView)
        
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(subtitleLabel)
        labelsStack.addArrangedSubview(statusBadge)
        statusBadge.addSubview(statusLabel)
        
        amountStack.addArrangedSubview(amountLabel)
        amountStack.addArrangedSubview(balanceLabel)
        
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        containerView.addSubview(labelsStack)
        containerView.addSubview(amountStack)
        
        NSLayoutConstraint.activate([
            // Container View (with bottom spacing for separation)
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            // Status Badge
            statusBadge.heightAnchor.constraint(equalToConstant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -8),
            statusLabel.centerYAnchor.constraint(equalTo: statusBadge.centerYAnchor),
            
            // Icon Container
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),
            
            // Icon Image
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            // Labels Stack
            labelsStack.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            labelsStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: amountStack.leadingAnchor, constant: -24),
            
            // Amount Stack
            amountStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            amountStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Height (64px container + 8px spacing)
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
