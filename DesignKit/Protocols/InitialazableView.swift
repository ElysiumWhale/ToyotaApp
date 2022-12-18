import UIKit

public protocol InitialazableView {
    func addViews()
    func configureLayout()
    func configureAppearance()
    func localize()
    func configureActions()
}

public extension InitialazableView {
    func initialize() {
        addViews()
        configureLayout()
        configureAppearance()
        localize()
        configureActions()
    }

    func addViews() { }

    func configureLayout() { }

    func configureAppearance() { }

    func localize() { }

    func configureActions() { }
}
