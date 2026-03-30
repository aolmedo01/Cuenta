import UIKit

// MARK: - Date Range Picker Delegate
@MainActor
protocol DateRangePickerDelegate: AnyObject {
    func dateRangePicker(_ picker: DateRangePickerViewController, didSelectStartDate startDate: Date, endDate: Date)
    func dateRangePickerDidCancel(_ picker: DateRangePickerViewController)
}

// MARK: - Date Range Picker View Controller
final class DateRangePickerViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: DateRangePickerDelegate?
    
    private var startDate: Date = Date()
    private var endDate: Date = Date()
    private var isSelectingStartDate: Bool = true
    private var currentDisplayedMonth: Date = Date()
    private var isConfirmationMode: Bool = false
    
    private var containerHeightConstraint: NSLayoutConstraint?
    private var endDateRowTopToCalendarConstraint: NSLayoutConstraint?
    private var endDateRowTopToStartDateConstraint: NSLayoutConstraint?
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
    
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.96, green: 0.965, blue: 0.973, alpha: 1) // #F5F6F8
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
        view.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1) // #CCCCCC
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    private let toolbarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        label.text = "Filtrar fecha"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0, green: 0.533, blue: 1, alpha: 1) // #0088FF
        button.layer.cornerRadius = 22
        button.setImage(UIImage(systemName: "checkmark")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }()
    
    private let filterCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.988, green: 0.988, blue: 0.992, alpha: 1) // #FCFCFD
        view.layer.cornerRadius = 24
        return view
    }()
    
    // Start date row
    private let startDateRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Empieza"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private lazy var startDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12)
        button.layer.cornerRadius = 6
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 11, bottom: 6, right: 11)
        button.addTarget(self, action: #selector(startDateTapped), for: .touchUpInside)
        return button
    }()
    
    // Calendar container
    private let calendarContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let separatorLine1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        return view
    }()
    
    // Calendar header
    private let calendarHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var monthYearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private lazy var previousMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)), for: .normal)
        button.tintColor = UIColor(red: 0, green: 0.533, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(previousMonthTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)), for: .normal)
        button.tintColor = UIColor(red: 0, green: 0.533, blue: 1, alpha: 1)
        button.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        return button
    }()
    
    // Weekday headers
    private let weekdayStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    // Calendar grid
    private let calendarGridView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var dayButtons: [[UIButton]] = []
    
    // End date row
    private let endDateRowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let confirmationSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        view.isHidden = true
        return view
    }()
    
    private let separatorLine2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12)
        return view
    }()
    
    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Termina"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private lazy var endDateButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12)
        button.layer.cornerRadius = 6
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 11, bottom: 6, right: 11)
        button.addTarget(self, action: #selector(endDateTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupWeekdayHeaders()
        setupCalendarGrid()
        updateDateButtons()
        updateCalendar()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        // Tap background to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(containerView)
        containerView.addSubview(grabberView)
        containerView.addSubview(toolbarView)
        toolbarView.addSubview(closeButton)
        toolbarView.addSubview(titleLabel)
        toolbarView.addSubview(confirmButton)
        
        containerView.addSubview(filterCardView)
        filterCardView.addSubview(startDateRowView)
        startDateRowView.addSubview(startDateLabel)
        startDateRowView.addSubview(startDateButton)
        
        filterCardView.addSubview(calendarContainerView)
        calendarContainerView.addSubview(separatorLine1)
        calendarContainerView.addSubview(calendarHeaderView)
        calendarHeaderView.addSubview(monthYearButton)
        calendarHeaderView.addSubview(previousMonthButton)
        calendarHeaderView.addSubview(nextMonthButton)
        calendarContainerView.addSubview(weekdayStackView)
        calendarContainerView.addSubview(calendarGridView)
        calendarContainerView.addSubview(separatorLine2)
        
        filterCardView.addSubview(endDateRowView)
        filterCardView.addSubview(confirmationSeparator)
        endDateRowView.addSubview(endDateLabel)
        endDateRowView.addSubview(endDateButton)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            grabberView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            grabberView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: 36),
            grabberView.heightAnchor.constraint(equalToConstant: 5),
            
            toolbarView.topAnchor.constraint(equalTo: grabberView.bottomAnchor, constant: 5),
            toolbarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            toolbarView.heightAnchor.constraint(equalToConstant: 44),
            
            closeButton.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: toolbarView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            
            confirmButton.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor, constant: -16),
            confirmButton.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 44),
            confirmButton.heightAnchor.constraint(equalToConstant: 44),
            
            filterCardView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor, constant: 32),
            filterCardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            filterCardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            startDateRowView.topAnchor.constraint(equalTo: filterCardView.topAnchor),
            startDateRowView.leadingAnchor.constraint(equalTo: filterCardView.leadingAnchor),
            startDateRowView.trailingAnchor.constraint(equalTo: filterCardView.trailingAnchor),
            startDateRowView.heightAnchor.constraint(equalToConstant: 52),
            
            startDateLabel.leadingAnchor.constraint(equalTo: startDateRowView.leadingAnchor, constant: 16),
            startDateLabel.centerYAnchor.constraint(equalTo: startDateRowView.centerYAnchor),
            
            startDateButton.trailingAnchor.constraint(equalTo: startDateRowView.trailingAnchor, constant: -16),
            startDateButton.centerYAnchor.constraint(equalTo: startDateRowView.centerYAnchor),
            startDateButton.heightAnchor.constraint(equalToConstant: 34),
            
            calendarContainerView.topAnchor.constraint(equalTo: startDateRowView.bottomAnchor),
            calendarContainerView.leadingAnchor.constraint(equalTo: filterCardView.leadingAnchor),
            calendarContainerView.trailingAnchor.constraint(equalTo: filterCardView.trailingAnchor),
            calendarContainerView.heightAnchor.constraint(equalToConstant: 336),
            
            separatorLine1.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            separatorLine1.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            separatorLine1.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
            separatorLine1.heightAnchor.constraint(equalToConstant: 1),
            
            calendarHeaderView.topAnchor.constraint(equalTo: separatorLine1.bottomAnchor, constant: 6),
            calendarHeaderView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calendarHeaderView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
            calendarHeaderView.heightAnchor.constraint(equalToConstant: 40),
            
            monthYearButton.leadingAnchor.constraint(equalTo: calendarHeaderView.leadingAnchor, constant: 16),
            monthYearButton.centerYAnchor.constraint(equalTo: calendarHeaderView.centerYAnchor),
            
            nextMonthButton.trailingAnchor.constraint(equalTo: calendarHeaderView.trailingAnchor, constant: -16),
            nextMonthButton.centerYAnchor.constraint(equalTo: calendarHeaderView.centerYAnchor),
            nextMonthButton.widthAnchor.constraint(equalToConstant: 24),
            nextMonthButton.heightAnchor.constraint(equalToConstant: 24),
            
            previousMonthButton.trailingAnchor.constraint(equalTo: nextMonthButton.leadingAnchor, constant: -28),
            previousMonthButton.centerYAnchor.constraint(equalTo: calendarHeaderView.centerYAnchor),
            previousMonthButton.widthAnchor.constraint(equalToConstant: 24),
            previousMonthButton.heightAnchor.constraint(equalToConstant: 24),
            
            weekdayStackView.topAnchor.constraint(equalTo: calendarHeaderView.bottomAnchor),
            weekdayStackView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor, constant: 16),
            weekdayStackView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor, constant: -16),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 20),
            
            calendarGridView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 3),
            calendarGridView.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor, constant: 16),
            calendarGridView.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor, constant: -16),
            calendarGridView.heightAnchor.constraint(equalToConstant: 220),
            
            separatorLine2.topAnchor.constraint(equalTo: calendarGridView.bottomAnchor, constant: 8),
            separatorLine2.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor, constant: 16),
            separatorLine2.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor, constant: -16),
            separatorLine2.heightAnchor.constraint(equalToConstant: 0.5),
            
            // Confirmation separator (hidden initially)
            confirmationSeparator.topAnchor.constraint(equalTo: startDateRowView.bottomAnchor),
            confirmationSeparator.leadingAnchor.constraint(equalTo: filterCardView.leadingAnchor, constant: 16),
            confirmationSeparator.trailingAnchor.constraint(equalTo: filterCardView.trailingAnchor, constant: -16),
            confirmationSeparator.heightAnchor.constraint(equalToConstant: 1),
            
            endDateRowView.leadingAnchor.constraint(equalTo: filterCardView.leadingAnchor),
            endDateRowView.trailingAnchor.constraint(equalTo: filterCardView.trailingAnchor),
            endDateRowView.heightAnchor.constraint(equalToConstant: 52),
            endDateRowView.bottomAnchor.constraint(equalTo: filterCardView.bottomAnchor),
            
            endDateLabel.leadingAnchor.constraint(equalTo: endDateRowView.leadingAnchor, constant: 16),
            endDateLabel.centerYAnchor.constraint(equalTo: endDateRowView.centerYAnchor),
            
            endDateButton.trailingAnchor.constraint(equalTo: endDateRowView.trailingAnchor, constant: -16),
            endDateButton.centerYAnchor.constraint(equalTo: endDateRowView.centerYAnchor),
            endDateButton.heightAnchor.constraint(equalToConstant: 34),
        ])
        
        // Setup variable constraints
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 642)
        containerHeightConstraint?.isActive = true
        
        // EndDateRow constraint that changes based on mode
        endDateRowTopToCalendarConstraint = endDateRowView.topAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)
        endDateRowTopToCalendarConstraint?.isActive = true
        
        endDateRowTopToStartDateConstraint = endDateRowView.topAnchor.constraint(equalTo: confirmationSeparator.bottomAnchor)
        endDateRowTopToStartDateConstraint?.isActive = false
    }
    
    private func setupWeekdayHeaders() {
        let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        
        for day in weekdays {
            let label = UILabel()
            label.text = day
            label.font = .systemFont(ofSize: 13, weight: .semibold)
            label.textColor = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.3)
            label.textAlignment = .center
            weekdayStackView.addArrangedSubview(label)
        }
    }
    
    private func setupCalendarGrid() {
        let rowHeight: CGFloat = 44
        let columns = 7
        let rows = 5
        
        for row in 0..<rows {
            var rowButtons: [UIButton] = []
            for col in 0..<columns {
                let button = UIButton(type: .system)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
                button.setTitleColor(.black, for: .normal)
                button.addTarget(self, action: #selector(dayTapped(_:)), for: .touchUpInside)
                button.tag = row * columns + col
                
                calendarGridView.addSubview(button)
                
                let buttonWidth = (UIScreen.main.bounds.width - 64) / CGFloat(columns)
                
                NSLayoutConstraint.activate([
                    button.topAnchor.constraint(equalTo: calendarGridView.topAnchor, constant: CGFloat(row) * rowHeight),
                    button.leadingAnchor.constraint(equalTo: calendarGridView.leadingAnchor, constant: CGFloat(col) * buttonWidth),
                    button.widthAnchor.constraint(equalToConstant: buttonWidth),
                    button.heightAnchor.constraint(equalToConstant: rowHeight)
                ])
                
                rowButtons.append(button)
            }
            dayButtons.append(rowButtons)
        }
    }
    
    private func updateDateButtons() {
        startDateButton.setTitle(dateFormatter.string(from: startDate), for: .normal)
        endDateButton.setTitle(dateFormatter.string(from: endDate), for: .normal)
        
        // Highlight active button
        startDateButton.backgroundColor = isSelectingStartDate 
            ? UIColor(red: 0, green: 0.533, blue: 1, alpha: 0.12) 
            : UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12)
        
        endDateButton.backgroundColor = !isSelectingStartDate 
            ? UIColor(red: 0, green: 0.533, blue: 1, alpha: 0.12) 
            : UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12)
    }
    
    private func updateCalendar() {
        // Update month/year label
        monthYearButton.setTitle(monthYearFormatter.string(from: currentDisplayedMonth).capitalized + " >", for: .normal)
        
        // Get first day of month
        let components = calendar.dateComponents([.year, .month], from: currentDisplayedMonth)
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: currentDisplayedMonth) else { return }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let numberOfDays = range.count
        
        // Reset all buttons
        for row in dayButtons {
            for button in row {
                button.setTitle("", for: .normal)
                button.backgroundColor = .clear
                button.isEnabled = false
                button.setTitleColor(.black, for: .normal)
            }
        }
        
        // Fill in days
        var day = 1
        var buttonIndex = firstWeekday - 1 // Sunday = 1
        
        while day <= numberOfDays {
            let row = buttonIndex / 7
            let col = buttonIndex % 7
            
            if row < dayButtons.count {
                let button = dayButtons[row][col]
                button.setTitle("\(day)", for: .normal)
                button.isEnabled = true
                
                // Check if this is the selected date
                if let dateForButton = getDate(forDay: day) {
                    let isStartDate = calendar.isDate(dateForButton, inSameDayAs: startDate)
                    let isEndDate = calendar.isDate(dateForButton, inSameDayAs: endDate)
                    
                    if isStartDate || isEndDate {
                        button.backgroundColor = UIColor(red: 0, green: 0.533, blue: 1, alpha: 0.12)
                        button.setTitleColor(UIColor(red: 0, green: 0.533, blue: 1, alpha: 1), for: .normal)
                        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
                        button.layer.cornerRadius = 22
                    } else {
                        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
                    }
                }
            }
            
            day += 1
            buttonIndex += 1
        }
    }
    
    private func getDate(forDay day: Int) -> Date? {
        var components = calendar.dateComponents([.year, .month], from: currentDisplayedMonth)
        components.day = day
        return calendar.date(from: components)
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
            self.delegate?.dateRangePickerDidCancel(self)
        }
    }
    
    @objc private func confirmTapped() {
        // Ensure end date is not before start date
        if endDate < startDate {
            let temp = startDate
            startDate = endDate
            endDate = temp
        }
        
        if isConfirmationMode {
            // Already in confirmation mode, dismiss and notify delegate
            dismiss(animated: true) {
                self.delegate?.dateRangePicker(self, didSelectStartDate: self.startDate, endDate: self.endDate)
            }
        } else {
            // Switch to confirmation mode (hide calendar)
            switchToConfirmationMode()
        }
    }
    
    private func switchToConfirmationMode() {
        isConfirmationMode = true
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Switch constraints before animation
        endDateRowTopToCalendarConstraint?.isActive = false
        endDateRowTopToStartDateConstraint?.isActive = true
        
        // Show confirmation separator
        confirmationSeparator.isHidden = false
        
        // Animate to collapsed state
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            // Hide calendar
            self.calendarContainerView.alpha = 0
            self.calendarContainerView.isHidden = true
            
            // Update container height for smaller modal (toolbar 70 + padding 32 + card 104 + bottom padding)
            self.containerHeightConstraint?.constant = 250
            
            self.view.layoutIfNeeded()
        }
        
        // Update date buttons to non-interactive state
        startDateButton.isUserInteractionEnabled = false
        endDateButton.isUserInteractionEnabled = false
        startDateButton.backgroundColor = UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12)
        endDateButton.backgroundColor = UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12)
    }
    
    @objc private func startDateTapped() {
        isSelectingStartDate = true
        currentDisplayedMonth = startDate
        updateDateButtons()
        updateCalendar()
    }
    
    @objc private func endDateTapped() {
        isSelectingStartDate = false
        currentDisplayedMonth = endDate
        updateDateButtons()
        updateCalendar()
    }
    
    @objc private func previousMonthTapped() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentDisplayedMonth) {
            currentDisplayedMonth = newMonth
            updateCalendar()
        }
    }
    
    @objc private func nextMonthTapped() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentDisplayedMonth) {
            currentDisplayedMonth = newMonth
            updateCalendar()
        }
    }
    
    @objc private func dayTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal),
              let day = Int(title),
              let selectedDate = getDate(forDay: day) else { return }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if isSelectingStartDate {
            startDate = selectedDate
            // Auto-switch to end date selection
            isSelectingStartDate = false
        } else {
            endDate = selectedDate
            // Ensure end date is not before start date
            if endDate < startDate {
                let temp = startDate
                startDate = endDate
                endDate = temp
            }
        }
        
        updateDateButtons()
        updateCalendar()
    }
}

// MARK: - Presentation Helper
extension DateRangePickerViewController {
    static func present(from viewController: UIViewController, delegate: DateRangePickerDelegate? = nil) {
        let picker = DateRangePickerViewController()
        picker.delegate = delegate
        picker.modalPresentationStyle = .overFullScreen
        picker.modalTransitionStyle = .coverVertical
        viewController.present(picker, animated: true)
    }
}
