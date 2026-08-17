import Foundation

@MainActor
final class NewsService: ObservableObject {
    @Published private(set) var headlines: [NewsHeadline] = []

    func refresh() async {
        guard let url = URL(string: "https://feeds.bbci.co.uk/news/rss.xml") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let parser = RSSParser()
            let titles = parser.parse(data: data)
            headlines = titles.prefix(10).map { NewsHeadline(title: $0) }
        } catch {
            // Keep any previously loaded headlines on failure.
        }
    }
}

private final class RSSParser: NSObject, XMLParserDelegate {
    private var titles: [String] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var isInItem = false
    private var isFirstTitle = true

    func parse(data: Data) -> [String] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return titles
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            isInItem = true
            isFirstTitle = true
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isInItem && currentElement == "title" && isFirstTitle {
            currentTitle += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "title" && isInItem && isFirstTitle {
            let trimmed = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                titles.append(trimmed)
            }
            currentTitle = ""
            isFirstTitle = false
        } else if elementName == "item" {
            isInItem = false
        }
    }
}
