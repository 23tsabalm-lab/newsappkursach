import Foundation

class NewsService {
    
    private let apiKey = "903f21c1ac5249d491d120994bb79fe1"
    private let baseUrl = "https://newsapi.org/v2/top-headlines"
    
    func fetchTechnologyNews() async throws -> [Article] {
        // Формуємо URL: категорія technology, країна us (або ua), ключ
        guard let url = URL(string: "\(baseUrl)?category=technology&country=us&apiKey=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decodedResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
        return decodedResponse.articles
    }
}
