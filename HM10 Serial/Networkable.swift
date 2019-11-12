//
//  Networkable.swift
//  Serial
//
//  Created by 강수진 on 2019/10/15.
//  Copyright © 2019 Balancing Rock. All rights reserved.
//

import Moya
import SwiftyJSON

protocol Networkable {
    var provider: MoyaProvider<CareGroundAPI> { get }
    func login(id: String,
               pwd: String,
               fcmToken: String,
               completion: @escaping (Result<String, NetworkError>) -> ())
    func getSensorData(completion: @escaping (Result<SensorDataModel, NetworkError>) -> ())
    func sendSensorData(temperature: Double,
                        humidityPercent: Double,
                        CO: Int,
                        pm10: Int,
                        soilPercent: Int,
                        completion: @escaping (Result<String, NetworkError>) -> ())
    func sendIamFine(completion: @escaping (Result<String, NetworkError>) -> ())
}

extension Networkable {
    func fetchData<T: Codable>(api: CareGroundAPI, networkData: T.Type, completion: @escaping (Result<(resCode : Int, resResult : T), NetworkError>)->Void) {
        provider.request(api) { (result) in
            switch result {
            case let .success(res) :
                do {
                    print(JSON(res.data))
                    let resCode = res.statusCode
                    let data = try JSONDecoder().decode(T.self, from: res.data)
                    completion(.success((resCode, data)))
                } catch {
                    completion(.failure(.decodeError))
                }
            case let .failure(err) :
                if let error = err as NSError? {
                    if error.code == -1009 {
                        completion(.failure(.networkConnectFail))
                    } else {
                        do {
                            if let body = try err.response?.mapJSON(){
                                print(body)
                                let message = JSON(body)["message"]
                                completion(.failure(.networkError(with: message.description)))
                            }
                        } catch  {
                            completion(.failure(.networkError(with: "Network Error")))
                        }
                    }
                }
            }
        }
    }
}
