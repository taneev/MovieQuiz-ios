import UIKit


final class MovieQuizViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.masksToBounds = true // Готовим возможность работать с рамкой
        imageView.layer.cornerRadius = 20 // устанавливаем радиус скругления углов картинки
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // статус-бар делаем светлым в соответствии с дизайн-макетом
        return .lightContent
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }

    func showLoadingIndicator() {
        // используется Hides when stopped (включено на сториборде)
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func showNetworkError(message: String) {
        hideLoadingIndicator()

        let networkAlert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") {[weak self] _ in
                self?.presenter.reloadData()
            }
        let alertPresenter = AlertPresenter(controller: self)
        alertPresenter.showAlert(alert: networkAlert)
    }

    func showLoadImageError(message: String) {
        let networkAlert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") {[weak self] _ in
                self?.presenter.restartQuestion()
            }
        let alertPresenter = AlertPresenter(controller: self)
        alertPresenter.showAlert(alert: networkAlert)
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        // Устанавливаем цвет и толщину рамки
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func toggleButtonsState(enable: Bool) {
        noButton.isEnabled = enable
        yesButton.isEnabled = enable
    }

    // MARK: - Show
    func show(quiz step: QuizStepViewModel) {

        imageView.image = step.image
        imageView.layer.borderWidth = 0 // убираем рамку
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {

        let alert = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText)
            {[weak self] _ in
                self?.presenter.restartGame()
            }
        let alertPresenter = AlertPresenter(controller: self, accessibilityIdentifier: "Quiz result")
        alertPresenter.showAlert(alert: alert)
    }
}
