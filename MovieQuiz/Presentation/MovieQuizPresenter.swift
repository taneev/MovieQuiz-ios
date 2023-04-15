//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Тимур Танеев on 15.04.2023.
//

import UIKit

final class MovieQuizPresenter {

    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService

    let questionsAmount: Int = 10
    var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0

    init(viewController: MovieQuizViewController) {
        self.viewController = viewController

        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(),
                                          delegate: self)
        viewController.showLoadingIndicator()
        questionFactory?.loadData()
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else {return}
        let isCorrect = currentQuestion.correctAnswer == isYes
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }

    func reloadData() {
        questionFactory?.loadData()
    }

    func restartQuestion() {
        questionFactory?.requestNextQuestion()
    }


    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let movieImage = UIImage(data: model.image) ?? UIImage()
        let quizStep = QuizStepViewModel(image: movieImage,
                                         question: model.text,
                                         questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)")
        return quizStep
    }

    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }

    func showNextQuestionOrResults() {

        if isLastQuestion() {
            // формируем результат
            let resultTitle = "Этот раунд окончен!"
            var resultText = "Ваш результат: \(correctAnswers) из \(questionsAmount)\n"

            // Сохраним результат (и заодно пересчитаем статистику)
            statisticService.store(correct: correctAnswers,
                                   total: questionsAmount)

            // Доформируем строку результата с пересчитанной статистикой
            let bestGame = statisticService.bestGame
            resultText += "Количество сыграных квизов: \(statisticService.gamesCount)\n"
            resultText += "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))\n"
            resultText += "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy*100))%"

            let buttonText = "Сыграть еще раз"

            viewController?.show(quiz: QuizResultsViewModel(title: resultTitle, text: resultText, buttonText: buttonText))
        }
        else {
            // готовим следующий вопрос
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }


    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question else {return}

        currentQuestion = question

        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
}


// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        didRecieveNextQuestion(question: question)
    }

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }

    func didFailToLoadImage(with error: Error) {
        viewController?.showLoadImageError(message: error.localizedDescription)
    }
}
