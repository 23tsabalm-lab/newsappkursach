import Foundation

@MainActor
class NewsFeedViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var filteredArticles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Для фільтрації (Вимога 3: Фільтрація за джерелом)
    @Published var searchText = "" {
        didSet {
            filterNews()
        }
    }
    
    private let service = NewsService()
    
    func loadNews() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedArticles = try await service.fetchTechnologyNews()
                self.articles = fetchedArticles
                self.filterNews()
                self.isLoading = false
            } catch {
                self.errorMessage = "Помилка завантаження: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func filterNews() {
        if searchText.isEmpty {
            filteredArticles = articles
        } else {
            // Фільтруємо за назвою джерела або заголовком
            filteredArticles = articles.filter { article in
                article.source.name.lowercased().contains(searchText.lowercased()) ||
                article.title.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    func addToFavorites(article: Article) {
        FavoritesManager.shared.save(article: article)
    }
}
