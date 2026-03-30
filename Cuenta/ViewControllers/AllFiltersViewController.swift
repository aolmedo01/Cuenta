import UIKit

// MARK: - All Filters Delegate
@MainActor
protocol AllFiltersDelegate: AnyObject {
    func allFiltersDidApply(_ filters: AllFiltersViewController.FilterState)
    func allFiltersDidCancel()
    func allFiltersDidReset()
}

// MARK: - All Filters View Controller
final class AllFiltersViewController: UIViewController {
    
    // MARK: - Filter State
    struct FilterState {
        var dateFilterType: String = "Personalizado"
        var startDate: Date = Date()
        var endDate: Date = Date()
        var transactionType: String = "Ingresos"
        var amountFilterType: String = "Personalizado"
        var minAmount: Double?
        var maxAmount: Double?
    }
    
    // MARK: - Properties
    weak var delegate: AllFiltersDelegate?
    var filterState = FilterState()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
    
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.96, green: 0.965, blue: 0.973, alpha: 1)
        view.layer.cornerRadius = 38
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.18
        view.layer.shadowOffset = CGSize(width: 0, height: -15)
        view.layer.shadowRadius = 75
        return view
    }()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.47, green: 0.47, blue: 0.5, alpha: 0.16)
        button.layer.cornerRadius = 22
        button.setImage(UIImage(systemName: "xmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)), for: .normal)
        button.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Filtrar movimientos"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0, green: 0.533, blue: 1, alpha: 1)
        button.layer.cornerRadius = 22
        button.setImage(UIImage(systemName: "checkmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        return scroll
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        return stack
    }()
    
    // Date Filter Card
    private let dateFilterCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        view.layer.cornerRadius = 24
        return view
    }()
    
    // Type Filter Card
    private let typeFilterCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        view.layer.cornerRadius = 24
        return view
    }()
    
    // Amount Filter Card
    private let amountFilterCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        view.layer.cornerRadius = 24
        return view
    }()
    
    // Reset Button
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Restablecer", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(UIColor(red: 0.122, green: 0.161, blue: 0.239, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        return button
    }()
    
    // Date filter rows
    private var dateTypeButton: UIButton!
    private var startDateButton: UIButton!
    private var endDateButton: UIButton!
    
    // Type filter row
    private var typeButton: UIButton!
    
    // Amount filter rows
    private var amountTypeButton: UIButton!
    private var minAmountLabel: UILabel!
    private var maxAmountLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        updateUI()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(containerView)
        containerView.addSubview(grabberView)
        containerView.addSubview(closeButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(confirmButton)
        containerView.addSubview(scrollView)
        containerView.addSubview(resetButton)
        
        scrollView.addSubview(contentStackView)
        
        // Setup cards
        setupDateFilterCard()
        setupTypeFilterCard()
        setupAmountFilterCard()
        
        contentStackView.addArrangedSubview(dateFilterCard)
        contentStackView.addArrangedSubview(typeFilterCard)
        contentStackView.addArrangedSubview(amountFilterCard)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 618),
            
            grabberView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            grabberView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: 36),
            grabberView.heightAnchor.constraint(equalToConstant: 5),
            
            closeButton.topAnchor.constraint(equalTo: grabberView.bottomAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            confirmButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            confirmButton.widthAnchor.constraint(equalToConstant: 44),
            confirmButton.heightAnchor.constraint(equalToConstant: 44),
            
            scrollView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: resetButton.topAnchor, constant: -16),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            resetButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            resetButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: 48),
        ])
    }
    
    private func setupDateFilterCard() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        
        // Date type row
        let dateTypeRow = createRow(title: "Fecha", value: "Personalizado", showChevron: true)
        dateTypeButton = dateTypeRow.button
        dateTypeButton.addTarget(self, action: #selector(dateTypeTapped), for: .touchUpInside)
        
        // Start date row
        let startRow = createDateRow(title: "Empieza")
        startDateButton = startRow.button
        startDateButton.addTarget(self, action: #selector(startDateTapped), for: .touchUpInside)
        
        // End date row
        let endRow = createDateRow(title: "Termina")
        endDateButton = endRow.button
        endDateButton.addTarget(self, action: #selector(endDateTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(dateTypeRow.view)
        stackView.addArrangedSubview(createSeparator())
        stackView.addArrangedSubview(startRow.view)
        stackView.addArrangedSubview(createSeparator())
        stackView.addArrangedSubview(endRow.view)
        
        dateFilterCard.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: dateFilterCard.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: dateFilterCard.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: dateFilterCard.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: dateFilterCard.bottomAnchor),
        ])
    }
    
    private func setupTypeFilterCard() {
        let typeRow = createRow(title: "Tipo de movimiento", value: "Ingresos", showChevron: true)
        typeButton = typeRow.button
        typeButton.addTarget(self, action: #selector(typeTapped), for: .touchUpInside)
        
        typeFilterCard.addSubview(typeRow.view)
        
        NSLayoutConstraint.activate([
            typeRow.view.topAnchor.constraint(equalTo: typeFilterCard.topAnchor),
            typeRow.view.leadingAnchor.constraint(equalTo: typeFilterCard.leadingAnchor),
            typeRow.view.trailingAnchor.constraint(equalTo: typeFilterCard.trailingAnchor),
            typeRow.view.bottomAnchor.constraint(equalTo: typeFilterCard.bottomAnchor),
        ])
    }
    
    private func setupAmountFilterCard() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        
        // Amount type row
        let amountTypeRow = createRow(title: "Monto", value: "Personalizado", showChevron: true)
        amountTypeButton = amountTypeRow.button
        amountTypeButton.addTarget(self, action: #selector(amountTypeTapped), for: .touchUpInside)
        
        // Min amount row
        let minRow = createAmountRow(title: "$10.00")
        minAmountLabel = minRow.label
        
        // Max amount row
        let maxRow = createAmountRow(title: "$50.00")
        maxAmountLabel = maxRow.label
        
        stackView.addArrangedSubview(amountTypeRow.view)
        stackView.addArrangedSubview(createSeparator())
        stackView.addArrangedSubview(minRow.view)
        stackView.addArrangedSubview(createSeparator())
        stackView.addArrangedSubview(maxRow.view)
        
        amountFilterCard.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: amountFilterCard.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: amountFilterCard.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: amountFilterCard.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: amountFilterCard.bottomAnchor),
        ])
    }
    
    private func createRow(title: String, value: String, showChevron: Bool) -> (view: UIView, button: UIButton) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .black
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 17, weight: .regular)
        valueLabel.textColor = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.6)
        
        let chevron = UIImageView(image: UIImage(systemName: "chevron.up.chevron.down"))
        chevron.tintColor = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.6)
        chevron.contentMode = .scaleAspectFit
        
        let stackView = UIStackView(arrangedSubviews: showChevron ? [valueLabel, chevron] : [valueLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        
        button.addSubview(stackView)
        stackView.isUserInteractionEnabled = false
        
        container.addSubview(titleLabel)
        container.addSubview(button)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            stackView.topAnchor.constraint(equalTo: button.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: button.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
        ])
        
        return (container, button)
    }
    
    private func createDateRow(title: String) -> (view: UIView, button: UIButton) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .black
        
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12)
        button.layer.cornerRadius = 6
        button.setTitle("9 feb 2026", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 11, bottom: 6, right: 11)
        
        container.addSubview(titleLabel)
        container.addSubview(button)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 34),
        ])
        
        return (container, button)
    }
    
    private func createAmountRow(title: String) -> (view: UIView, label: UILabel) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .black
        
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 52),
            
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
        
        return (container, label)
    }
    
    private func createSeparator() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        container.addSubview(line)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 1),
            line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            line.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            line.heightAnchor.constraint(equalToConstant: 1),
        ])
        
        return container
    }
    
    private func updateUI() {
        // Update date buttons
        startDateButton?.setTitle(dateFormatter.string(from: filterState.startDate), for: .normal)
        endDateButton?.setTitle(dateFormatter.string(from: filterState.endDate), for: .normal)
        
        // Update amount labels
        if let min = filterState.minAmount {
            minAmountLabel?.text = currencyFormatter.string(from: NSNumber(value: min))
        }
        if let max = filterState.maxAmount {
            maxAmountLabel?.text = currencyFormatter.string(from: NSNumber(value: max))
        }
    }
    
    // MARK: - Actions
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            closeTapped()
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true) {
            self.delegate?.allFiltersDidCancel()
        }
    }
    
    @objc private func confirmTapped() {
        dismiss(animated: true) {
            self.delegate?.allFiltersDidApply(self.filterState)
        }
    }
    
    @objc private func resetTapped() {
        filterState = FilterState()
        updateUI()
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        delegate?.allFiltersDidReset()
    }
    
    @objc private func dateTypeTapped() {
        // TODO: Show date type picker
        print("Date type tapped")
    }
    
    @objc private func startDateTapped() {
        // TODO: Show date picker for start date
        print("Start date tapped")
    }
    
    @objc private func endDateTapped() {
        // TODO: Show date picker for end date
        print("End date tapped")
    }
    
    @objc private func typeTapped() {
        // TODO: Show type picker
        print("Type tapped")
    }
    
    @objc private func amountTypeTapped() {
        // TODO: Show amount type picker
        print("Amount type tapped")
    }
}

// MARK: - Presentation Helper
extension AllFiltersViewController {
    static func present(from viewController: UIViewController, delegate: AllFiltersDelegate? = nil, initialState: FilterState? = nil) {
        let picker = AllFiltersViewController()
        picker.delegate = delegate
        if let state = initialState {
            picker.filterState = state
        }
        picker.modalPresentationStyle = .overFullScreen
        picker.modalTransitionStyle = .coverVertical
        viewController.present(picker, animated: true)
    }
}
