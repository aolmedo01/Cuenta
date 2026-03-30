import UIKit

final class SegmentedControlView: UIView {
    
    // MARK: - Properties
    enum Segment: Int {
        case manual = 0
        case automatico = 1
    }
    
    var selectedSegment: Segment = .manual {
        didSet {
            updateSelection()
        }
    }
    
    var onSegmentChanged: ((Segment) -> Void)?
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12)
        view.layer.cornerRadius = 13 // height/2 for pill shape
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        return stack
    }()
    
    private lazy var manualButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Manual", for: .normal)
        button.titleLabel?.font = .manrope(size: 12, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 11 // height/2 for pill shape
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.04
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 1
        button.tag = Segment.manual.rawValue
        button.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var automaticoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Automático", for: .normal)
        button.titleLabel?.font = .manrope(size: 12, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 11
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 1
        button.tag = Segment.automatico.rawValue
        button.addTarget(self, action: #selector(segmentTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(manualButton)
        stackView.addArrangedSubview(automaticoButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 160),
            containerView.heightAnchor.constraint(equalToConstant: 26),
            
            // Self width constraint
            widthAnchor.constraint(equalToConstant: 160),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2),
            
            manualButton.heightAnchor.constraint(equalToConstant: 22),
            manualButton.widthAnchor.constraint(equalToConstant: 74),
            
            automaticoButton.heightAnchor.constraint(equalToConstant: 22),
            automaticoButton.widthAnchor.constraint(equalToConstant: 78),
            
            // Self height constraint
            heightAnchor.constraint(equalToConstant: 26)
        ])
    }
    
    // MARK: - Actions
    @objc private func segmentTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        guard let segment = Segment(rawValue: sender.tag) else { return }
        
        if segment != selectedSegment {
            selectedSegment = segment
            onSegmentChanged?(segment)
        }
    }
    
    // MARK: - Update
    private func updateSelection() {
        UIView.animate(withDuration: 0.2) {
            if self.selectedSegment == .manual {
                self.manualButton.backgroundColor = .white
                self.manualButton.layer.shadowOpacity = 0.04
                self.automaticoButton.backgroundColor = .clear
                self.automaticoButton.layer.shadowOpacity = 0
            } else {
                self.manualButton.backgroundColor = .clear
                self.manualButton.layer.shadowOpacity = 0
                self.automaticoButton.backgroundColor = .white
                self.automaticoButton.layer.shadowOpacity = 0.04
            }
        }
    }
}
