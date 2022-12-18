import UIKit
import DesignKit

final class AddCarViewController: BaseViewController, Loadable {

    private let subtitleLabel = UILabel()
    private let fieldsStack = UIStackView()
    private let vinCodeTextField = InputTextField()
    private let plateTextField = InputTextField()
    private let modelTextField = InputTextField()
    private let yearTextField = InputTextField()
    private let colorTextField = InputTextField()
    private let actionButton = CustomizableButton()
    private let skipButton = UIButton()
    private let modelPicker = UIPickerView()
    private let yearPicker = UIPickerView()
    private let colorPicker = UIPickerView()

    private let interactor: AddCarInteractor

    let loadingView = LoadingView()

    var isLoading: Bool = false

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
        actionButton.size(.init(width: 245, height: 43))
        actionButton.bottomToSuperview(offset: -16,
                                       usingSafeArea: true)
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground

        subtitleLabel.textColor = .appTint(.signatureGray)
        subtitleLabel.font = .toyotaType(.semibold, of: 23)
        subtitleLabel.numberOfLines = .zero
        subtitleLabel.lineBreakMode = .byWordWrapping

        vinCodeTextField.maxSymbolCount = 17
        plateTextField.maxSymbolCount = 12

        for field in textFields {
            field.backgroundColor = .appTint(.background)
            field.cornerRadius = 10
            field.font = .toyotaType(.light, of: 18)
            field.textAlignment = .center
            field.textColor = .appTint(.signatureGray)
            field.rule = .notEmpty
            field.tintColor = .appTint(.secondarySignatureRed)
        }

        plateTextField.rule = nil

        skipButton.titleLabel?.font = .toyotaType(.regular, of: 18)
        skipButton.isHidden = interactor.type != .register
        skipButton.setTitleColor(.systemBlue, for: .normal)

        actionButton.rounded = true
        actionButton.titleLabel?.font = .toyotaType(.regular, of: 22)
        actionButton.normalColor = .appTint(.secondarySignatureRed)
        actionButton.highlightedColor = .appTint(.dimmedSignatureRed)
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
            .buildToolbar(with: #selector(modelDidPick))
        )
        yearPicker.configure(
            delegate: self,
            for: yearTextField,
            .buildToolbar(with: #selector(yearDidPick))
        )
        colorPicker.configure(
            delegate: self,
            for: colorTextField,
            .buildToolbar(with: #selector(colorDidPick))
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
        interactor.setCar(vin: vinCodeTextField.inputText,
                          plate: plateTextField.inputText)
    }
}

extension AddCarViewController {
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

        switch interactor.type {
        case .register:
            let vc = RegisterFlow.endRegistrationModule()
            vc.modalPresentationStyle = .fullScreen
            navigationController?.present(vc, animated: true)
        case .update:
            navigationController?.popToRootViewController(animated: true)
        }
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
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        switch pickerView {
        case modelPicker:
            return interactor.models[row].name
        case yearPicker:
            return interactor.years[row]
        case colorPicker:
            return interactor.colors[row].name
        default:
            return .empty
        }
    }

    @objc private func modelDidPick() {
        pick(from: modelPicker,
             to: modelTextField,
             setProperty: interactor.setSelectedModel)
    }

    @objc private func yearDidPick() {
        pick(from: yearPicker,
             to: yearTextField,
             setProperty: interactor.setSelectedYear)
    }

    @objc private func colorDidPick() {
        pick(from: colorPicker,
             to: colorTextField,
             setProperty: interactor.setSelectedColor)
    }

    private func pick(from picker: UIPickerView,
                      to textField: UITextField,
                      setProperty: (Int) -> String?) {
        view.endEditing(true)
        let index = picker.selectedRow
        textField.text = setProperty(index)
    }
}

// MARK: - UIPickerViewDataSource
extension AddCarViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
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
