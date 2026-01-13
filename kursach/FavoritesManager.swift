import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    private let key = "FavoriteArticles"
    
    // Зберігаємо лише прості дані: назву та посилання
    struct FavoriteItem: Codable, Identifiable {
        var id: String { url }
        let title: String
        let url: String
    }
    
    func save(article: Article) {
        var favorites = getFavorites()
        if !favorites.contains(where: { $0.url == article.url }) {
            let item = FavoriteItem(title: article.title, url: article.url)
            favorites.append(item)
            if let data = try? JSONEncoder().encode(favorites) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
    
    func getFavorites() -> [FavoriteItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let favorites = try? JSONDecoder().decode([FavoriteItem].self, from: data) else {
            return []
        }
        return favorites
    }
    
    func isFavorite(article: Article) -> Bool {
        return getFavorites().contains(where: { $0.url == article.url })
    }
}
