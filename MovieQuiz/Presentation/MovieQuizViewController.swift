import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noAnswerButton: UIButton!
    @IBOutlet private weak var yesAnswerButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private var presenter: MovieQuizPresenter! = nil
    private var alertPresenter : AlertPresenterProtocol?
    private var statisticService : StatisticService?
    private var userAnswer = false
    // MARK: - Overrides funcs
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesAnswerButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        noAnswerButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
    }
    
    // MARK: - Func
    
    func willShowAlert(alert: UIViewController) {
        self.present(alert, animated: true){
        }
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
        }
    
    // MARK: - Private funcs
    
    func show(quizStepViewModel: QuizStepViewModel) {
        previewImageView.image = quizStepViewModel.image
        questionLabel.text = quizStepViewModel.question
        counterLabel.text = quizStepViewModel.questionNumber
    }
    
    private func handleEnableAnswersButtons(){
        noAnswerButton.isEnabled.toggle()
        yesAnswerButton.isEnabled.toggle()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        var color = UIColor(resource: .ypRed).cgColor
        if isCorrect {
            presenter.correctAnswers += 1
            color = UIColor(resource: .ypGreen).cgColor
        }
        configureImageFrame(color: color)
        handleEnableAnswersButtons()
        self.presenter.correctAnswers = self.presenter.correctAnswers
        self.presenter.questionFactory = self.presenter.questionFactory

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.configureImageFrame(color: (UIColor(resource: .ypGray).withAlphaComponent(0)).cgColor)
            self.presenter.showNextQuestionOrResults()
            self.handleEnableAnswersButtons()
        }
    }
    
    private func configureImageFrame(color: CGColor) {
        UIView.animate(withDuration: 0.68) { [weak self] in
            self?.previewImageView.layer.masksToBounds = true
            self?.previewImageView.layer.borderWidth = 8
            self?.previewImageView.layer.cornerRadius = 20
            self?.previewImageView.layer.borderColor = color
        }
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
     func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(title: "Ошибка",text: message,buttonText: "Попробовать еще раз") {
            [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            self.presenter.restartGame()
            self.showLoadingIndicator()
            presenter = MovieQuizPresenter(viewController: self)
            self.presenter?.questionFactory?.loadData()
            self.presenter?.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(alertModel: alertModel )
    }
    
    func presentNextQuizStepQuestion(){
        UIView.animate(withDuration: 1){ [weak self] in
            self?.presenter.questionFactory?.requestNextQuestion()
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
        Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
        Количесвто сыгранных квизов: \(gamesCount)
        Рекорд: \(recordCorrectAnswers.description)/\(recordTotalQuestions) (\(date))
        Средняя точность: \(String(format: "%.2f",accuracy))%
        """
        
        return messageToShow
    }
    
    func showQuizResults(){
        let messageToShow = createMessageToShowInAlert()
        let alertModel = AlertModel(title: "Этот раунд окончен!", text: messageToShow, buttonText: "Сыграть ещё раз",completion: { [weak self] in
            self?.presenter.correctAnswers = 0
            self?.presenter.restartGame()
            self?.presentNextQuizStepQuestion()
        })
        self.alertPresenter?.showAlert(alertModel: alertModel)
    }
    
    //MARK: - IBActions
    
    @IBAction private func yesButtonTapped(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonTapped(_ sender: Any) {
        presenter.noButtonClicked()
    }
}





