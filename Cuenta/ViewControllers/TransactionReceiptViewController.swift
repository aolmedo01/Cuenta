import UIKit

final class TransactionReceiptViewController: UIViewController {
    
    // MARK: - Properties
    private var transaction: Transaction?
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let handleBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1)
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 17, weight: .semibold)
        label.textColor = UIColor(red: 0.122, green: 0.161, blue: 0.239, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private let checkmarkContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.961, green: 0.965, blue: 0.973, alpha: 1)
        view.layer.cornerRadius = 40
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1).cgColor
        return view
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 28, weight: .medium))
        imageView.tintColor = UIColor(red: 0.541, green: 0.576, blue: 0.659, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 34, weight: .bold)
        label.textColor = UIColor(red: 0.122, green: 0.161, blue: 0.239, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 15, weight: .regular)
        label.textColor = UIColor(red: 0.424, green: 0.455, blue: 0.553, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 13, weight: .regular)
        label.textColor = UIColor(red: 0.541, green: 0.576, blue: 0.659, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private let journeyCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let journeyTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "RECORRIDO DEL DINERO"
        label.font = .manrope(size: 11, weight: .semibold)
        label.textColor = UIColor(red: 0.541, green: 0.576, blue: 0.659, alpha: 1)
        return label
    }()
    
    // Origin
    private let originCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(red: 0.047, green: 0.306, blue: 0.796, alpha: 1).cgColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let originNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 15, weight: .semibold)
        label.textColor = UIColor(red: 0.122, green: 0.161, blue: 0.239, alpha: 1)
        return label
    }()
    
    private let originDetailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 13, weight: .regular)
        label.textColor = UIColor(red: 0.541, green: 0.576, blue: 0.659, alpha: 1)
        return label
    }()
    
    // Connection line
    private let connectionLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1)
        return view
    }()
    
    // Destination
    private let destinationCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.047, green: 0.306, blue: 0.796, alpha: 1)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let destinationCheckmark: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 10, weight: .bold))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let destinationNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 15, weight: .semibold)
        label.textColor = UIColor(red: 0.122, green: 0.161, blue: 0.239, alpha: 1)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    // Transaction code
    private let codeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 12, weight: .regular)
        label.textColor = UIColor(red: 0.541, green: 0.576, blue: 0.659, alpha: 1)
        return label
    }()
    
    private let codeValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .manrope(size: 12, weight: .regular)
        label.textColor = UIColor(red: 0.424, green: 0.455, blue: 0.553, alpha: 1)
        return label
    }()
    
    // Header back button
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = UIColor(red: 0.424, green: 0.455, blue: 0.553, alpha: 1)
        button.backgroundColor = .clear
        return button
    }()
    
    // Background decorative circles
    private let outerCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 0.5).cgColor
        return view
    }()
    
    private let middleCircle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 0.5).cgColor
        return view
    }()
    
    // MARK: - Init
    init(transaction: Transaction) {
        self.transaction = transaction
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.969, green: 0.973, blue: 0.980, alpha: 1) // Light gray background
        view.clipsToBounds = true

        view.addSubview(closeButton)
        view.addSubview(headerLabel)
        view.addSubview(amountLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(dateLabel)
        view.addSubview(journeyCard)
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        journeyCard.addSubview(journeyTitleLabel)
        journeyCard.addSubview(originCircle)
        journeyCard.addSubview(originNameLabel)
        journeyCard.addSubview(originDetailLabel)
        journeyCard.addSubview(connectionLine)
        journeyCard.addSubview(destinationCircle)
        destinationCircle.addSubview(destinationCheckmark)
        journeyCard.addSubview(destinationNameLabel)
        journeyCard.addSubview(codeLabel)
        journeyCard.addSubview(codeValueLabel)
        
        NSLayoutConstraint.activate([   
            // Header - centered
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Back button in header
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),
            
            // Amount - below header, centered
            amountLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 32),
            amountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 8),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Date
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Journey card
            journeyCard.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 32),
            journeyCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            journeyCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Journey title
            journeyTitleLabel.topAnchor.constraint(equalTo: journeyCard.topAnchor, constant: 16),
            journeyTitleLabel.leadingAnchor.constraint(equalTo: journeyCard.leadingAnchor, constant: 16),
            
            // Origin circle
            originCircle.topAnchor.constraint(equalTo: journeyTitleLabel.bottomAnchor, constant: 16),
            originCircle.leadingAnchor.constraint(equalTo: journeyCard.leadingAnchor, constant: 16),
            originCircle.widthAnchor.constraint(equalToConstant: 20),
            originCircle.heightAnchor.constraint(equalToConstant: 20),
            
            // Origin name
            originNameLabel.topAnchor.constraint(equalTo: originCircle.topAnchor, constant: -2),
            originNameLabel.leadingAnchor.constraint(equalTo: originCircle.trailingAnchor, constant: 12),
            originNameLabel.trailingAnchor.constraint(equalTo: journeyCard.trailingAnchor, constant: -16),
            
            // Origin detail
            originDetailLabel.topAnchor.constraint(equalTo: originNameLabel.bottomAnchor, constant: 2),
            originDetailLabel.leadingAnchor.constraint(equalTo: originNameLabel.leadingAnchor),
            originDetailLabel.trailingAnchor.constraint(equalTo: journeyCard.trailingAnchor, constant: -16),
            
            // Connection line
            connectionLine.topAnchor.constraint(equalTo: originCircle.bottomAnchor),
            connectionLine.centerXAnchor.constraint(equalTo: originCircle.centerXAnchor),
            connectionLine.widthAnchor.constraint(equalToConstant: 2),
            connectionLine.heightAnchor.constraint(equalToConstant: 24),
            
            // Destination circle
            destinationCircle.topAnchor.constraint(equalTo: connectionLine.bottomAnchor),
            destinationCircle.centerXAnchor.constraint(equalTo: originCircle.centerXAnchor),
            destinationCircle.widthAnchor.constraint(equalToConstant: 20),
            destinationCircle.heightAnchor.constraint(equalToConstant: 20),
            
            destinationCheckmark.centerXAnchor.constraint(equalTo: destinationCircle.centerXAnchor),
            destinationCheckmark.centerYAnchor.constraint(equalTo: destinationCircle.centerYAnchor),
            
            // Destination name
            destinationNameLabel.centerYAnchor.constraint(equalTo: destinationCircle.centerYAnchor),
            destinationNameLabel.leadingAnchor.constraint(equalTo: destinationCircle.trailingAnchor, constant: 12),
            destinationNameLabel.trailingAnchor.constraint(equalTo: journeyCard.trailingAnchor, constant: -16),
        ])
        
        // Add a separator line above code
        let separatorLine = UIView()
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = UIColor(red: 0.933, green: 0.941, blue: 0.957, alpha: 1)
        journeyCard.addSubview(separatorLine)
        
        NSLayoutConstraint.activate([
            separatorLine.topAnchor.constraint(equalTo: destinationCircle.bottomAnchor, constant: 16),
            separatorLine.leadingAnchor.constraint(equalTo: journeyCard.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: journeyCard.trailingAnchor, constant: -16),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            // Code label - below separator
            codeLabel.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 16),
            codeLabel.leadingAnchor.constraint(equalTo: journeyCard.leadingAnchor, constant: 16),
            codeLabel.bottomAnchor.constraint(equalTo: journeyCard.bottomAnchor, constant: -16),
            
            // Code value
            codeValueLabel.centerYAnchor.constraint(equalTo: codeLabel.centerYAnchor),
            codeValueLabel.leadingAnchor.constraint(equalTo: codeLabel.trailingAnchor, constant: 8),
        ])
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    private func configureData() {
        guard let transaction = transaction else { return }
        
        // Header based on type
        switch transaction.type {
        case .electricity:
            headerLabel.text = "Pago de servicio"
            descriptionLabel.text = "Luz local"
            destinationNameLabel.text = "CNEL - Empresa Eléctrica Pública Estrat..."
        case .payment:
            headerLabel.text = "Pago de servicio"
            descriptionLabel.text = transaction.description
            destinationNameLabel.text = transaction.name
        case .transfer:
            headerLabel.text = "Transferencia"
            descriptionLabel.text = transaction.description
            destinationNameLabel.text = transaction.name
        default:
            headerLabel.text = "Comprobante"
            descriptionLabel.text = transaction.description
            destinationNameLabel.text = transaction.name
        }
        
        // Amount (absolute value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        amountLabel.text = formatter.string(from: NSNumber(value: abs(transaction.amount))) ?? "$0.00"
        
        // Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy, h:mma"
        dateFormatter.locale = Locale(identifier: "es_ES")
        dateLabel.text = dateFormatter.string(from: transaction.date).lowercased()
        
        // Origin (current user)
        originNameLabel.text = "Daniel Rodriguez"
        originDetailLabel.text = "Banco Guayaquil  AHO 12772365"
        
        // Transaction code
        codeLabel.text = "Código de transacción"
        let transactionCode = String(format: "%015d", Int.random(in: 100000000...999999999))
        codeValueLabel.text = transactionCode
    }
}
