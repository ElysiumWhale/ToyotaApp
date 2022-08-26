import UIKit
import SafariServices

final class NewsViewController: BaseViewController, Refreshable {
    private let newsService: NewsService
    private let showrooms: [Showroom] = [.aurora, .north, .south]
    private let showroomPicker = UIPickerView()

    let refreshableView = TableView<NewsCell>()
    let showroomField = NoCopyPasteTextField()

    private(set) var refreshControl = UIRefreshControl()

    private var news: [News] = []
    private var selectedRow: IndexPath?
    private var selectedShowroom: Showroom? = DefaultsManager.retrieve(for: .selectedShowroom) ?? .aurora
    private var url: ShowroomsUrl {
        ShowroomsUrl(rawValue: selectedShowroom?.id) ?? .samaraAurora
    }


    init(newsService: NewsService = HtmlParser()) {
        self.newsService = newsService

        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshableView.dataSource = self
        refreshableView.delegate = self

        configureRefresh()
        if let index = showrooms.firstIndex(where: { $0.id == selectedShowroom?.id}) {
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
        refreshableView.edgesToSuperview(excluding: .top, usingSafeArea: true)

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
        showroomField.text = selectedShowroom?.showroomName
    }

    override func configureActions() {
        showroomPicker.configure(delegate: self,
                                 with: #selector(showroomDidSelect),
                                 for: showroomField)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedRow = selectedRow {
            refreshableView.deselectRow(at: selectedRow, animated: true)
        }
    }

    func startRefreshing() {
        if news.isNotEmpty {
            news = []
            refreshableView.reloadData()
        }
        refreshControl.startRefreshing()
        newsService.getNews(for: url) { [weak self] response in
            self?.handleNewsResponse(response)
        }
    }

    private func handleNewsResponse(_ response: Result<[News], Error>) {
        switch response {
        case .failure:
            news = []
            refreshableView.reloadData()
            endRefreshing()
            refreshableView.setBackground(text: .error(.newsError))
        case .success(let loadedNews):
            news = loadedNews
            refreshableView.reloadData()
            let text: String? = loadedNews.isEmpty ? .background(.noNews) : nil
            refreshableView.setBackground(text: text)
            endRefreshing()
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
}

// MARK: - UITableViewDelegate
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = news[indexPath.row].url else {
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
        news.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewsCell = tableView.dequeue(for: indexPath)
        cell.configure(with: news[indexPath.item])
        return cell
    }
}

// MARK: - UIPickerViewDataSource
extension NewsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        showrooms.count
    }
}

// MARK: - UIPickerViewDelegate
extension NewsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        showrooms[row].showroomName
    }
}
