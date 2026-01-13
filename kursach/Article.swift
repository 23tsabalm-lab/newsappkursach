import Foundation

// Відповідь від API має структуру { "status": "ok", "articles": [...] }
struct NewsResponse: Codable {
    let articles: [Article]
}

struct Article: Codable, Identifiable {
    // API не завжди повертає унікальний ID, тому генеруємо його динамічно для SwiftUI списку
    var id: String { url }
    
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    
    // Вкладена структура для джерела
    struct Source: Codable {
        let id: String?
        let name: String
    }
}
