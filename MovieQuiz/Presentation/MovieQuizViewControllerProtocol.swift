//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Тимур Танеев on 15.04.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)

    func highlightImageBorder(isCorrectAnswer: Bool)

    func showLoadingIndicator()
    func hideLoadingIndicator()

    func showNetworkError(message: String)
    func showLoadImageError(message: String)

    func toggleButtonsState(enable: Bool)
}
