import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quizStepViewModel: QuizStepViewModel)
    func didReceiveNextQuestion(question: QuizQuestion?)
    func handleEnableAnswersButtons()
    func hideLoadingIndicator()
    func showLoadingIndicator()
    func presentNextQuizStepQuestion()
    
}

