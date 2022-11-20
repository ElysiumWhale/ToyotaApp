import UIKit
import SafariServices

final class NewsViewController: BaseViewController, Refreshable {
    private let interactor: NewsInteractor
    private let showroomPicker = UIPickerView()

    let refreshableView = TableView<NewsCell>()
    let showroomField = NoCopyPasteTextField()
    let refreshControl = UIRefreshControl()

    private var selectedRow: IndexPath?

    init(interactor: NewsInteractor = .init()) {
        self.interactor = interactor

        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshableView.dataSource = self
        refreshableView.delegate = self

        configureRefresh()
        if let index = interactor.selectedShowroomIndex {
            showroomPicker.selectRow(index, inComponent: 0, animated: false)
        }
        startRefreshing()
    }

    override func addViews() {
        let button: UIButton = .imageButton { [weak self] in
            self?.showroomField.becomeFirstResponder()
        }
        showroomField.setRightView(from: button,
                                   height: 45)

        addSubviews(showroomField, refreshableView)
    }

    override func configureLayout() {
        showroomField.height(45)
        showroomField.horizontalToSuperview(insets: .horizontal(16))
        showroomField.topToSuperview(offset: 5, usingSafeArea: true)

        refreshableView.topToBottom(of: showroomField, offset: 5)
        refreshableView.edgesToSuperview(excluding: .top,
                                         usingSafeArea: true)

        refreshableView.alwaysBounceVertical = true
    }

    override func configureAppearance() {
        configureNavBarAppearance(color: nil)
        view.backgroundColor = .systemBackground

        showroomField.tintColor = .clear
        showroomField.rightViewMode = .always
        showroomField.backgroundColor = .appTint(.background)
        showroomField.font = .toyotaType(.light, of: 25)
        showroomField.textColor = .appTint(.signatureGray)
        showroomField.adjustsFontSizeToFitWidth = true
        showroomField.minimumFontSize = 17
        showroomField.textAlignment = .center
        showroomField.cornerRadius = 10

        refreshableView.separatorStyle = .singleLine
        refreshableView.separatorColor = .appTint(.secondaryGray)
        refreshableView.sectionHeaderHeight = .zero
    }

    override func localize() {
        navigationItem.title = .common(.offers)
        showroomField.text = interactor.selectedShowroom?.showroomName
        showroomField.placeholder = .common(.chooseShowroom)
    }

    override func configureActions() {
        showroomPicker.configure(
            delegate: self,
            with: #selector(showroomDidSelect),
            for: showroomField
        )

        interactor.onSuccessNewsLoad = { [weak self] in
            DispatchQueue.main.async {
                self?.handleSuccess()
            }
        }

        interactor.onFailureNewsLoad = { [weak self] in
            DispatchQueue.main.async {
                self?.handleError()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedRow = selectedRow {
            refreshableView.deselectRow(at: selectedRow, animated: true)
        }
    }

    func startRefreshing() {
        refreshControl.startRefreshing()
        interactor.loadNews()
    }

    private func handleError() {
        refreshableView.reloadData()
        endRefreshing()
        refreshableView.setBackground(text: .error(.newsError))
    }

    private func handleSuccess() {
        refreshableView.reloadData()
        let text: String? = interactor.news.isEmpty ? .background(.noNews) : nil
        refreshableView.setBackground(text: text)
        endRefreshing()
    }

    @objc func showroomDidSelect() {
        if interactor.selectShowroomIfNeeded(at: showroomPicker.selectedRow) {
            showroomField.text = interactor.selectedShowroom?.showroomName
            refreshControl.refreshManually()
        }

        view.endEditing(true)
    }
}

// MARK: - UITableViewDelegate
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard let url = interactor.news[indexPath.row].url else {
            return
        }

        selectedRow = indexPath

        let webController = SFSafariViewController(url: url)
        webController.preferredControlTintColor = .appTint(.secondarySignatureRed)
        navigationController?.present(webController,
                                      animated: true)
    }
}

// MARK: - UITableViewDataSource
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        interactor.news.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsCell = tableView.dequeue(for: indexPath)
        cell.configure(with: interactor.news[indexPath.item])
        return cell
    }
}

// MARK: - UIPickerViewDataSource
extension NewsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        interactor.showrooms.count
    }
}

// MARK: - UIPickerViewDelegate
extension NewsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        interactor.showrooms[row].showroomName
    }
}
