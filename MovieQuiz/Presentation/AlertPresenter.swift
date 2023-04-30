//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Тимур Танеев on 13.03.2023.
//

import UIKit

final class AlertPresenter {
    
    private var controller: UIViewController
    private var accessibilityIdentifier: String
    
    init(controller: UIViewController, accessibilityIdentifier: String = "alert") {
        self.controller = controller
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    func showAlert(alert: AlertModel) {
        let alertController = UIAlertController(title: alert.title,
                                      message: alert.message,
                                      preferredStyle: .alert)
        alertController.view.accessibilityIdentifier = accessibilityIdentifier
        let action = UIAlertAction(title: alert.buttonText, style: .default, handler: alert.completion)
        alertController.addAction(action)
        controller.present(alertController, animated: true, completion: nil)
    }
}
