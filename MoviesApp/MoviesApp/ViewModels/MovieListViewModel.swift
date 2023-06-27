//
//  MovieListViewModel.swift
//  MoviesApp
//
//  Created by Kant on 2023/06/24.
//

import Foundation
import SwiftUI
import Combine

class MovieListViewModel: ViewModelBase {
    
    @Published var movies = [MovieViewModel]()
    var httpClient = HTTPClient()
    
    var cancellables = Set<AnyCancellable>()
    
    func searchByName(name: String) {
        
        if name.isEmpty { return }

        self.loadingState = .loading
        
        httpClient.getMoviesBy(search: name.trimmedAndEscaped())
            .sink { completion in
                switch completion {
                case .finished:
                    print(#fileID, #function, #line, "request success")
                case .failure(let error):
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.loadingState = .failed
                    }
                }
            } receiveValue: { movies in
                if let movies = movies {
                    DispatchQueue.main.async {
                        self.movies = movies.map(MovieViewModel.init)
                        self.loadingState = .success
                    }
                }
            }
            .store(in: &cancellables)
    }
}

struct MovieViewModel {
    let movie: Movie
    
    var imdbId: String {
        movie.imdbId
    }
    
    var title: String {
        movie.title
    }
    
    var poster: String {
        movie.poster
    }
    
    var year: String {
        movie.year
    }
}
