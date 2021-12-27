import UIKit

class AddCarViewController: UIViewController, PickerController, Loadable {
    @IBOutlet private var vinCodeTextField: InputTextField!
    @IBOutlet private var plateTextField: InputTextField!
    @IBOutlet private var modelTextField: InputTextField!
    @IBOutlet private var yearTextField: InputTextField!
    @IBOutlet private var colorTextField: InputTextField!
    @IBOutlet private var nextButton: CustomizableButton!
    @IBOutlet private var skipButton: UIButton!
    @IBOutlet private var indicator: UIActivityIndicatorView!

    private var modelPicker = UIPickerView()
    private var yearPicker = UIPickerView()
    private var colorPicker = UIPickerView()
    let loadingView = LoadingView()

    private let interactor = AddCarInteractor()

    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.view = self
        skipButton.isHidden = interactor.type != .register

        view.hideKeyboardWhenSwipedDown()

        configurePicker(modelPicker, with: #selector(modelDidPick), for: modelTextField)
        configurePicker(yearPicker, with: #selector(yearDidPick), for: yearTextField)
        configurePicker(colorPicker, with: #selector(colorDidPick), for: colorTextField)

        if interactor.loadNeeded {
            loadModelsAndColors()
        }

        if case .update = interactor.type {
            let item = UIBarButtonItem(title: .common(.done), style: .plain,
                                       target: self, action: #selector(customDismiss))
            item.tintColor = .appTint(.secondarySignatureRed)
            navigationItem.rightBarButtonItem = item
        }
    }

    func configure(models: [Model] = [], colors: [Color] = [], controllerType: AddInfoType = .register) {
        interactor.configure(type: controllerType, models: models, colors: colors)
    }

    // MARK: - IBActions
    @IBAction private func textDidChange(sender: UITextField) {
        switch sender {
            case vinCodeTextField:
                interactor.vin = sender.text ?? .empty
            case plateTextField:
                interactor.plate = sender.text ?? .empty
            default: print(sender)
        }

        sender.toggle(state: .normal)
    }

    @IBAction private func nextButtonDidPressed(sender: Any?) {
        var validated = true
        [modelTextField, colorTextField,
         yearTextField, vinCodeTextField].forEach { field in
            let fieldHasError = field?.text == nil || field?.text?.isEmpty ?? true
            validated = validated && !fieldHasError
            field?.toggle(state: fieldHasError ? .error : .normal)
        }

        guard interactor.vin.count == .vinLength else {
            vinCodeTextField.toggle(state: .error)
            return
        }

        guard validated else {
            return
        }

        nextButton.fadeOut()
        indicator.startAnimating()
        interactor.setCar()
    }

    @IBAction private func skipButtonDidPressed(sender: Any?) {
        guard interactor.type == .register else {
            return
        }

        skipButton.fadeOut()
        nextButton.fadeOut()
        indicator.startAnimating()
        interactor.skipRegister()
    }

    // MARK: - Private methods
    private func loadModelsAndColors() {
        startLoading()
        interactor.loadModelsAndColors()
    }

    @objc private func modelDidPick() {
        pick(from: modelPicker, to: modelTextField, setProperty: interactor.setSelectedModel)
    }

    @objc private func yearDidPick() {
        pick(from: yearPicker, to: yearTextField, setProperty: interactor.setSelectedYear)
    }

    @objc private func colorDidPick() {
        pick(from: colorPicker, to: colorTextField, setProperty: interactor.setSelectedColor)
    }

    private func pick(from picker: UIPickerView, to textField: UITextField, setProperty: (Int) -> String?) {
        view.endEditing(true)
        let index = picker.selectedRow
        textField.text = setProperty(index)
        if textField.text != nil || !textField.text!.isEmpty {
            textField.toggle(state: .normal)
        }
    }
}

// MARK: - AddCarViewInput
extension AddCarViewController: AddCarViewInput {
    func handleCarAdded() {
        indicator.stopAnimating()
        nextButton.fadeIn()
        switch interactor.type {
            case .register:
                perform(segue: .addCarToEndRegistration)
            case .update:
                popToRootWithDispatch(animated: true)
        }
    }

    func handleFailure(with message: String) {
        PopUp.display(.error(description: message))
        indicator.stopAnimating()
        nextButton.fadeIn()
    }

    func handleModelsLoaded() {
        stopLoading()
        modelPicker.reloadComponent(0)
        colorPicker.reloadComponent(0)
    }
}

// MARK: - UIPickerViewDataSource
extension AddCarViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
            case modelPicker:
                return interactor.models.count
            case yearPicker:
                return interactor.years.count
            case colorPicker:
                return interactor.colors.count
            default:
                return 0
        }
    }
}

// MARK: - UIPickerViewDelegate
extension AddCarViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
}
