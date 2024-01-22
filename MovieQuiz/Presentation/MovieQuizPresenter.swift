import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - Properties
    
    private var aalertPresenter : AlertPresenterProtocol?
    private var alertPresenter : AlertPresenterProtocol?
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService!
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var correctAnswers = 0
    
    // MARK: - Init
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    // MARK: - Func
    
    func willShowAlert(alert: UIViewController) {
        self.viewController?.present(alert, animated: true){
        }
    }
    
    func showQuizResults(){
        let messageToShow = createMessageToShowInAlert()
        let alertModel = AlertModel(title: "Этот раунд окончен!", text: messageToShow, buttonText: "Сыграть ещё раз",completion: { [weak self] in
            self?.correctAnswers = 0
            self?.restartGame()
            self?.viewController?.presentNextQuizStepQuestion()
        })
        self.alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    func showNetworkError(message: String) {
        viewController?.hideLoadingIndicator()
        let alertModel = AlertModel(title: "Ошибка",text: message,buttonText: "Попробовать еще раз") {
            [weak self] in
            guard let self = self else { return }
            
            self.restartGame()
            self.restartGame()
            self.viewController?.showLoadingIndicator()
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            self.questionFactory?.loadData()
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(alertModel: alertModel )
    }
    
    func showAnswerResult(isCorrect: Bool) {
        var color = UIColor(resource: .ypRed).cgColor
        if isCorrect {
            correctAnswers += 1
            color = UIColor(resource: .ypGreen).cgColor
        }
        viewController?.configureImageFrame(color: color)
        viewController?.handleEnableAnswersButtons()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.configureImageFrame(color: (UIColor(resource: .ypGray).withAlphaComponent(0)).cgColor)
            self.showNextQuestionOrResults()
            self.viewController?.handleEnableAnswersButtons()
        }
    }
    
    func createMessageToShowInAlert() -> String{
        let recordToShow = statisticService?.bestGame
        guard let gamesCount = statisticService?.gamesCount else {return "0"}
        guard let recordCorrectAnswers = recordToShow?.correctAnswers else {return "0"}
        guard let recordTotalQuestions = recordToShow?.totalQuestions else {return "0"}
        guard let accuracy = statisticService?.totalAccuracy else {return "0"}
        guard let date = recordToShow?.date.dateTimeString else {return Date().dateTimeString}
        
        let messageToShow = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количесвто сыгранных квизов: \(gamesCount)
        Рекорд: \(recordCorrectAnswers.description)/\(recordTotalQuestions) (\(date))
        Средняя точность: \(String(format: "%.2f",accuracy))%
        """
        
        return messageToShow
    }
    
    func questionFactoryy(){
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame(){
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion(){
        currentQuestionIndex += 1
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quizStepViewModel: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            showQuizResults()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
