import UIKit

protocol MovieQuizViewControllerProtocol:UIViewController, AnyObject {
    func show(quizStepViewModel: QuizStepViewModel)
    func didReceiveNextQuestion(question: QuizQuestion?)
    func handleEnableAnswersButtons()
    func hideLoadingIndicator()
    func showLoadingIndicator()
    func presentNextQuizStepQuestion()
    func configureImageFrame(color: CGColor)
}

