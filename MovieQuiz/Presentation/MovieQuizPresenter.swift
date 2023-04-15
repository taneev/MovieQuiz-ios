//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Тимур Танеев on 15.04.2023.
//

import UIKit

final class MovieQuizPresenter {

    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0

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
