//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Тимур Танеев on 13.03.2023.
//

import UIKit

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: (UIAlertAction) -> Void
}
