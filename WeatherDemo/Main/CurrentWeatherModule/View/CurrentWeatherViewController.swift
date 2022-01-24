//
//  CurrentWeatherViewController.swift
//  WeatherDemo
//
//  Created by Георгий Рыбак on 20.01.22.
//

import UIKit

class CurrentWeatherViewController: UIViewController {
    private let containerView = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    private let curentWeatherImage = UIImageView()
    private let locationLabel = UILabel()
    private let precipitationImage = UIImageView()
    private let popImage = UIImageView()
    private let pressureImage = UIImageView()
    private let windSpeedImage = UIImageView()
    private let poleImage = UIImageView()
    private let popLabel = UILabel()
    private let precipitationLable = UILabel()
    private let pressureLabel = UILabel()
    private let windSpeedLabel = UILabel()
    private let poleLabel = UILabel()
    private let imageview = UIImageView()
    private let shareButton = UIButton(type: .system)

    var presenter: CurrentWeatherPresenter!

    private var currentWeather: CurrentWeatherViewModel?

    private lazy var curentWeatherLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        return label
    }()

    private lazy var noInternetView: UIView = {
        let view = getNoInternetView(frame: view.safeAreaLayoutGuide.layoutFrame)
        return view
    }()

    private enum AlertType {
        case dataIsNotAvaible
        case locationDisabled
        case locationIsNotAvaible
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configUI()
    }

    // MARK: - Layouts
    override func viewWillLayoutSubviews() {
        disableTranslAutoresMaskIntoConstraints()
        layoutViewItems()
        layoutLables()
        layoutImages()
        layoutButton()
    }

    // MARK: - Config elements
    private func configUI() {
        addViews()
        configStyles()

        navigationController?.navigationBar.barTintColor = UIColor(named: "colorForHeaders")

        view.backgroundColor = UIColor(named: "secondaryBackground")

        noInternetView.isHidden = true

        shareButton.addTarget(presenter, action: #selector(self.presenter.share), for: .touchUpInside)
    }

    // MARK: - Adding views
    private func addViews() {
        view.addSubview(containerView)
        view.addSubview(activityIndicator)
        view.addSubview(noInternetView)
        [
            curentWeatherImage,
            locationLabel,
            curentWeatherLabel,
            popImage,
            popLabel,
            precipitationImage,
            precipitationLable,
            pressureImage,
            pressureLabel,
            windSpeedImage,
            windSpeedLabel,
            poleImage,
            poleLabel,
            shareButton
        ].forEach( { containerView.addSubview($0) } )
    }

    // MARK: - Config styles
    private func configStyles() {
        // Icons of weather parametrs config
        popImage.image = UIImage(systemName: "cloud.rain.fill")
        precipitationImage.image = UIImage(systemName: "drop.fill")
        pressureImage.image = UIImage(systemName: "aqi.medium")
        windSpeedImage.image = UIImage(systemName: "wind")
        poleImage.image = UIImage(systemName: "globe")
        curentWeatherImage.contentMode = .scaleAspectFit

        // Activity indicator config
        activityIndicator.style = .large
        activityIndicator.backgroundColor = .systemBackground
        activityIndicator.layer.opacity = 1
        activityIndicator.hidesWhenStopped = true
        activityIndicator.backgroundColor = UIColor(named: "secondaryBackground")
        activityIndicator.startAnimating()

        // Button config
        shareButton.setTitle("Share", for: .normal)
        shareButton.tintColor = .systemRed

        // Location lable config
        curentWeatherLabel.textColor = .systemBlue

        // Lables text config
        [
            curentWeatherLabel,
            locationLabel,
            popLabel,
            precipitationLable,
            pressureLabel,
            windSpeedLabel,
            poleLabel
        ].forEach(
            {
                $0.textAlignment = .center
                $0.numberOfLines = 0
            }
        )
    }

    // MARK: - Alerts configer
    private func getRequiredAlert(type: AlertType) -> UIAlertController {
        let title = "Error"
        let messege: String
        let action: UIAlertAction

        switch type {
        case .dataIsNotAvaible:
            messege = "Can't get  current data from network"
            action = UIAlertAction(
                title: "Try again",
                style: .cancel,
                handler: { _ in self.presenter.getWeather() }
            )
        case .locationDisabled:
            messege = "Location is disabled"
            action = UIAlertAction(
                title: "Enable in settings",
                style: .default
            ) { _ in
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)! as URL,
                    options: [:],
                    completionHandler: nil
                )
            }
        case .locationIsNotAvaible:
            messege = "Can't get current location"
            action = UIAlertAction(
                title: "Try again",
                style: .cancel,
                handler: { _ in self.presenter.locationService.requestLocation() }
            )
        }

        let alert = UIAlertController(title: title, message: messege, preferredStyle: .alert)
        alert.addAction(action)

        return alert
    }

    // MARK: - Updating view data
    private func updateData() {
        guard let weather = currentWeather else { return }
        popLabel.text = "\(weather.pop)"
        precipitationLable.text = "\(weather.precipitation)"
        precipitationImage.image = UIImage(systemName: "\(weather.precipitationIcon)")
        pressureLabel.text = "\(weather.pressure)"
        windSpeedLabel.text = "\(weather.windSpeed)"
        poleLabel.text = "\(weather.windDirection)"
        curentWeatherLabel.text = "\(weather.tempWithDiscription)"
        locationLabel.text = "\(weather.location)"
        curentWeatherImage.image = UIImage(named: weather.icon)
    }
}

// MARK: - Protocol methods
extension CurrentWeatherViewController: CurrentWeatherViewProtocol {
    func present(activityVC: UIActivityViewController) {
        self.present(
            activityVC,
            animated: true,
            completion: nil
        )
    }

    func configureIndicator(animation: Bool) {
        if animation {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    func checkedInternetConnection(connection: Bool) {
        if connection {
            noInternetView.isHidden = true
        } else {
            noInternetView.isHidden = false
        }
    }

    func succesGettingData(model: CurrentWeatherViewModel) {
        currentWeather = model
        updateData()
    }

    func failureGettingData() {
        present(getRequiredAlert(type: .dataIsNotAvaible), animated: true, completion: nil)
    }

    func failureGettingLocation() {
        present(getRequiredAlert(type: .locationIsNotAvaible), animated: true, completion: nil)
    }

    func locationIsDisabled() {
        present(getRequiredAlert(type: .locationDisabled), animated: true, completion: nil)
    }
}

// MARK: - Private layout methods
private extension CurrentWeatherViewController {
    func layoutViewItems() {
        view.addConstraints(
            [
                containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                activityIndicator.topAnchor.constraint(equalTo: view.topAnchor),
                activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
        )
    }

    func disableTranslAutoresMaskIntoConstraints() {
        [
            curentWeatherImage,
            locationLabel,
            curentWeatherLabel,
            popImage,
            precipitationImage,
            pressureImage,
            windSpeedImage,
            poleImage,
            shareButton,
            popLabel,
            precipitationLable,
            pressureLabel,
            windSpeedLabel,
            poleLabel,
            containerView,
            activityIndicator,
            containerView,
            activityIndicator
        ].forEach( { $0.translatesAutoresizingMaskIntoConstraints = false } )
    }

    func layoutImages() {
        let width = view.safeAreaLayoutGuide.layoutFrame.size.width
        let widthConst = width / 7
        let elemXConst = (width - 2 * widthConst) / 3
        let halfHeight = view.safeAreaLayoutGuide.layoutFrame.size.height / 2
        let elemYConst = (halfHeight - 2 * widthConst) / 4
        let heightConst = halfHeight / 8

        containerView.addConstraints(
            [
                curentWeatherImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                curentWeatherImage.heightAnchor.constraint(equalToConstant: 5 * heightConst),
                curentWeatherImage.widthAnchor.constraint(equalToConstant: 5 * heightConst),
                curentWeatherImage.topAnchor.constraint(
                    equalTo: containerView.topAnchor,
                    constant: 0.75 * heightConst
                ),
                popImage.heightAnchor.constraint(equalToConstant: widthConst),
                popImage.widthAnchor.constraint(equalToConstant: widthConst),
                popImage.leadingAnchor.constraint(
                    equalTo: containerView.leadingAnchor,
                    constant: widthConst
                ),
                popImage.topAnchor.constraint(
                    equalTo: containerView.centerYAnchor,
                    constant: elemYConst
                ),
                precipitationImage.heightAnchor.constraint(equalToConstant: widthConst),
                precipitationImage.widthAnchor.constraint(equalToConstant: widthConst),
                precipitationImage.leadingAnchor.constraint(
                    equalTo: containerView.leadingAnchor,
                    constant: 3 * widthConst
                ),
                precipitationImage.topAnchor.constraint(
                    equalTo: containerView.centerYAnchor,
                    constant: elemYConst
                ),
                pressureImage.heightAnchor.constraint(equalToConstant: widthConst),
                pressureImage.widthAnchor.constraint(equalToConstant: widthConst),
                pressureImage.leadingAnchor.constraint(
                    equalTo: containerView.leadingAnchor,
                    constant: 5 * widthConst
                ),
                pressureImage.topAnchor.constraint(
                    equalTo: containerView.centerYAnchor,
                    constant: elemYConst
                ),
                windSpeedImage.heightAnchor.constraint(equalToConstant: widthConst),
                windSpeedImage.widthAnchor.constraint(equalToConstant: widthConst),
                windSpeedImage.leadingAnchor.constraint(
                    equalTo: containerView.leadingAnchor,
                    constant: elemXConst
                ),
                windSpeedImage.topAnchor.constraint(
                    equalTo: containerView.centerYAnchor,
                    constant: 2 * elemYConst + widthConst
                ),
                poleImage.heightAnchor.constraint(equalToConstant: widthConst),
                poleImage.widthAnchor.constraint(equalToConstant: widthConst),
                poleImage.leadingAnchor.constraint(
                    equalTo: containerView.leadingAnchor,
                    constant: 2 * elemXConst + widthConst
                ),
                poleImage.topAnchor.constraint(
                    equalTo: containerView.centerYAnchor,
                    constant: 2 * elemYConst + widthConst
                )
            ]
        )
    }

    func layoutLables() {
        let heightConst = view.safeAreaLayoutGuide.layoutFrame.size.height / 16

        containerView.addConstraints(
            [
                locationLabel.heightAnchor.constraint(equalToConstant: 0.5 * heightConst),
                locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                curentWeatherLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor),
                curentWeatherLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                curentWeatherLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                curentWeatherLabel.heightAnchor.constraint(equalToConstant: 1.5 * heightConst),
                locationLabel.topAnchor.constraint(
                    equalTo: curentWeatherImage.bottomAnchor,
                    constant: 0.75 * heightConst
                ),
                popLabel.topAnchor.constraint(
                    equalTo: popImage.bottomAnchor,
                    constant: 5
                ),
                popLabel.leadingAnchor.constraint(
                    equalTo: popImage.leadingAnchor,
                    constant: -5
                ),
                popLabel.trailingAnchor.constraint(
                    equalTo: popImage.trailingAnchor,
                    constant: 5
                ),
                precipitationLable.topAnchor.constraint(
                    equalTo: precipitationImage.bottomAnchor,
                    constant: 5
                ),
                precipitationLable.leadingAnchor.constraint(
                    equalTo: precipitationImage.leadingAnchor,
                    constant: -15
                ),
                precipitationLable.trailingAnchor.constraint(
                    equalTo: precipitationImage.trailingAnchor,
                    constant: 15
                ),
                pressureLabel.topAnchor.constraint(
                    equalTo: pressureImage.bottomAnchor,
                    constant: 5
                ),
                pressureLabel.leadingAnchor.constraint(
                    equalTo: pressureImage.leadingAnchor,
                    constant: -15
                ),
                pressureLabel.trailingAnchor.constraint(
                    equalTo: pressureImage.trailingAnchor,
                    constant: 15
                ),
                windSpeedLabel.topAnchor.constraint(
                    equalTo: windSpeedImage.bottomAnchor,
                    constant: 5
                ),
                windSpeedLabel.leadingAnchor.constraint(
                    equalTo: windSpeedImage.leadingAnchor,
                    constant: -15
                ),
                windSpeedLabel.trailingAnchor.constraint(
                    equalTo: windSpeedImage.trailingAnchor,
                    constant: 15
                ),
                poleLabel.topAnchor.constraint(
                    equalTo: poleImage.bottomAnchor,
                    constant: 5
                ),
                poleLabel.leadingAnchor.constraint(equalTo: poleImage.leadingAnchor),
                poleLabel.trailingAnchor.constraint(equalTo: poleImage.trailingAnchor)
            ]
        )
    }

    func layoutButton() {
        let widthConst = view.safeAreaLayoutGuide.layoutFrame.size.width / 7
        let halfHeight = view.safeAreaLayoutGuide.layoutFrame.size.height / 2
        let elemYConst = (halfHeight - 2 * widthConst) / 4

        containerView.addConstraints(
            [
                shareButton.heightAnchor.constraint(equalToConstant: elemYConst),
                shareButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                shareButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                shareButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ]
        )
    }
}
