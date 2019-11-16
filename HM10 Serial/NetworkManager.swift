//
//  NetworkManager.swift
//  Serial
//
//  Created by 강수진 on 2019/10/15.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import Foundation
import Moya

struct NetworkManager: Networkable {
    static let sharedInstance = NetworkManager()
    let provider = MoyaProvider<CareGroundAPI>()
    private init() {
    }
}

extension NetworkManager {
    func login(id: String, pwd: String, fcmToken: String, completion: @escaping (Result<String, NetworkError>) -> ()) {
        fetchData(api: .login(id: id, pwd: pwd, fcmToken: fcmToken), networkData: LoginModel.self) { (result) in
            switch result {
            case .success(let successResult):
                completion(.success(successResult.resResult.token))
            case .failure(let errorType):
                switch errorType {
                case .networkConnectFail:
                    completion(.failure(.networkConnectFail))
                case .networkError(let errMessage):
                    completion(.failure(.networkError(with: errMessage)))
                case .decodeError:
                    completion(.failure(.decodeError))
                }
            }
        }
    }
    
    func getSensorData(completion: @escaping (Result<SensorDataModel, NetworkError>) -> ()) {
        fetchData(api: .getSensorData, networkData: SensorDataModel.self) { (result) in
            switch result {
            case .success(let successResult):
                completion(.success(successResult.resResult))
            case .failure(let errorType):
                switch errorType {
                case .networkConnectFail:
                    completion(.failure(.networkConnectFail))
                case .networkError(let errMessage):
                    completion(.failure(.networkError(with: errMessage)))
                case .decodeError:
                    completion(.failure(.decodeError))
                }
            }
        }
    }
    
    func sendSensorData(temperature: Double?, humidityPercent: Double?, CO: Int?, pm10: Int?,soilPercent: Int?, completion: @escaping (Result<String, NetworkError>) -> ()) {
        fetchData(api: .sendSensorData(temperature: temperature, humidityPercent: humidityPercent, CO: CO, pm10: pm10, soilPercent: soilPercent), networkData: DefaultModel.self) { (result) in
            switch result {
            case .success(let successResult):
                completion(.success(successResult.resResult.message))
            case .failure(let errorType):
                switch errorType {
                case .networkConnectFail:
                    completion(.failure(.networkConnectFail))
                case .networkError(let errMessage):
                    completion(.failure(.networkError(with: errMessage)))
                case .decodeError:
                    completion(.failure(.decodeError))
                }
            }
        }
    }
    func sendIamFine(completion: @escaping (Result<String, NetworkError>) -> ()) {
        fetchData(api: .sendIamFine, networkData: DefaultModel.self) { (result) in
            switch result {
            case .success(let successResult):
                completion(.success(successResult.resResult.message))
            case .failure(let errorType):
                switch errorType {
                case .networkConnectFail:
                    completion(.failure(.networkConnectFail))
                case .networkError(let errMessage):
                    completion(.failure(.networkError(with: errMessage)))
                case .decodeError:
                    completion(.failure(.decodeError))
                }
            }
        }
    }
}
