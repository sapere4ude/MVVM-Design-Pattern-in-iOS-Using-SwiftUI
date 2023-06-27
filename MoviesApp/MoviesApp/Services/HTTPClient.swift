//
//  HTTPClient.swift
//  MoviesApp
//
//  Created by Kant on 2023/06/22.
//

import Foundation
import Combine

enum NetworkError: Error {
    case badUrl
    case noData
    case decodingError
}

class HTTPClient {
    
//    func getMovieDetailsBy(imdbId: String, completion: @escaping (Result<MovieDetail, NetworkError>) -> Void) {
//
//        guard let url = URL.forMoviesByImdbId(imdbId) else {
//            return completion(.failure(.badUrl))
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//
//            guard let data = data, error == nil else {
//                return completion(.failure(.noData))
//            }
//
//            guard let movieDetail = try? JSONDecoder().decode(MovieDetail.self, from: data) else {
//                return completion(.failure(.decodingError))
//            }
//
//            completion(.success(movieDetail))
//
//        }.resume()
//    }

    func getMovieDetailsBy(imdbId: String) -> AnyPublisher<MovieDetail, NetworkError> {
        guard let url = URL.forMoviesByImdbId(imdbId) else {
            return Fail(error: NetworkError.badUrl).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw NetworkError.noData
                }
                return data
            }
            .decode(type: MovieDetail.self, decoder: JSONDecoder())
            .mapError { error -> NetworkError in
                if let decodingError = error as? DecodingError {
                    return .decodingError
                } else {
                    return .noData
                }
            }
            .eraseToAnyPublisher()
    }
    
//    func getMoviesBy(search: String, completion: @escaping (Result<[Movie]?, NetworkError>) -> Void) {
//
//        guard let url = URL.forMoviesByName(search) else {
//            return completion(.failure(.badUrl))
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//
//            guard let data = data, error == nil else {
//                return completion(.failure(.noData))
//            }
//
//            guard let moviesResponse = try? JSONDecoder().decode(MovieResponse.self, from: data) else {
//                return completion(.failure(.decodingError))
//            }
//
//            completion(.success(moviesResponse.movies))
//
//        }.resume()
//    }
    
    func getMoviesBy(search: String) -> AnyPublisher<[Movie]?, NetworkError> {
        
        guard let url = URL.forMoviesByName(search) else {
            return Fail(error: NetworkError.badUrl).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      200..<300 ~= httpResponse.statusCode else {
                    throw NetworkError.noData
                }
                return data
            }
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .map { $0.movies }
            .mapError { error -> NetworkError in
                if let decodingError = error as? DecodingError {
                    return .decodingError
                } else {
                    return .noData
                }
            }
            .eraseToAnyPublisher()
    }

}
