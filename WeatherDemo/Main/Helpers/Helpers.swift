//
//  Helpers.swift
//  WeatherDemo
//
//  Created by Георгий Рыбак on 20.01.22.
//

import UIKit

func degreeConverter(degree: Int) -> String {
    switch degree {
    case 337...360, 0...22 :
        return "N"
    case 23...67:
        return "NE"
    case 68...112:
        return "E"
    case 113...157:
        return "SE"
    case 158...202:
        return "S"
    case 203...247:
        return "SW"
    case 248...292:
        return "W"
    case 293...336:
        return "NW"
    default:
        return "none"
    }
}

func delayWithSeconds(_ seconds: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

func getNoInternetView(frame: CGRect) -> UIView {
    let noIntrenetView = UIView(frame: frame)
    let label = UILabel()

    noIntrenetView.addSubview(label)

    label.frame = CGRect(x: 0, y: 0, width: noIntrenetView.frame.size.width, height: 100)
    label.center = noIntrenetView.center
    label.text = "No internet connection\n\nPlease turn WiFi or LTE on"
    label.numberOfLines = 0
    label.textAlignment = .center
    noIntrenetView.backgroundColor = UIColor(named: "secondaryBackground")

    return noIntrenetView
}

func convertWeathreInText(weather: CurrentWeatherViewModel) -> String {
    let message = """
        Current weather for \(weather.location):
        Outside the window: \(weather.tempWithDiscription)
        Pop: \(weather.pop)
        Precipitation: \(weather.precipitation)mm
        Pressure: \(weather.pressure)
        Wind speed: \(weather.windSpeed)
        Wind direction: \(weather.windDirection)
        """
    return message
}
