import UIKit
import SafariServices

class NewsViewController: RefreshableController {
    @IBOutlet private(set) var refreshableView: UITableView!
    @IBOutlet private var showroomField: NoCopyPasteTexField!

    private(set) var refreshControl = UIRefreshControl()
    private let showroomPicker = UIPickerView()

    private let showrooms: [Showroom] = [.aurora, .north, .south]

    private var user: UserProxy!
    private var news: [News] = []
    private var selectedRow: IndexPath?
    private var selectedShowroom: Showroom? = DefaultsManager.retrieve(for: .selectedShowroom) ?? .aurora
    private var url: ShowroomsUrl {
        ShowroomsUrl(rawValue: selectedShowroom?.id) ?? .samaraAurora
    }

    private lazy var parser = HtmlParser(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.toyotaType(.regular, of: 17)
        ]
        configureRefresh()
        showroomField.text = selectedShowroom?.showroomName
        configureShowroomField()
        if let index = showrooms.firstIndex(where: { $0.id == selectedShowroom?.id}) {
            showroomPicker.selectRow(index, inComponent: 0, animated: false)
        }
        refreshableView.alwaysBounceVertical = true
        startRefreshing()
    }

    func startRefreshing() {
        if news.isNotEmpty {
            news = []
            refreshableView.reloadData()
        }
        refreshControl.startRefreshing()
        parser.start(with: url)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedRow = selectedRow {
            refreshableView.deselectRow(at: selectedRow, animated: true)
        }
    }

    @objc func showroomDidSelect() {
        let newShowroom = showrooms[showroomPicker.selectedRow]
        if newShowroom.id != selectedShowroom?.id {
            selectedShowroom = newShowroom
            startRefreshing()
            showroomField.text = newShowroom.showroomName
        }
        view.endEditing(true)
    }

    private func configureShowroomField() {
        showroomField.tintColor = .clear
        showroomField.rightViewMode = .always
        let button: UIButton = .imageButton { [weak self] in
            self?.showroomField.becomeFirstResponder()
        }
        showroomField.setRightView(from: button, width: 30,
                                   height: showroomField.frame.height)
        showroomPicker.configure(delegate: self,
                                 with: #selector(showroomDidSelect),
                                 for: showroomField)
    }
}

// MARK: - UITableViewDelegate
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = news[indexPath.row].url {
            selectedRow = indexPath
            navigationController?.present(SFSafariViewController(url: url),
                                          animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        news.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsTableViewCell = tableView.dequeue(for: indexPath)
        cell.configure(with: news[indexPath.item])
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }
}

// MARK: - ParserDelegate
extension NewsViewController: ParserDelegate {
    func errorDidReceive(_ error: Error) {
        news = []
        refreshableView.reloadData()
        endRefreshing()
        refreshableView.setBackground(text: .error(.newsError))
    }

    func newsDidLoad(_ loadedNews: [News]) {
        news = loadedNews
        refreshableView.reloadData()
        let text: String? = loadedNews.isEmpty ? .background(.noNews) : nil
        refreshableView.setBackground(text: text)
        endRefreshing()
    }
}

// MARK: - WithUserInfo
extension NewsViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
}

// MARK: - UIPickerViewDataSource
extension NewsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        showrooms.count
    }
}

// MARK: - UIPickerViewDelegate
extension NewsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        showrooms[row].showroomName
    }
}
