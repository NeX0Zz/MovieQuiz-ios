import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Properties
    
    private var alertPresenter : AlertPresenterProtocol?
    private var statisticService : StatisticService?
    private var currentQuestion: QuizQuestion?
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var correctAnswers = 0
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewController) {
           self.viewController = viewController
           questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
           questionFactory?.loadData()
           viewController.showLoadingIndicator()
       }
    
    // MARK: - Func
    
    func questionFactoryy(){
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    }
    func didLoadDataFromServer() {
        viewController?.activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
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
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
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
            viewController?.showQuizResults()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
