import Foundation

final class NewsInteractor {
    private let newsService: NewsService

    private var url: ShowroomsUrl {
        ShowroomsUrl(rawValue: selectedShowroom?.id) ?? .samaraAurora
    }

    let showrooms: [Showroom] = [.aurora, .north, .south]

    private(set) var selectedShowroom: Showroom?
    private(set) var news: [News] = []

    var selectedShowroomIndex: Int? {
        showrooms.firstIndex(where: { $0.id == selectedShowroom?.id})
    }

    var onSuccessNewsLoad: Closure?
    var onFailureNewsLoad: Closure?

    init(newsService: NewsService = NewsInfoService()) {
        self.newsService = newsService

        selectedShowroom = DefaultsService.shared.get(key: .selectedShowroom) ?? .aurora
    }

    func loadNews() {
        newsService.getNews(for: url) { [weak self] response in
            self?.handleNewsResponse(response)
        }
    }

    func selectShowroomIfNeeded(at index: Int) -> Bool {
        guard showrooms.indices.contains(index) else {
            return false
        }

        let showroom = showrooms[index]
        if showroom.id != selectedShowroom?.id {
            selectedShowroom = showroom
            return true
        }

        return false
    }

    private func handleNewsResponse(_ response: Result<[News], Error>) {
        switch response {
        case .failure:
            news = []
            onFailureNewsLoad?()
        case .success(let loadedNews):
            news = loadedNews
            onSuccessNewsLoad?()
        }
    }
}

// MARK: - Predefined showrooms
private extension Showroom {
    static let aurora = Showroom(id: "7",
                                 showroomName: "Тойота Самара Аврора",
                                 cityName: "Самара")
    static let south = Showroom(id: "1",
                                showroomName: "Тойота Самара Юг",
                                cityName: "Самара")
    static let north = Showroom(id: "2",
                                showroomName: "Тойота Самара Север",
                                cityName: "Самара")
}
