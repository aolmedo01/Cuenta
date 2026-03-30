import UIKit

final class AccountSettingsViewController: UIViewController {
    
    // MARK: - Data
    private enum ThemeOption: String, CaseIterable {
        case magenta = "Magenta"
        case magno = "Magno"
    }
    
    private var selectedTheme: ThemeOption = .magenta
    private var accountName: String = "AHO"
    
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
        label.text = "Configurar cuenta"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .textPrimary
        label.textAlignment = .center
        return label
    }()
    
    // Theme preview views
    private var magentaCheckmark: UIImageView?
    private var magnoCheckmark: UIImageView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.961, green: 0.965, blue: 0.973, alpha: 1) // #F5F6F8
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        setupToolbar()
        setupAccessSection()
        setupAppearanceSection()
        setupAccountNameSection()
        
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
    
    private func setupAccessSection() {
        // Header
        let headerView = createSectionHeader(title: "Dar acceso a mi cuenta")
        mainStackView.addArrangedSubview(headerView)
        
        // Container
        let containerStack = UIStackView()
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        containerStack.isLayoutMarginsRelativeArrangement = true
        
        // Invite row
        let inviteRow = createInviteRow()
        containerStack.addArrangedSubview(inviteRow)
        
        mainStackView.addArrangedSubview(containerStack)
        
        // Description
        let descriptionView = createDescriptionText(
            text: "Invita a alguien de confianza para ayudarte con tu cuenta. Actuará como ",
            linkText: "Firma autorizada",
            action: #selector(firmAutorizadaTapped)
        )
        mainStackView.addArrangedSubview(descriptionView)
    }
    
    private func setupAppearanceSection() {
        // Header
        let headerView = createSectionHeader(title: "Aspecto")
        mainStackView.addArrangedSubview(headerView)
        
        // Theme options container
        let themesContainer = UIView()
        themesContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let themesStack = UIStackView()
        themesStack.translatesAutoresizingMaskIntoConstraints = false
        themesStack.axis = .horizontal
        themesStack.spacing = 16
        themesStack.distribution = .fillEqually
        
        // Magenta theme
        let magentaOption = createThemeOption(
            theme: .magenta,
            isSelected: selectedTheme == .magenta
        )
        themesStack.addArrangedSubview(magentaOption)
        
        // Magno theme
        let magnoOption = createThemeOption(
            theme: .magno,
            isSelected: selectedTheme == .magno
        )
        themesStack.addArrangedSubview(magnoOption)
        
        themesContainer.addSubview(themesStack)
        
        NSLayoutConstraint.activate([
            themesStack.topAnchor.constraint(equalTo: themesContainer.topAnchor),
            themesStack.leadingAnchor.constraint(equalTo: themesContainer.leadingAnchor, constant: 16),
            themesStack.trailingAnchor.constraint(equalTo: themesContainer.trailingAnchor, constant: -16),
            themesStack.bottomAnchor.constraint(equalTo: themesContainer.bottomAnchor),
            themesStack.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        mainStackView.addArrangedSubview(themesContainer)
    }
    
    private func setupAccountNameSection() {
        // Header
        let headerView = createSectionHeader(title: "Nombre de la cuenta")
        mainStackView.addArrangedSubview(headerView)
        
        // Container
        let containerStack = UIStackView()
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.spacing = 8
        containerStack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        containerStack.isLayoutMarginsRelativeArrangement = true
        
        // Name row
        let nameRow = createAccountNameRow()
        containerStack.addArrangedSubview(nameRow)
        
        mainStackView.addArrangedSubview(containerStack)
        
        // Description
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "En pagos y transferencias, se mostrará el nombre de tu cuenta en lugar del número, para que puedas identificarla fácilmente."
        descriptionLabel.font = .manrope(size: 12, weight: .regular)
        descriptionLabel.textColor = UIColor(red: 0.318, green: 0.353, blue: 0.451, alpha: 1)
        descriptionLabel.numberOfLines = 0
        
        let descContainer = UIView()
        descContainer.translatesAutoresizingMaskIntoConstraints = false
        descContainer.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: descContainer.topAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: descContainer.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: descContainer.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: descContainer.bottomAnchor, constant: -8)
        ])
        
        mainStackView.addArrangedSubview(descContainer)
    }
    
    // MARK: - Factory Methods
    private func createSectionHeader(title: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .manrope(size: 15, weight: .semibold)
        titleLabel.textColor = .accentBlue
        
        container.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createInviteRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        container.layer.cornerRadius = 24
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Invitar a una persona"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .black
        
        let chevron = UIImageView()
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.image = UIImage(systemName: "chevron.right")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
        chevron.tintColor = UIColor(red: 0.129, green: 0.157, blue: 0.227, alpha: 1)
        
        container.addSubview(titleLabel)
        container.addSubview(chevron)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(inviteRowTapped))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 16),
            chevron.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        return container
    }
    
    private func createDescriptionText(text: String, linkText: String, action: Selector) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        let fullText = text + linkText + "."
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Base style
        attributedString.addAttributes([
            .font: UIFont.manrope(size: 12, weight: .regular),
            .foregroundColor: UIColor(red: 0.318, green: 0.353, blue: 0.451, alpha: 1)
        ], range: NSRange(location: 0, length: fullText.count))
        
        // Link style
        if let linkRange = fullText.range(of: linkText) {
            let nsRange = NSRange(linkRange, in: fullText)
            attributedString.addAttributes([
                .foregroundColor: UIColor.accentBlue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: nsRange)
        }
        
        label.attributedText = attributedString
        
        // Add tap gesture for link
        let tap = UITapGestureRecognizer(target: self, action: action)
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createThemeOption(theme: ThemeOption, isSelected: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.tag = theme == .magenta ? 0 : 1
        
        // Phone preview container with image
        let previewContainer = UIView()
        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        previewContainer.layer.cornerRadius = 12
        previewContainer.clipsToBounds = true
        previewContainer.layer.borderWidth = isSelected ? 2 : 1
        previewContainer.layer.borderColor = isSelected ? 
            UIColor.accentBlue.cgColor : 
            UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
        
        // Theme preview image
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: theme == .magenta ? "ThemeMagenta" : "ThemeMagno")
        
        previewContainer.addSubview(imageView)
        
        // Theme name label
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = theme.rawValue
        nameLabel.font = .manrope(size: 15, weight: .regular)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .center
        
        // Checkmark
        let checkmarkContainer = UIView()
        checkmarkContainer.translatesAutoresizingMaskIntoConstraints = false
        checkmarkContainer.layer.cornerRadius = 11
        checkmarkContainer.layer.borderWidth = isSelected ? 0 : 1.5
        checkmarkContainer.layer.borderColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1).cgColor
        checkmarkContainer.backgroundColor = isSelected ? .accentBlue : .clear
        
        let checkmark = UIImageView()
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        checkmark.image = UIImage(systemName: "checkmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 10, weight: .bold))
        checkmark.tintColor = .white
        checkmark.isHidden = !isSelected
        
        checkmarkContainer.addSubview(checkmark)
        
        // Store reference
        if theme == .magenta {
            magentaCheckmark = checkmark
        } else {
            magnoCheckmark = checkmark
        }
        
        container.addSubview(previewContainer)
        container.addSubview(nameLabel)
        container.addSubview(checkmarkContainer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(themeOptionTapped(_:)))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            previewContainer.topAnchor.constraint(equalTo: container.topAnchor),
            previewContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            previewContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            previewContainer.heightAnchor.constraint(equalToConstant: 150),
            
            imageView.topAnchor.constraint(equalTo: previewContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: 12),
            nameLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            checkmarkContainer.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            checkmarkContainer.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            checkmarkContainer.widthAnchor.constraint(equalToConstant: 22),
            checkmarkContainer.heightAnchor.constraint(equalToConstant: 22),
            checkmarkContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            checkmark.centerXAnchor.constraint(equalTo: checkmarkContainer.centerXAnchor),
            checkmark.centerYAnchor.constraint(equalTo: checkmarkContainer.centerYAnchor)
        ])
        
        return container
    }
    
    private func createAccountNameRow() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        container.layer.cornerRadius = 24
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = accountName
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        nameLabel.textColor = .black
        
        container.addSubview(nameLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(accountNameRowTapped))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    // MARK: - Actions
    @objc private func backTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func inviteRowTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        print("Invite person tapped")
    }
    
    @objc private func firmAutorizadaTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        print("Firma autorizada link tapped")
    }
    
    @objc private func themeOptionTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let theme: ThemeOption = view.tag == 0 ? .magenta : .magno
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Update selection
        selectedTheme = theme
        
        // Update UI
        UIView.animate(withDuration: 0.2) {
            if theme == .magenta {
                self.magentaCheckmark?.isHidden = false
                self.magentaCheckmark?.superview?.backgroundColor = .accentBlue
                self.magentaCheckmark?.superview?.layer.borderWidth = 0
                
                self.magnoCheckmark?.isHidden = true
                self.magnoCheckmark?.superview?.backgroundColor = .clear
                self.magnoCheckmark?.superview?.layer.borderWidth = 1.5
            } else {
                self.magnoCheckmark?.isHidden = false
                self.magnoCheckmark?.superview?.backgroundColor = .accentBlue
                self.magnoCheckmark?.superview?.layer.borderWidth = 0
                
                self.magentaCheckmark?.isHidden = true
                self.magentaCheckmark?.superview?.backgroundColor = .clear
                self.magentaCheckmark?.superview?.layer.borderWidth = 1.5
            }
        }
        
        print("Theme selected: \(theme.rawValue)")
    }
    
    @objc private func accountNameRowTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        print("Account name row tapped")
    }
}
