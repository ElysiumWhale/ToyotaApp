import UIKit

enum TimeTypeController {
    case withTime
    case withoutTime
}

class BaseServiceViewController: UIViewController {
    @IBOutlet private(set) var primaryTextField: UITextField!
    @IBOutlet private(set) var datePicker: UIPickerView!
    @IBOutlet private(set) var indicator: UIActivityIndicatorView!
    @IBOutlet private(set) var sendOrderButton: UIButton!
    @IBOutlet private(set) var dateTimeLabel: UILabel!
    @IBOutlet private(set) var primaryLabel: UILabel!
    
    private(set) var type: TimeTypeController = .withTime
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open func configure(type: TimeTypeController) {
        self.type = type
    }
    
    open func bookService() {
        
    }
}

class TwoPicksServiceController: BaseServiceViewController {
    @IBOutlet private(set) var secondaryTextField: UITextField!
    @IBOutlet private(set) var secondaryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bookService() {
        
    }
}

class ThreePicksServiceController: TwoPicksServiceController {
    @IBOutlet private(set) var tertiaryTextField: UITextField!
    @IBOutlet private(set) var tertiaryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bookService() {
        
    }
}
