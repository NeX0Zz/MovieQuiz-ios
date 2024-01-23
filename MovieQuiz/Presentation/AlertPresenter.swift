import UIKit

final class AlertPresenter: AlertPresenterProtocol {

    weak var delegate: AlertPresenterDelegate?

    private var alertModel: AlertModel?

    init(delegate: AlertPresenterDelegate?) {
        self.delegate = delegate
    }

    func setDelegate(_ delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }

    func showAlert(alertModel: AlertModel) {

        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.text,
            preferredStyle: .alert)

        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
        alert.addAction(action)

        alert.view?.accessibilityIdentifier = "Game"

        delegate?.willShowAlert(alert: alert)
    }
}
