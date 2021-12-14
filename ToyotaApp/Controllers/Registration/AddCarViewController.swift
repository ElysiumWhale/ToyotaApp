import UIKit

class AddCarViewController: UIViewController, PickerController {
    @IBOutlet private var vinCodeTextField: InputTextField!
    @IBOutlet private var plateTextField: InputTextField!
    @IBOutlet private var modelTextField: InputTextField!
    @IBOutlet private var yearTextField: InputTextField!
    @IBOutlet private var colorTextField: InputTextField!
    @IBOutlet private var nextButton: KeyboardBindedButton!
    @IBOutlet private var skipButton: UIButton!

    private var modelPicker = UIPickerView()
    private var yearPicker = UIPickerView()
    private var colorPicker = UIPickerView()

    private let interactor = AddCarInteractor()

    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.view = self
        skipButton.isHidden = interactor.type != .register

        view.hideKeyboardWhenSwipedDown()

        configurePicker(modelPicker, with: modelDidPick, for: modelTextField)
        configurePicker(yearPicker, with: yearDidPick, for: yearTextField)
        configurePicker(colorPicker, with: colorDidPick, for: colorTextField)

        if interactor.loadNeeded {
            interactor.loadModelsAndColors()
        }
    }

    func configure(models: [Model], colors: [Color], controllerType: AddInfoType = .register) {
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
        let validated = [modelTextField, colorTextField,
                         yearTextField, vinCodeTextField].reduce(true, { hasError, field in
            let fieldHasError = field?.text == nil || field?.text?.isEmpty ?? true
            field?.toggle(state: fieldHasError ? .error : .normal)
            return hasError && fieldHasError
        })

        guard interactor.vin.count == 17 else {
            vinCodeTextField.toggle(state: .error)
            return
        }

        guard validated else {
            return
        }

        nextButton.fadeOut()
        interactor.setCar()
    }

    @IBAction private func skipButtonDidPressed(sender: Any?) {
        guard interactor.type != .register else {
            return
        }

        handleCarAdded()
    }

    // MARK: - Private methods
    private func modelDidPick() {
        view.endEditing(true)
        let index = modelPicker.selectedRow(inComponent: 0)
        modelTextField.text = interactor.setSelectedModel(for: index)
    }

    private func yearDidPick() {
        view.endEditing(true)
        let index = yearPicker.selectedRow(inComponent: 0)
        yearTextField.text = interactor.setSelectedYear(for: index)
    }

    private func colorDidPick() {
        view.endEditing(true)
        let index = colorPicker.selectedRow(inComponent: 0)
        colorTextField.text = interactor.setSelectedColor(for: index)
    }
}

// MARK: - AddCarViewInput
extension AddCarViewController: AddCarViewInput {
    func handleCarAdded() {
        nextButton.fadeIn()
        perform(segue: .addCarToEndRegistration)
    }

    func handleFailure(with message: String) {
        PopUp.display(.error(description: message))
        nextButton.fadeIn()
    }

    func handleModelsLoaded() {
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
