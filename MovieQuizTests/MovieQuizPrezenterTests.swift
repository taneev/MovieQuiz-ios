//
//  MovieQuizPrezenterTests.swift
//  MovieQuizTests
//
//  Created by Тимур Танеев on 15.04.2023.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {

    func show(quiz step: QuizStepViewModel) {

    }

    func show(quiz result: QuizResultsViewModel) {

    }

    func highlightImageBorder(isCorrectAnswer: Bool) {

    }

    func showLoadingIndicator() {

    }

    func hideLoadingIndicator() {

    }

    func showNetworkError(message: String) {

    }

    func showLoadImageError(message: String) {

    }

    func toggleButtonsState(enable: Bool) {

    }
}

final class MovieQuizPrezenterTests: XCTestCase {

    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)

        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)

        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
