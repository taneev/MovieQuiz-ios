//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Тимур Танеев on 15.04.2023.
//

import UIKit

final class MovieQuizPresenter {

    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService
    private weak var viewController: MovieQuizViewController?

    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
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

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else {return}
        let isCorrect = currentQuestion.correctAnswer == isYes
        proceedWithAnswer(isCorrect: isCorrect)
    }

    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let movieImage = UIImage(data: model.image) ?? UIImage()
        let quizStep = QuizStepViewModel(image: movieImage,
                                         question: model.text,
                                         questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)")
        return quizStep
    }

    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }

    private func makeResultMessage() -> String {
        var resultText = "Ваш результат: \(correctAnswers) из \(questionsAmount)\n"

        // Доформируем строку результата с пересчитанной статистикой
        let bestGame = statisticService.bestGame
        resultText += "Количество сыграных квизов: \(statisticService.gamesCount)\n"
        resultText += "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))\n"
        resultText += "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy*100))%"

        return resultText
    }

    private func proceedToNextQuestionOrResults() {
        // Если кнопки заблокированы, разблокируем их (блокируются на время показа ответа на предыдущий вопрос)
        viewController?.toggleButtonsState(enable: true)

        if isLastQuestion() {
            // Сохраним результат (и заодно пересчитаем статистику)
            statisticService.store(correct: correctAnswers,
                                   total: questionsAmount)

            // формируем результат
            let resultTitle = "Этот раунд окончен!"
            let resultText = makeResultMessage()
            let buttonText = "Сыграть еще раз"

            viewController?.show(quiz: QuizResultsViewModel(title: resultTitle, text: resultText, buttonText: buttonText))
        }
        else {
            // готовим следующий вопрос
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }

    private func proceedWithAnswer(isCorrect: Bool) {

        // На время показа результата заблокируем кнопки
        viewController?.toggleButtonsState(enable: false)

        didAnswer(isCorrectAnswer: isCorrect)

        // Устанавливаем цвет и толщину рамки
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            self?.proceedToNextQuestionOrResults()
        }
    }
}


// MARK: - QuestionFactoryDelegate
extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {return}

        currentQuestion = question

        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
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
