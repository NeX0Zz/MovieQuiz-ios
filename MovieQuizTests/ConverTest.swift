import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: UIViewController, MovieQuizViewControllerProtocol {
    func configureImageFrame(color: CGColor) {
        
    }
    
    func show(quizStepViewModel: QuizStepViewModel){
        
    }
    func didReceiveNextQuestion(question: QuizQuestion?){
        
    }
    func handleEnableAnswersButtons(){
        
    }
    func hideLoadingIndicator(){
        
    }
    func showLoadingIndicator(){
        
    }

    func presentNextQuizStepQuestion(){
        
    }
    
    final class MovieQuizPresenterTests: XCTestCase {
        func testPresenterConvertModel() throws {
            let viewControllerMock = MovieQuizViewControllerMock()
            let sut = MovieQuizPresenter(viewController: viewControllerMock)
            
            let emptyData = Data()
            let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
            let viewModel = sut.convert(model: question)
            
            XCTAssertNotNil(viewModel.image)
            XCTAssertEqual(viewModel.question, "Question Text")
            XCTAssertEqual(viewModel.questionNumber, "1/10")
        }
    }
}
