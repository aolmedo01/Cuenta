import UIKit

final class DocumentsViewController: UIViewController {
    
    // MARK: - Data
    private struct StatementMonth {
        let name: String
        let year: Int
        var isSelected: Bool
    }
    
    private var statementMonths: [StatementMonth] = []
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .fill
        return stack
    }()
    
    // Toolbar
    private let toolbarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: CircleIconButton = {
        let button = CircleIconButton(systemName: "chevron.left")
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Documentos"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup Data
    private func setupData() {
        // Generate months for 2026 and 2025
        let months2026 = ["Marzo", "Febrero", "Enero"]
        let months2025 = ["Diciembre", "Noviembre", "Octubre", "Septiembre", "Agosto", "Julio", "Junio", "Mayo", "Abril", "Marzo", "Febrero", "Enero"]
        
        for month in months2026 {
            statementMonths.append(StatementMonth(name: month, year: 2026, isSelected: false))
        }
        for month in months2025 {
            statementMonths.append(StatementMonth(name: month, year: 2025, isSelected: false))
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.961, green: 0.965, blue: 0.973, alpha: 1) // #F5F6F8
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        setupToolbar()
        setupCertificatesSection()
        setupStatementsSection()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func setupToolbar() {
        mainStackView.addArrangedSubview(toolbarView)
        toolbarView.addSubview(backButton)
        toolbarView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            toolbarView.heightAnchor.constraint(equalToConstant: 54),
            
            backButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: toolbarView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor)
        ])
    }
    
    private func setupCertificatesSection() {
        // Header
        let headerView = createSectionHeader(title: "Certificados bancarios", subtitle: "Solicita certificados con validez legal.")
        mainStackView.addArrangedSubview(headerView)
        
        // Container for certificate rows
        let containerStack = UIStackView()
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        containerStack.isLayoutMarginsRelativeArrangement = true
        
        // Cuenta activa row
        let cuentaActivaRow = createCertificateRow(
            icon: "doc.text",
            title: "Cuenta activa",
            subtitle: "Confirma que tu cuenta está vigente"
        )
        containerStack.addArrangedSubview(cuentaActivaRow)
        
        // Productos activos row
        let productosActivosRow = createCertificateRow(
            icon: "creditcard",
            title: "Productos activos",
            subtitle: "Tus productos bancarios"
        )
        containerStack.addArrangedSubview(productosActivosRow)
        
        mainStackView.addArrangedSubview(containerStack)
    }
    
    private func setupStatementsSection() {
        // Header
        let headerView = createSectionHeader(title: "Estados de cuenta", subtitle: "Descarga los que necesites.")
        mainStackView.addArrangedSubview(headerView)
        
        // Container for month rows
        let containerStack = UIStackView()
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        containerStack.isLayoutMarginsRelativeArrangement = true
        
        var currentYear = 0
        
        for (index, month) in statementMonths.enumerated() {
            // Add year header if changed
            if month.year != currentYear {
                currentYear = month.year
                let yearHeader = createYearHeader(year: currentYear)
                containerStack.addArrangedSubview(yearHeader)
            }
            
            // Add month row
            let monthRow = createMonthRow(month: month, index: index)
            containerStack.addArrangedSubview(monthRow)
        }
        
        mainStackView.addArrangedSubview(containerStack)
    }
    
    // MARK: - Factory Methods
    private func createSectionHeader(title: String, subtitle: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .black
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = .manrope(size: 12, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.318, green: 0.353, blue: 0.451, alpha: 1) // #515A73
        
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 63),
            
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        ])
        
        return container
    }
    
    private func createCertificateRow(icon: String, title: String, subtitle: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1) // #FCFCFD
        container.layer.cornerRadius = 24
        
        // Icon container
        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = UIColor(red: 0.961, green: 0.965, blue: 0.973, alpha: 1) // #F5F6F8
        iconContainer.layer.cornerRadius = 18
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
        iconImageView.tintColor = UIColor(red: 0.047, green: 0.067, blue: 0.114, alpha: 1) // #0C111D
        iconImageView.contentMode = .scaleAspectFit
        
        // Labels
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .manrope(size: 17, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.122, green: 0.161, blue: 0.239, alpha: 1) // #1F293D
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = .manrope(size: 15, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.424, green: 0.455, blue: 0.553, alpha: 1) // #6C748D
        
        // Chevron
        let chevronImageView = UIImageView()
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold))
        chevronImageView.tintColor = UIColor(red: 0.129, green: 0.157, blue: 0.227, alpha: 1) // #21283A
        chevronImageView.contentMode = .scaleAspectFit
        
        container.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(chevronImageView)
        
        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(certificateRowTapped(_:)))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 64),
            
            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            
            chevronImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        return container
    }
    
    private func createYearHeader(year: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let yearLabel = UILabel()
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.text = "\(year)"
        yearLabel.font = .manrope(size: 15, weight: .bold)
        yearLabel.textColor = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.6) // rgba(60, 60, 67, 0.6)
        
        container.addSubview(yearLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 44),
            
            yearLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            yearLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createMonthRow(month: StatementMonth, index: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1) // #FCFCFD
        container.layer.cornerRadius = 24
        container.tag = index
        
        // Checkbox
        let checkbox = UIView()
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.layer.borderWidth = 1.5
        checkbox.layer.borderColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1).cgColor // #C7C7CC
        checkbox.layer.cornerRadius = 11
        checkbox.tag = 100 // Tag for checkbox identification
        
        // Checkmark (hidden by default)
        let checkmark = UIImageView()
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        checkmark.image = UIImage(systemName: "checkmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .bold))
        checkmark.tintColor = .white
        checkmark.isHidden = true
        checkmark.tag = 101
        
        // Month label
        let monthLabel = UILabel()
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.text = month.name
        monthLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        monthLabel.textColor = .black
        
        container.addSubview(checkbox)
        checkbox.addSubview(checkmark)
        container.addSubview(monthLabel)
        
        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(monthRowTapped(_:)))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            
            checkbox.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            checkbox.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            checkbox.widthAnchor.constraint(equalToConstant: 22),
            checkbox.heightAnchor.constraint(equalToConstant: 22),
            
            checkmark.centerXAnchor.constraint(equalTo: checkbox.centerXAnchor),
            checkmark.centerYAnchor.constraint(equalTo: checkbox.centerYAnchor),
            
            monthLabel.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 16),
            monthLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            monthLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        
        return container
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func certificateRowTapped(_ gesture: UITapGestureRecognizer) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // TODO: Navigate to certificate detail
        print("Certificate row tapped")
    }
    
    @objc private func monthRowTapped(_ gesture: UITapGestureRecognizer) {
        guard let container = gesture.view else { return }
        let index = container.tag
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Toggle selection
        statementMonths[index].isSelected.toggle()
        let isSelected = statementMonths[index].isSelected
        
        // Update UI
        if let checkbox = container.viewWithTag(100),
           let checkmark = container.viewWithTag(101) as? UIImageView {
            
            UIView.animate(withDuration: 0.2) {
                if isSelected {
                    checkbox.backgroundColor = .accentBlue
                    checkbox.layer.borderColor = UIColor.accentBlue.cgColor
                    checkmark.isHidden = false
                } else {
                    checkbox.backgroundColor = .clear
                    checkbox.layer.borderColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1).cgColor
                    checkmark.isHidden = true
                }
            }
        }
    }
}
