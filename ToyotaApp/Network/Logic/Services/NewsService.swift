import Foundation

protocol NewsService {
    func getNews(for showroomUrl: ShowroomsUrl,
                 handler: ParameterClosure<Result<[News], Error>>?)
}

/// Experimental
final class NewsInfoService: NewsService {
    private let container: ParserContainer<HtmlNewsParser>

    init(container: ParserContainer<HtmlNewsParser> = .init(parser: .init())) {
        self.container = container
    }

    func getNews(for showroomUrl: ShowroomsUrl,
                 handler: ParameterClosure<Result<[News], Error>>?) {
        container.parser.parseData(from: URL(string: showroomUrl.url)!,
                                   additionalParameters: [.baseUrl: showroomUrl.baseUrl],
                                   handler: handler)
    }
}
