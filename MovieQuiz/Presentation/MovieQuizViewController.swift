import UIKit

struct QuizQuestion {
  let image: String
  let text: String
  let correctAnswer: Bool
}

// для состояния "Вопрос задан"
struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}

// для состояния "Результат квиза"
struct QuizResultsViewModel {
  let title: String
  let text: String
  let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    private let questions: [QuizQuestion] =
    [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initRoundStat() // инициализируем статистику раунда
        imageView.layer.masksToBounds = true // Готовим возможность работать с рамкой
        imageView.layer.cornerRadius = 20 // устанавливаем радиус скругления углов картинки
        
        let firstQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: firstQuestion)
        
        show(quiz: viewModel)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        // статус-бар делаем светлым в соответствии с дизайн-макетом
        return .lightContent
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        let isCorrect = questions[currentQuestionIndex].correctAnswer == false
        showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        let isCorrect = questions[currentQuestionIndex].correctAnswer == true
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // запускаем задачу через 1 секунду
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
        let quizStep = QuizStepViewModel(image: movieImage, question: model.text, questionNumber: "\(currentQuestionIndex+1)/\(questions.count)")
        return quizStep
    }

    private func showNextQuestionOrResults() {
        // Если кнопки заблокированы, разблокируем их (блокируются на время показа ответа на предыдущий вопрос)
        toggleButtonsState(enable: true)
        
        if currentQuestionIndex >= questions.count - 1 {
            // формируем результат
            let resultTitle = "Этот раунд окончен!"
            let resultText = "Ваш результат: \(correctAnswers) из \(questions.count)\n"
            let buttonText = "Сыграть еще раз"
            
            show(quiz: QuizResultsViewModel(title: resultTitle, text: resultText, buttonText: buttonText))
        }
        else {
            // готовим следующий вопрос
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)

            show(quiz: viewModel)
        }
    }

    private func show(quiz step: QuizStepViewModel) {

        imageView.image = step.image
        imageView.layer.borderWidth = 0 // убираем рамку
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title, // заголовок всплывающего окна
                                      message: result.text, // текст во всплывающем окне
                                      preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet

        // создаём для него кнопки с действиями
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.initRoundStat()

            // показываем первый вопрос
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }

        // добавляем в алерт кнопки
        alert.addAction(action)

        // показываем всплывающее окно
        self.present(alert, animated: true, completion: nil)
    }
}
