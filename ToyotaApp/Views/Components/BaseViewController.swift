import UIKit
import DesignKit

class BaseViewController: UIViewController, InitialazableView {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }

    func addViews() {
        // override in subclasses
    }

    func configureLayout() {
        // override in subclasses
    }

    func configureAppearance() {
        // override in subclasses
    }

    func localize() {
        // override in subclasses
    }

    func configureActions() {
        // override in subclasses
    }

    func setBackButtonTitle(_ title: String?) {
        navigationController?.navigationBar.topItem?.backButtonTitle = title
    }
}
