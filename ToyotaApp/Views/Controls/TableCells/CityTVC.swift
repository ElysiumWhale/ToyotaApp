import UIKit

class CityTVC: TableCell {
    @IBOutlet private var cityNameLabel: UILabel!

    class var identifier: UITableView.TableCells { .cityCell }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if !highlighted {
            backgroundColor = .appTint(.background)
            return
        }

        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0.0,
                                                       options: .curveEaseOut, animations: {
            self.backgroundColor = .appTint(.secondarySignatureRed)
        })
    }
}
