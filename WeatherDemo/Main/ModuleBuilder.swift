//
//  ModuleBilder.swift
//  WeatherDemo
//
//  Created by Георгий Рыбак on 20.01.22.
//

import UIKit

protocol Bulder {
    static func createCurrentWeatherModule() -> UIViewController
    static func createForecastWeatherModule() -> UIViewController
}

class ModulBuilder: Bulder {
    static func createCurrentWeatherModule() -> UIViewController {
        let view = CurrentWeatherViewController()
        let networkService = NetworkService()
        let presenter = CurrentWeatherPresenter(view: view, networkService: networkService)
        view.presenter = presenter
        return view
    }

    static func createForecastWeatherModule() -> UIViewController {
        let view = ForecastWeatherViewController()
        let networkService = NetworkService()
        let presenter = ForecastWeatherPresenter(view: view, networkService: networkService)
        view.presenter = presenter
        return view
    }
}
