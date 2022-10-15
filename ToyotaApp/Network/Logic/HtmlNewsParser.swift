import Foundation
import SwiftSoup
import WebKit

/// Experimental
struct ParserContainer<T: HtmlParserService> {
    private let parser: T

    init(parser: T) {
        self.parser = parser
    }

    func parse<TData, TParams>(
        from url: URL?,
        params: [TParams: Any] = [:],
        handler: ParameterClosure<Result<TData, Error>>?
    ) where TData == T.TParsingData, TParams == T.TAdditionalParameters {

        parser.parseData(from: url,
                         additionalParameters: params,
                         handler: handler)
    }
}

/// Experimental
protocol HtmlParserService {
    associatedtype TParsingData
    associatedtype TAdditionalParameters: Hashable

    func parseData(from url: URL?,
                   additionalParameters: [TAdditionalParameters: Any],
                   handler: ParameterClosure<Result<TParsingData, Error>>?)
}

/// Temporary class for parsing news from toyota showrooms
final class HtmlNewsParser: NSObject, HtmlParserService {
    enum AdditionalParameters: Hashable {
        case baseUrl
    }

    private let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1, height: 1))

    private var imageBaseUrl: String = .empty
    private var handler: ParameterClosure<Result<[News], Error>>?

    func parseData(from url: URL?,
                   additionalParameters: [AdditionalParameters: Any],
                   handler: ParameterClosure<Result<[News], Error>>?) {

        guard let url = url else {
            handler?(.failure(AppErrors.newsError))
            return
        }

        self.handler = handler
        imageBaseUrl = additionalParameters[.baseUrl] as? String ?? .empty
        webView.navigationDelegate = self
        webView.load(.init(url: url))
    }

    private func parseNews(from html: String) {
        var result: [News] = []
        do {
            let body = try SwiftSoup.parse(html).body()
            let cards = try body!.getElementsByClass(.newsCardClass)
            result.append(contentsOf: cards.array().compactMap { parseCard(from: $0) })
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.handler?(.failure(error))
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.handler?(.success(result))
        }
    }

    private func parseCard(from element: Element) -> News? {
        do {
            let link: String = try element.attr(.href)
            let img = try element.select(.img).first()!
            let imgLink: String = try img.attr(.src)
            let imgTitle: String = try img.attr(.title)
            let truncatedTitle = imgTitle.replacingOccurrences(
                of: String.unicodeSpace,
                with: String.space
            )

            return News(title: truncatedTitle.firstUppercased,
                        imgUrl: URL(string: imgLink),
                        url: URL(string: imageBaseUrl + link))
        } catch {
            return nil
        }
    }
}

// MARK: - WKNavigationDelegate
extension HtmlNewsParser: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(.documentJavaScript) { [weak self] (html, error) in
            if let webError = error {
                self?.handler?(.failure(webError))
            } else {
                self?.parseNews(from: html as? String ?? .empty)
            }
        }
    }
}

private extension String {
    static let newsCardClass = "news-card"
    static let href = "href"
    static let src = "src"
    static let img = "img"
    static let title = "title"
    static let unicodeSpace = "&#160;"
    static let documentJavaScript = "document.documentElement.outerHTML"
}
