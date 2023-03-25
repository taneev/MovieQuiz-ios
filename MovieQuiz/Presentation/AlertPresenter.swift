//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Тимур Танеев on 13.03.2023.
//

import UIKit

class AlertPresenter {
    
    private var controller: UIViewController
    
    init(controller: UIViewController) {
        self.controller = controller
    }
    
    func showAlert(alert: AlertModel) {
        let alertController = UIAlertController(title: alert.title,
                                      message: alert.message,
                                      preferredStyle: .alert)

        let action = UIAlertAction(title: alert.buttonText, style: .default, handler: alert.completion)
        alertController.addAction(action)
        controller.present(alertController, animated: true, completion: nil)
    }
}
