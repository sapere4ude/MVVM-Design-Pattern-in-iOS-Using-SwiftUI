//
//  MovieDetailViewModel.swift
//  MoviesApp
//
//  Created by Kant on 2023/06/24.
//

import Foundation
import Combine

class MovieDetailViewModel: ViewModelBase {
    
    private var movieDetail: MovieDetail?
    private var httpClient = HTTPClient()
    
    var cancellables = Set<AnyCancellable>()
    
    init(movieDetail: MovieDetail? = nil) {
        self.movieDetail = movieDetail
    }
    
    func getDetailsByImdbId(imdbId: String) {
        httpClient.getMovieDetailsBy(imdbId: imdbId)
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
            } receiveValue: { movieDetail in
                DispatchQueue.main.async {
                    self.movieDetail = movieDetail
                    self.loadingState = .success
                }
            }
            .store(in: &cancellables)
    }
    
    var title: String {
        self.movieDetail?.title ?? ""
    }
    
    var poster: String {
        self.movieDetail?.poster ?? ""
    }
    
    var plot: String {
        self.movieDetail?.plot ?? ""
    }
    
    var rating: Int {
        get {
            let ratingAsDouble = Double(self.movieDetail?.imdbRating ?? "0.0")
            return Int(ceil(ratingAsDouble ?? 0.0))
        }
    }
    
    var director: String {
        self.movieDetail?.director ?? ""
    }
}
