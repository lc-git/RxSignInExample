//
//  GithubAPI.swift
//  RxSignInSignUpExample
//
//  Created by Chao Li on 9/27/16.
//  Copyright © 2016 ERStone. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Alamofire

let GithubAPIProvider = RxMoyaProvider<GithubAPI>(endpointClosure: endpointClosure)

enum GithubAPI {
    case SignIn(username: String, password: String)
}

extension GithubAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var path: String {
        switch self {
        case .SignIn:
            return "/authorizations"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .SignIn:
            return .POST
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .SignIn:
            return ["scopes": ["public_repo", "user"], "note": "RxSignInSignUp_demo (\(Date()))"]
        }
    }
    
    var sampleData: Data {
        switch self {
        case .SignIn:
            return "Sample data".data(using: String.Encoding.utf8)!
        }
    }
    
    var task: Task {
        return .request
    }
}

var endpointClosure = { (target: GithubAPI) -> Endpoint<GithubAPI> in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    let endpoint: Endpoint<GithubAPI> = Endpoint(URL: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters)
    switch target {
    case .SignIn(let username, let password):
        let credentialData = "\(username):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        return endpoint.endpointByAddingHTTPHeaderFields(["Authorization": "Basic \(base64Credentials)"])
            .endpointByAddingParameterEncoding(JSONEncoding.default)
    }
}







