//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Тимур Танеев on 09.04.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()
        app.launch()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
        app = nil
    }

    // MARK: - кнопки Да/Нет
    func testYesButton() throws {
        sleep(3)

        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Yes"].tap()
        sleep(3)

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testNoButton() throws {
        sleep(3)

        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["No"].tap()
        sleep(3)

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]

        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    //MARK: - алерт с результатами
    func testRoundResultAlert() throws {
        // 10 раз жмем Да, чтобы добраться до Алерта с результатами раунда
        for _ in 1...10 {
            sleep(2)
            app.buttons["Yes"].tap()
        }

        sleep(2)
        // Проверим, что алерт появился
        let alert = app.alerts["Quiz result"]
        XCTAssertTrue(alert.exists)

        // Проверим заголовок алерта
        XCTAssertEqual(alert.label, "Этот раунд окончен!")

        // Проверим текст кнопки
        let alertButton = alert.buttons.firstMatch
        XCTAssertEqual(alertButton.label, "Сыграть еще раз")
    }

    func testAlertDismiss() {
        for _ in 1...10 {
            sleep(2)
            app.buttons["Yes"].tap()
        }

        sleep(2)
        let alert = app.alerts["Quiz result"]
        alert.buttons.firstMatch.tap()

        sleep(2)
        let indexLabel = app.staticTexts["Index"]

        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
