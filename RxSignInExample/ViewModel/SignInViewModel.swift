//
//  SignInViewModel.swift
//  RxSignInSignUpExample
//
//  Created by Chao Li on 9/27/16.
//  Copyright © 2016 ERStone. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Validator

class SignInViewModel {
    let validatedUsername: Driver<ValidationResult>
    let validatedPassword: Driver<ValidationResult>
    
    let signInEnabled: Driver<Bool>
    let signingIn: Driver<Bool>
    let signedIn: Driver<Bool>
    
    init(
        input: (username: Driver<String>, password: Driver<String>, signInTap: Driver<Void>),
        dependency: (API: RxMoyaProvider<GithubAPI>, other: String)) {
        
        validatedUsername = input.username
            .map { usernameString in
                let usernameRule = ValidationRuleLength(min: 1, max: 100, failureError: ValidationError(message: "InValid Username"))
                return usernameString.validate(rule: usernameRule)
        }
        
        validatedPassword = input.password
            .map { passwordString in
                let passwordRule = ValidationRuleLength(min: 6, max: 100, failureError: ValidationError(message: "InValid Password"))
                return passwordString.validate(rule: passwordRule)
        }
        
        let signInIndicator = ActivityIndicator()
        signingIn = signInIndicator.asDriver()
        
        signInEnabled = Driver
            .combineLatest(validatedUsername, validatedPassword, self.signingIn) { username, password, signingIn in
                return username.isValid && password.isValid && !signingIn
            }
            .distinctUntilChanged()
        
        let usernameAndPassword = Driver.combineLatest(input.username, input.password) { ($0, $1) }
        signedIn = input.signInTap
            .withLatestFrom(usernameAndPassword)
            .flatMapLatest { (username, password) in
                return GithubAPIProvider
                    .request(GithubAPI.SignIn(username: username, password: password))
                    .filterSuccessfulStatusAndRedirectCodes()
                    .mapJSON()
                    .map { json in
                        print(json)
                        return true
                    }
                    .trackActivity(signInIndicator)
                    .asDriver(onErrorJustReturn: false)
            }
    }
}
