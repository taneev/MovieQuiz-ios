//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Тимур Танеев on 12.03.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
