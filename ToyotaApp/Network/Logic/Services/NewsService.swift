import Foundation

protocol NewsService {
    func getNews(
        for showroomUrl: ShowroomsUrl,
        handler: ParameterClosure<Result<[News], Error>>?
    )
}

/// Experimental
struct NewsInfoService: NewsService {
    private let container: HtmlNewsParser

    init(container: HtmlNewsParser = HtmlNewsParser()) {
        self.container = container
    }

    func getNews(
        for showroomUrl: ShowroomsUrl,
        handler: ParameterClosure<Result<[News], Error>>?
    ) {
        container.parseData(
            from: URL(string: showroomUrl.url)!,
            additionalParameters: [.baseUrl: showroomUrl.baseUrl],
            handler: handler
        )
    }
}
