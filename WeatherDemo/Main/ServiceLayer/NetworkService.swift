//
//  NetworkService.swift
//  WeatherDemo
//
//  Created by Георгий Рыбак on 20.01.22.
//

import Foundation

enum RequestType {
    case current
    case forecast
}

class NetworkService {
    func getWeather<T: Codable>(
        for: T.Type = T.self,
        location: Location,
        request: RequestType,
        completion: @escaping ((Result<T?, Error>) -> Void)
    )
    {
        var url: String

        switch request {
        case .current:
            url = getURLForCurrentWeatherRequest(location: location)
        case .forecast:
            url = getURLForForecastWeatherRequest(location: location)
        }

        guard let url = URL(string: url) else { return }

        URLSession.shared.dataTask(with: url) {data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                let obj = try JSONDecoder().decode(T.self, from: data!)
                completion(.success(obj))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private func getURLForForecastWeatherRequest(location: Location) -> String {
        let locationParams = "lat=\(location.lat)&lon=\(location.lon)"
        let apiParam = "&appid=e04a16f0973fee362374f4db77bba5c2"
        let url = "http://api.openweathermap.org/data/2.5/forecast?\(locationParams)\(apiParam)"
        return url
    }
    private func getURLForCurrentWeatherRequest(location: Location) -> String {
        let locationParams = "lat=\(location.lat)&lon=\(location.lon)"
        let exclude = "&exclude=hourly,minutely,alerts"
        let apiParam = "&appid=e04a16f0973fee362374f4db77bba5c2"
        let url = "http://api.openweathermap.org/data/2.5/onecall?\(locationParams)\(exclude)\(apiParam)"
        return url
    }
}
