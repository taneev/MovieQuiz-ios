//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Тимур Танеев on 30.03.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

enum LoaderError: Error {
    case loaderDecodeError(String)

    var localizedDescription: String {
        switch self {
        case .loaderDecodeError(let message):
            return message
        }
    }
}

struct MoviesLoader: MoviesLoading {


    // MARK: - NetworkClient
    private let networkClient = NetworkClient()

    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/MostPopularMovies/k_2m3tg8et") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }

    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) {result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    guard !mostPopularMovies.items.isEmpty else {
                        let error = LoaderError.loaderDecodeError(mostPopularMovies.errorMessage)
                        handler(.failure(error))
                        return
                    }
                    handler(.success(mostPopularMovies))
                    return
                }
                catch {
                    handler(.failure(error))
                }
            }
        }
    }
}
