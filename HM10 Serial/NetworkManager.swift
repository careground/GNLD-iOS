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
    func login(id: String, pwd: String, completion: @escaping (Result<String, NetworkError>) -> ()) {
        fetchData(api: .login(id: id, pwd: pwd), networkData: SampleModel.self) { (result) in
            switch result {
            case .success(let successResult):
                guard let data = successResult.resResult.comments else {
                    return
                }
                completion(.success(data))
            case .failure(let errorType):
                switch errorType {
                case .networkConnectFail:
                    completion(.failure(.networkConnectFail))
                case .networkError:
                    completion(.failure(.networkError))
                case .decodeError:
                    completion(.failure(.decodeError))
                }
            }
        }
    }
    
    func getSensorData(completion: @escaping (Result<String, NetworkError>) -> ()) {
        fetchData(api: .getSensorData, networkData: SampleModel.self) { (result) in
            switch result {
            case .success(let successResult):
                guard let data = successResult.resResult.comments else {
                    return
                }
                completion(.success(data))
            case .failure(let errorType):
                switch errorType {
                case .networkConnectFail:
                    completion(.failure(.networkConnectFail))
                case .networkError:
                    completion(.failure(.networkError))
                case .decodeError:
                    completion(.failure(.decodeError))
                }
            }
        }
    }
    
    func sendSensorData(temperature: Double, humidity_per: Double, CO: Int, pm10: Int, pm2p5: Int, soil_per: Int, completion: @escaping (Result<String, NetworkError>) -> ()) {
        fetchData(api: .sendSensorData(temperature: temperature, humidity_per: humidity_per, CO: CO, pm10: pm10, pm2p5: pm2p5, soil_per: soil_per), networkData: SampleModel.self) { (result) in
            switch result {
            case .success(let successResult):
                guard let data = successResult.resResult.comments else {
                    return
                }
                completion(.success(data))
            case .failure(let errorType):
                switch errorType {
                case .networkConnectFail:
                    completion(.failure(.networkConnectFail))
                case .networkError:
                    completion(.failure(.networkError))
                case .decodeError:
                    completion(.failure(.decodeError))
                }
            }
        }
    }
}
