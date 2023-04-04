//
//  File.swift
//  MovieQuiz
//
//  Created by Тимур Танеев on 12.03.2023.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    private weak var delegate: QuestionFactoryDelegate?

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self else {return}
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = self.movies[safe: index] else {return}

            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            }
            catch {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailToLoadImage(with: error)
                }
                return
            }

            let rating = Float(movie.rating) ?? 0

            // рейтинг в вопросе берем случайным близким чуть выше или ниже реального рейтинга
            // (опциональная задача)
            var questionRating = rating
            // легкий тюнинг для большей сложности
            // сделано несимметрично намеренно, т.к. далее округление результата всегда вверх
            let randomChange = [-1, 0]
            if let ratingChange = randomChange.randomElement() {
                // добавляем выбранное изменение, округляем вверх и убеждаемся, что результат не выше 8
                // т.к. если получилось 10, нет смысла задавать вопрос, выше ли рейтинг 10 - ответ всегда "нет"
                // фильмов с рейтингом больше 9 всего 2 - сильно меньше, чем фильмов с рейтингом выше 8.
                questionRating = min((questionRating + Float(ratingChange)).rounded(.awayFromZero), 8.0)
            }

            let text = "Рейтинг этого фильма больше чем \(Int(questionRating))?"

            let correctAnswer = rating > questionRating

            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

    func loadData() {
        moviesLoader.loadMovies{ [weak self] result in
            DispatchQueue.main.async {
                guard let self else {return}
                switch result {
                case .success(let mostPopularMovies):
                    var movies = mostPopularMovies.items
                    // в списке есть фильмы с пустым рейтингом, которые ломают квиз, уберем их
                    movies.removeAll(where: {$0.rating == ""})
                    self.movies = movies
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
