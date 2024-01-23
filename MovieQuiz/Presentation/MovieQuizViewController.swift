import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol, AlertPresenterDelegate {

    // MARK: - Outlets

    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noAnswerButton: UIButton!
    @IBOutlet private weak var yesAnswerButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties

    private var presenter: MovieQuizPresenter! = nil

    // MARK: - Overrides funcs

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        presenter.statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
    }

    // MARK: - Funcs

    func willShowAlert(alert: UIViewController) {
        self.present(alert, animated: true) {
        }
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
        }

    func show(quizStepViewModel: QuizStepViewModel) {
        previewImageView.image = quizStepViewModel.image
        questionLabel.text = quizStepViewModel.question
        counterLabel.text = quizStepViewModel.questionNumber
    }

    func handleEnableAnswersButtons() {
        noAnswerButton.isEnabled.toggle()
        yesAnswerButton.isEnabled.toggle()
    }

     func configureImageFrame(color: CGColor) {
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

    func presentNextQuizStepQuestion() {
        UIView.animate(withDuration: 1) { [weak self] in
            self?.presenter.questionFactory?.requestNextQuestion()
        }
    }

    // MARK: - IBActions

    @IBAction private func yesButtonTapped(_ sender: Any) {
        presenter.yesButtonClicked()
    }

    @IBAction private func noButtonTapped(_ sender: Any) {
        presenter.noButtonClicked()
    }
}
