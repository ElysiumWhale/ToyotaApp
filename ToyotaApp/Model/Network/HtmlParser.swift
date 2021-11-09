import Foundation
import SwiftSoup
import WebKit

protocol ParserDelegate: AnyObject {
    func newsDidLoad(_ news: [News])
    func errorDidReceive(_ error: Error)
}

/// Temporary class for parsing news from https://cars.toyota-aurora.ru
class HtmlParser: NSObject, WKNavigationDelegate {
    let url = "https://cars.toyota-aurora.ru/special-offers-list"
    let baseUrl = "https://cars.toyota-aurora.ru"
    
    weak var parserDelegate: ParserDelegate?
    var webView: WKWebView?
    
    init(delegate: ParserDelegate) {
        parserDelegate = delegate
        webView = WKWebView()
    }
    
    func start() {
        let url = URL(string: url)!
        webView?.navigationDelegate = self
        webView?.load(URLRequest(url: url))
    }
    
    func parseNews(from html: String) {
        var result: [News] = []
        do {
            let body = try SwiftSoup.parse(html).body()
            let cards = try body!.getElementsByClass(.newsCardClass)
            result.append(contentsOf: cards.array().compactMap { parseCard(from: $0) })
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.parserDelegate?.errorDidReceive(error)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.parserDelegate?.newsDidLoad(result)
        }
    }

    func parseCard(from element: Element) -> News? {
        do {
            let link: String = try element.attr(.href)
            let img = try element.select(.img).first()!
            let imgLink: String = try img.attr(.src)
            let imgTitle: String = try img.attr(.title)
            let truncatedTitle = imgTitle.replacingOccurrences(of: String.unicodeSpace,
                                                               with: String.space)
            
            return News(title: truncatedTitle.firstUppercased,
                        imgUrl: URL(string: imgLink),
                        url: URL(string: baseUrl + link))
        } catch {
            return nil
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(.documentJavaScript) { [weak self] (html, error) in
            if let webError = error {
                self?.parserDelegate?.errorDidReceive(webError)
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
