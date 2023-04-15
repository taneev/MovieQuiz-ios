import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var correctAnswers: Int = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initRoundStat() // инициализируем статистику раунда
        imageView.layer.masksToBounds = true // Готовим возможность работать с рамкой
        imageView.layer.cornerRadius = 20 // устанавливаем радиус скругления углов картинки

        presenter.viewController = self

        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // статус-бар делаем светлым в соответствии с дизайн-макетом
        return .lightContent
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }

    private func showLoadingIndicator() {
        // используется Hides when stopped (включено на сториборде)
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let networkAlert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") {[weak self] _ in
                guard let self else {return}

                self.questionFactory?.loadData()
            }
        let alertPresenter = AlertPresenter(controller: self)
        alertPresenter.showAlert(alert: networkAlert)
    }

    private func showLoadImageError(message: String) {
        let networkAlert = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") {[weak self] _ in
                guard let self else {return}

                self.questionFactory?.requestNextQuestion()
            }
        let alertPresenter = AlertPresenter(controller: self)
        alertPresenter.showAlert(alert: networkAlert)
    }

    func showAnswerResult(isCorrect: Bool) {
        
        // На время показа результата заблокируем кнопки
        toggleButtonsState(enable: false)
        
        if isCorrect {
            correctAnswers += 1
        }
        // Устанавливаем цвет и толщину рамки
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self else {return}
            // запускаем задачу через 1 секунду
            self.showNextQuestionOrResults()
        }
    }
    
    private func initRoundStat() {
        presenter.resetQuestionIndex()
        correctAnswers = 0
    }

    private func toggleButtonsState(enable: Bool) {
        noButton.isEnabled = enable
        yesButton.isEnabled = enable
    }

    // MARK: - Show
    private func showNextQuestionOrResults() {
        // Если кнопки заблокированы, разблокируем их (блокируются на время показа ответа на предыдущий вопрос)
        toggleButtonsState(enable: true)
        
        if presenter.isLastQuestion() {
            // формируем результат
            let resultTitle = "Этот раунд окончен!"
            var resultText = "Ваш результат: \(correctAnswers) из \(presenter.questionsAmount)\n"
            if let statisticService {
                // Сохраним результат (и заодно пересчитаем статистику)
                statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)

                // Доформируем строку результата с пересчитанной статистикой
                let bestGame = statisticService.bestGame
                resultText += "Количество сыграных квизов: \(statisticService.gamesCount)\n"
                resultText += "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))\n"
                resultText += "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            }
            let buttonText = "Сыграть еще раз"
            
            show(quiz: QuizResultsViewModel(title: resultTitle, text: resultText, buttonText: buttonText))
        }
        else {
            // готовим следующий вопрос
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }

    private func show(quiz step: QuizStepViewModel) {

        imageView.image = step.image
        imageView.layer.borderWidth = 0 // убираем рамку
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {

        let alert = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText)
            {[weak self] _ in
                guard let self else {return}
                self.initRoundStat()
                // показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            }
        let alertPresenter = AlertPresenter(controller: self, accessibilityIdentifier: "Quiz result")
        alertPresenter.showAlert(alert: alert)
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    func didFailToLoadImage(with error: Error) {
        showLoadImageError(message: error.localizedDescription)
    }

}
