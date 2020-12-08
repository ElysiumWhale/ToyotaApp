import UIKit
import SwiftEntryKit

class PickerController: UIViewController {
    func configurePicker<T>(view: UIPickerView, with action: Selector, for textField: UITextField, delegate: T) where T: UIPickerViewDelegate & UIPickerViewDataSource {
        view.dataSource = delegate
        view.delegate = delegate
        textField.inputAccessoryView = buildToolbar(for: view, with: action)
        textField.inputView = view
    }
    
    private func buildToolbar(for pickerView: UIPickerView, with action: Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: action)
        toolBar.setItems([flexible, doneButton], animated: true)
        return toolBar
    }
}

class AddingCarViewController: PickerController {
    
    @IBOutlet private(set) var modelTextField: UITextField!
    @IBOutlet private(set) var colorTextField: UITextField!
    @IBOutlet private(set) var plateTextField: UITextField!
    @IBOutlet private(set) var checkVinButton: UIButton!
    @IBOutlet private(set) var modelLabel: UILabel!
    @IBOutlet private(set) var colorLabel: UILabel!
    @IBOutlet private(set) var plateLabel: UILabel!
    
    private var modelPicker: UIPickerView = UIPickerView()
    private var colorPicker: UIPickerView = UIPickerView()
    private var platePicker: UIPickerView = UIPickerView()
    
    var cars: [Car]?
    private var selectedModel: String?
    private var colors: [Car] = [Car]()
    private var selectedColor: String?
    private var plates: [Car] = [Car]()
    private var selectedPlate: String?
    
    struct Color {
        typealias Color = String
        var color: String?
    }
    
    private let cellIdentifier = CellIdentifiers.CarChoosingCell
    private let endRegisterSegueCode = SegueIdentifiers.CarToEndRegistration
    private let checkCarSegueCode = SegueIdentifiers.CarToCheckVin
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nullCar = Car(id: "", brandName: "", modelName: "Null", colorName: "Null", colorSwatch: "", colorDescription: "", isMetallic: "", licensePlate: "Null")
        colors.append(nullCar)
        plates.append(nullCar)
        configurePicker(view: modelPicker, with: #selector(selectModel), for: modelTextField, delegate: self)
        configurePicker(view: colorPicker, with: #selector(selectColor), for: colorTextField, delegate: self)
        configurePicker(view: platePicker, with: #selector(selectPlate), for: plateTextField, delegate: self)
        PopUpPreset.display(with: "Добавьте машину", description: "Выберите машину по параметрам и подтвердите ее владение с помощью VIN-кода", buttonText: "Ок")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case checkCarSegueCode:
                if let cell = sender as? CarChoosingCell {
                    let vc = segue.destination as? CheckVinViewController
                    vc!.car = cell.cellCar
                    vc!.parentDelegate = self
                } else {
                    let vc = segue.destination as? CheckVinViewController
                    vc!.car = plates.first(where: { $0.licensePlate == selectedPlate })
                    vc!.parentDelegate = self
                }
            default: return
        }
    }
    
    func configure(carsList: [Car]) {
        cars = carsList
    }
    
    @IBAction func checkVinButtonTapped(sender: Any?) {
        DispatchQueue.main.async { [self] in
            performSegue(withIdentifier: checkCarSegueCode, sender: sender)
        }
    }
}

//MARK: - AddingCarDelegate
extension AddingCarViewController: AddingCarDelegate {
    func carDidChecked() {
        DispatchQueue.main.async { [self] in
            performSegue(withIdentifier: endRegisterSegueCode, sender: nil)
        }
    }
}

//MARK: - UIPickerView Setup
extension AddingCarViewController {
    @objc private func selectModel(sender: Any?) {
        let row = modelPicker.selectedRow(inComponent: 0)
        selectedModel = cars![row].modelName
        modelTextField.text = selectedModel
        view.endEditing(true)
        colors = cars!.filter { $0.modelName == selectedModel }
        DispatchQueue.main.async { [self] in
            colorLabel.isHidden = false
            colorTextField.isHidden = false
            if selectedColor != nil {
                selectedColor = nil
                colorTextField.text = ""
            }
            if !plateTextField.isHidden {
                plateLabel.isHidden = true
                plateTextField.isHidden = true
            }
        }
    }
    
    @objc private func selectColor(sender: Any?) {
        let row = colorPicker.selectedRow(inComponent: 0)
        selectedColor = colors[row].colorDescription
        colorTextField.text = selectedColor
        view.endEditing(true)
        plates = colors.filter { $0.colorDescription == selectedColor }
        DispatchQueue.main.async { [self] in
            if selectedPlate != nil {
                selectedPlate = nil
                plateTextField.text = ""
            }
            plateLabel.isHidden = false
            plateTextField.isHidden = false
        }
    }
    
    @objc private func selectPlate(sender: Any?) {
        let row = platePicker.selectedRow(inComponent: 0)
        selectedPlate = plates[row].licensePlate
        plateTextField.text = selectedPlate
        view.endEditing(true)
        checkVinButton.isHidden = false
        checkVinButton.isEnabled = true
    }
}

//MARK: - UIPickerViewDataSource
extension AddingCarViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
            case modelPicker: return cars?.count ?? 1
            case colorPicker: return colors.count
            case platePicker: return plates.count
            default: return 1
        }
    }
}

//MARK: - UIPickerViewDelegate
extension AddingCarViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
            case modelPicker: return cars?[row].modelName ?? "No model"
            case colorPicker: return colors[row].colorDescription
            case platePicker: return plates[row].licensePlate
            default: return "Object is missing"
        }
    }
}
