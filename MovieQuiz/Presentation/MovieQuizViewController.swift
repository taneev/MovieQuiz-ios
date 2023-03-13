import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initRoundStat() // инициализируем статистику раунда
        imageView.layer.masksToBounds = true // Готовим возможность работать с рамкой
        imageView.layer.cornerRadius = 20 // устанавливаем радиус скругления углов картинки
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // статус-бар делаем светлым в соответствии с дизайн-макетом
        return .lightContent
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion else {return}
        let isCorrect = currentQuestion.correctAnswer == false
        showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion else {return}
        let isCorrect = currentQuestion.correctAnswer == true
        showAnswerResult(isCorrect: isCorrect)
    }

    private func showAnswerResult(isCorrect: Bool) {
        
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
        currentQuestionIndex = 0
        correctAnswers = 0
    }

    private func toggleButtonsState(enable: Bool) {
        noButton.isEnabled = enable
        yesButton.isEnabled = enable
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let movieImage = UIImage(named: model.image) ?? UIImage()
        let quizStep = QuizStepViewModel(image: movieImage, question: model.text, questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)")
        return quizStep
    }

    private func showNextQuestionOrResults() {
        // Если кнопки заблокированы, разблокируем их (блокируются на время показа ответа на предыдущий вопрос)
        toggleButtonsState(enable: true)
        
        if currentQuestionIndex >= questionsAmount - 1 {
            // формируем результат
            let resultTitle = "Этот раунд окончен!"
            let resultText = "Ваш результат: \(correctAnswers) из \(questionsAmount)\n"
            let buttonText = "Сыграть еще раз"
            
            show(quiz: QuizResultsViewModel(title: resultTitle, text: resultText, buttonText: buttonText))
        }
        else {
            // готовим следующий вопрос
            currentQuestionIndex += 1
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

        let alert = AlertModel(title: result.title,message: result.text, buttonText: result.buttonText)
            {[weak self] _ in
                guard let self else {return}
                self.initRoundStat()
                // показываем первый вопрос
                self.questionFactory?.requestNextQuestion()
            }
        let alertPresenter = AlertPresenter(controller: self)
        alertPresenter.showAlert(alert: alert)
    }
}
