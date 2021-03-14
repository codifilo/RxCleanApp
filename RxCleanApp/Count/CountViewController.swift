import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CountViewController<ViewModel: CountViewModel>: UIViewController, RxView, UpdatableLayout {
    struct Layout {
        let fontSize: CGFloat
        let verticalSpacing: CGFloat
        let horizontalMargin: Int
    }
    
    var viewModel: ViewModel?
    
    let disposeBag = DisposeBag()
    
    private let label = UILabel()
    private let button = UIButton(type: .system)
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupBindings()
        viewModel?.viewEvent.onNext(.viewDidLoad)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayout()
    }
    
    var layout: Layout {
        switch traitCollection.horizontalSizeClass {
        case .compact:
            return Layout(
                fontSize: 18,
                verticalSpacing: 18,
                horizontalMargin: 24
            )
        default:
            return Layout(
                fontSize: 22,
                verticalSpacing: 26,
                horizontalMargin: 32
            )
        }
    }
    
    private func setupViews() {
        setupUI()
        addViews()
        updateLayout()
    }
    
    func updateLayout() {
        let currentLayout = self.layout
        updateUI(with: currentLayout)
        setupAutolayout(with: currentLayout)
    }
    
    private func setupUI() {
        label.textAlignment = .center
        button.setTitle("Increment", for: .normal)
        stackView.axis = .vertical
    }
    
    private func updateUI(with layout: Layout) {
        label.font = .systemFont(ofSize: layout.fontSize)
        button.titleLabel?.font = .systemFont(ofSize: layout.fontSize)
        stackView.spacing = layout.verticalSpacing
    }
    
    private func addViews() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)
    }
    
    private func setupAutolayout(with layout: Layout) {
        stackView.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.leading.equalToSuperview().offset(layout.horizontalMargin)
            $0.trailing.equalToSuperview().offset(-layout.horizontalMargin)
        }
    }
    
    func bind(viewModel: ViewModel) {
        // Actions
        button.rx.tap
            .map { CountViewEvent.didTapButton }
            .bind(to: viewModel.viewEvent )
            .disposed(by: disposeBag)
        
        // Effects
        bind(\CountViewState.countLabelText, to: label.rx.text)
    }
}
