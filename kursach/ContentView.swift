import SwiftUI

struct NewsFeedView: View {
    @StateObject private var viewModel = NewsFeedViewModel()
    @State private var showFavorites = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Завантаження новин...")
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text(error).foregroundColor(.red)
                        Button("Спробувати знову") {
                            viewModel.loadNews()
                        }
                    }
                } else {
                    List(viewModel.filteredArticles) { article in
                        NavigationLink(destination: ArticleDetailView(article: article)) {
                            ArticleRowView(article: article)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.addToFavorites(article: article)
                            } label: {
                                Label("В улюблене", systemImage: "star.fill")
                            }
                            .tint(.yellow)
                        }
                    }
                    .refreshable {
                        viewModel.loadNews()
                    }
                }
            }
            .navigationTitle("Tech News")
            .searchable(text: $viewModel.searchText, prompt: "Пошук за джерелом...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FavoritesView()) {
                        Image(systemName: "star.circle")
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadNews()
        }
    }
}

// Окремий рядок списку
struct ArticleRowView: View {
    let article: Article
    
    var body: some View {
        HStack(alignment: .top) {
            // Вимога 4: AsyncImage для завантаження фото
            if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 80, height: 80)
                    case .success(let image):
                        image.resizable()
                             .aspectRatio(contentMode: .fill)
                             .frame(width: 80, height: 80)
                             .cornerRadius(8)
                    case .failure:
                        Image(systemName: "photo")
                             .frame(width: 80, height: 80)
                             .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Заглушка, якщо фото немає
                Color.gray.opacity(0.3)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .overlay(Image(systemName: "newspaper").foregroundColor(.gray))
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let description = article.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                Text(article.source.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

// Екран з WebView
struct ArticleDetailView: View {
    let article: Article
    
    var body: some View {
        WebView(urlString: article.url)
            .navigationTitle(article.source.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}

// Екран улюблених
struct FavoritesView: View {
    @State private var favorites = FavoritesManager.shared.getFavorites()
    
    var body: some View {
        List(favorites) { item in
            NavigationLink(destination: WebView(urlString: item.url)) {
                VStack(alignment: .leading) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.url)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Улюблене")
        .onAppear {
            favorites = FavoritesManager.shared.getFavorites()
        }
    }
}
