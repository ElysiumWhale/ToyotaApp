import UIKit
import DesignKit

enum AddCarOutput {
    case carDidAdd(_ scenario: AddInfoScenario)
}

protocol AddCarModule: UIViewController, Outputable<AddCarOutput> { }

final class AddCarViewController: BaseViewController, Loadable, AddCarModule {

    private let subtitleLabel = UILabel()
    private let fieldsStack = UIStackView()
    private let vinCodeTextField = InputTextField(.toyota)
    private let plateTextField = InputTextField(.toyota)
    private let modelTextField = InputTextField(.toyota)
    private let yearTextField = InputTextField(.toyota)
    private let colorTextField = InputTextField(.toyota)
    private let actionButton = CustomizableButton(.toyotaAction())
    private let skipButton = UIButton()
    private let modelPicker = UIPickerView()
    private let yearPicker = UIPickerView()
    private let colorPicker = UIPickerView()

    private let interactor: AddCarInteractor

    let loadingView = LoadingView()

    var output: ParameterClosure<AddCarOutput>?

    init(interactor: AddCarInteractor) {
        self.interactor = interactor

        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if interactor.loadNeeded {
            startLoading()
            interactor.loadModelsAndColors()
        }
    }

    override func addViews() {
        addSubviews(subtitleLabel, fieldsStack, skipButton, actionButton)
        fieldsStack.addArrangedSubviews(textFields)
    }

    override func configureLayout() {
        subtitleLabel.edgesToSuperview(
            excluding: .bottom,
            insets: .horizontal(16),
            usingSafeArea: true
        )

        fieldsStack.axis = .vertical
        fieldsStack.spacing = 8
        fieldsStack.distribution = .fillEqually
        fieldsStack.topToBottom(of: subtitleLabel, offset: 20)
        fieldsStack.horizontalToSuperview(insets: .horizontal(16))

        vinCodeTextField.height(50)

        skipButton.centerXToSuperview()
        skipButton.bottomToSuperview(offset: -65,
                                     usingSafeArea: true)

        actionButton.centerXToSuperview()
        actionButton.size(.toyotaActionL)
        actionButton.bottomToSuperview(offset: -16,
                                       usingSafeArea: true)
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground

        subtitleLabel.textColor = .appTint(.signatureGray)
        subtitleLabel.backgroundColor = view.backgroundColor
        subtitleLabel.font = .toyotaType(.semibold, of: 23)
        subtitleLabel.numberOfLines = .zero
        subtitleLabel.lineBreakMode = .byWordWrapping

        vinCodeTextField.maxSymbolCount = 17
        plateTextField.maxSymbolCount = 12

        textFields.forEach { $0.rule = .notEmpty }
        plateTextField.rule = nil

        skipButton.titleLabel?.font = .toyotaType(.regular, of: 18)
        skipButton.isHidden = interactor.type != .register
        skipButton.setTitleColor(.systemBlue, for: .normal)
    }

    override func localize() {
        navigationItem.title = .common(.auto)
        subtitleLabel.text = .common(.fillAutoInfo)
        vinCodeTextField.placeholder = .common(.vin)
        plateTextField.placeholder = .common(.numberNotNecessary)
        modelTextField.placeholder = .common(.model)
        yearTextField.placeholder = .common(.year)
        colorTextField.placeholder = .common(.color)
        skipButton.setTitle(.common(.skipThisStep), for: .normal)
        actionButton.setTitle(.common(.next), for: .normal)
    }

    override func configureActions() {
        view.hideKeyboard(when: .tapAndSwipe)

        modelPicker.configure(
            delegate: self,
            for: modelTextField,
            .makeToolbar(#selector(modelDidPick))
        )
        yearPicker.configure(
            delegate: self,
            for: yearTextField,
            .makeToolbar(#selector(yearDidPick))
        )
        colorPicker.configure(
            delegate: self,
            for: colorTextField,
            .makeToolbar(#selector(colorDidPick))
        )

        skipButton.addAction { [weak self] in
            self?.skipButtonDidPress()
        }

        actionButton.addAction { [weak self] in
            self?.actionButtonDidPress()
        }
    }

    private func skipButtonDidPress() {
        guard interactor.type == .register else {
            return
        }

        startLoading()
        interactor.skipRegister()
    }

    private func actionButtonDidPress() {
        let fieldsValidation = textFields.areValid
        let vinValidation = vinCodeTextField.validate(
            for: .requiredSymbolsCount(17),
            toggleState: true
        )

        guard fieldsValidation, vinValidation else {
            return
        }

        startLoading()
        interactor.setCar(
            vin: vinCodeTextField.inputText,
            plate: plateTextField.inputText
        )
    }
}

private extension AddCarViewController {
    var textFields: [InputTextField] {
        [
            vinCodeTextField,
            plateTextField,
            modelTextField,
            yearTextField,
            colorTextField
        ]
    }
}

// MARK: - AddCarViewInput
extension AddCarViewController: AddCarViewInput {
    func handleCarAdded() {
        stopLoading()

        output?(.carDidAdd(interactor.type))
    }

    func handleFailure(with message: String) {
        PopUp.display(.error(description: message))
        stopLoading()
    }

    func handleModelsLoaded() {
        stopLoading()
        modelPicker.reloadComponent(0)
        colorPicker.reloadComponent(0)
    }
}

// MARK: - UIPickerViewDelegate
extension AddCarViewController: UIPickerViewDelegate {
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        switch pickerView {
        case modelPicker:
            return interactor.models[safe: row]?.name
        case yearPicker:
            return interactor.years[safe: row]
        case colorPicker:
            return interactor.colors[safe: row]?.name
        default:
            return .empty
        }
    }

    @objc private func modelDidPick() {
        view.endEditing(true)
        let index = modelPicker.selectedRow
        modelTextField.text = interactor.setSelectedModel(for: index)
    }

    @objc private func yearDidPick() {
        view.endEditing(true)
        let index = yearPicker.selectedRow
        yearTextField.text = interactor.setSelectedYear(for: index)
    }

    @objc private func colorDidPick() {
        view.endEditing(true)
        let index = colorPicker.selectedRow
        colorTextField.text = interactor.setSelectedColor(for: index)
    }
}

// MARK: - UIPickerViewDataSource
extension AddCarViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        switch pickerView {
        case modelPicker:
            return interactor.models.count
        case colorPicker:
            return interactor.colors.count
        case yearPicker:
            return interactor.years.count
        default:
            return .zero
        }
    }
}
