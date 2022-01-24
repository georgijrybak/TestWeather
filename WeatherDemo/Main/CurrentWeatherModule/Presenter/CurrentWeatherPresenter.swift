//
//  CurrentWeatherPresenter.swift
//  WeatherDemo
//
//  Created by Георгий Рыбак on 20.01.22.
//

import UIKit
import Network

protocol CurrentWeatherViewProtocol: AnyObject {
    func succesGettingData(model: CurrentWeatherViewModel)
    func checkedInternetConnection(connection: Bool)
    func present(activityVC: UIActivityViewController)
    func failureGettingData()
    func failureGettingLocation()
    func locationIsDisabled()
    func configureIndicator(animation: Bool)
}

protocol CurrentWeatherViewPresenterProtocol: AnyObject {
    init(view: CurrentWeatherViewProtocol, networkService: NetworkService)
    func getWeather()
    func share()
    var currentWeatherForView: CurrentWeatherViewModel? { get set }
    var location: Location? { get set }
}

class CurrentWeatherPresenter: CurrentWeatherViewPresenterProtocol {
    weak var view: CurrentWeatherViewProtocol?

    private var networkService = NetworkService()

    let locationService = LocationService()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()

    private var currentWeather: CurrentWeather?
    private var currentLocation: LocationApi?

    var currentWeatherForView: CurrentWeatherViewModel? = CurrentWeatherViewModel(
        location: "",
        tempWithDiscription: "",
        pop: "",
        precipitation: "",
        precipitationIcon: "",
        pressure: "",
        windSpeed: "",
        windDirection: "",
        icon: ""
    )

    var location: Location? {
        didSet {
            monitor.start(queue: queue)
        }
    }

    required init(view: CurrentWeatherViewProtocol, networkService: NetworkService) {
        self.view = view
        self.networkService = networkService
        self.locationService.delegate = self
        self.locationService.requestLocation()

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.getWeather()
                    self.view?.checkedInternetConnection(connection: true)
                }
                print("Internet connection is on.")
            } else {
                DispatchQueue.main.async {
                    self.view?.checkedInternetConnection(connection: false)
                }
                print("There's no internet connection.")
            }
        }
    }

    func getWeather() {
        self.view?.configureIndicator(animation: true)

        guard let location = location else { return }
        let group = DispatchGroup()
        group.enter()
        networkService.getWeather(
            for: LocationApi.self,
            location: location,
            request: .forecast
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let currentLocation):
                    self.currentLocation = currentLocation
                        group.leave()
                case .failure(let error):
                    print(error.localizedDescription)
                    group.notify(queue: .main) {
                        self.view?.failureGettingData()
                    }
                }
            }
        }
        group.enter()
        networkService.getWeather(
            for: CurrentWeather.self,
            location: location,
            request: .current
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let currentWeather):
                    self.currentWeather = currentWeather
                    group.leave()
                case .failure(let error):
                    print(error.localizedDescription)
                    group.notify(queue: .main) {
                        self.view?.failureGettingData()
                    }
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            guard let currentWeather = self.currentWeather else { return }
            guard let currentLocation = self.currentLocation else { return }
            self.view?.succesGettingData(
                model: self.configureViewModel(
                    currentWeather: currentWeather,
                    currentLocation: currentLocation
                )
            )
            self.view?.configureIndicator(animation: false)
            self.locationService.stopUpdatingLocation()
            self.monitor.cancel()
        }
    }

    private func configureViewModel(currentWeather: CurrentWeather, currentLocation: LocationApi) -> CurrentWeatherViewModel {
        let windDirection = degreeConverter(degree: currentWeather.current.windDeg)

        let precipitation = { ()-> [ String ] in
            var precipitation = [String]()
            if let snow = currentWeather.daily[0].snow {
                precipitation.append("\(snow)mm")
                precipitation.append("snow")
            } else if let rain = currentWeather.daily[0].rain {
                precipitation.append("\(rain)mm")
                precipitation.append("drop.fill")
            } else {
                precipitation = ["0", "drop.fill"]
            }
            return precipitation
        }()

        let currentWeatherForView = CurrentWeatherViewModel(
            location: "\(self.currentLocation?.city.name ?? "") \(self.currentLocation?.city.country ?? "")",
            tempWithDiscription:
                "\(Int(currentWeather.current.temp - 273))°C | \(currentWeather.current.weather[0].weatherDescription)",
            pop: "\(Int(currentWeather.daily[0].pop * 100))%",
            precipitation: precipitation[0],
            precipitationIcon: precipitation[1],
            pressure: "\(currentWeather.current.pressure)hPa",
            windSpeed: "\(currentWeather.current.windSpeed)m/s",
            windDirection: windDirection,
            icon: currentWeather.current.weather[0].icon
        )
        return currentWeatherForView
    }

    @objc func share() {
        guard let currentWeather = self.currentWeather else { return }
        guard let currentLocation = self.currentLocation else { return }

        let message = convertWeathreInText(weather:
            configureViewModel(
                currentWeather: currentWeather,
                currentLocation: currentLocation
            )
        )
        let objectsToShare = [message] as [Any]
        let activityVC = UIActivityViewController(
            activityItems: objectsToShare,
            applicationActivities: nil
        )
        self.view?.present(activityVC: activityVC)
    }
}

extension CurrentWeatherPresenter: LocationServiceDelegate {
    func locationIsDisabled() {
        self.view?.locationIsDisabled()
    }

    func didUpdateLocation(location: Location) {
        self.location = location
    }

    func didntUpdateLocation() {
        self.view?.failureGettingLocation()
    }
}
