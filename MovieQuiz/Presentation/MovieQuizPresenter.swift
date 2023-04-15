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

    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0

    func yesButtonClicked() {
        guard let currentQuestion else {return}
        let isCorrect = currentQuestion.correctAnswer == true
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }

    func noButtonClicked() {
        guard let currentQuestion else {return}
        let isCorrect = currentQuestion.correctAnswer == false
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 0
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

}
