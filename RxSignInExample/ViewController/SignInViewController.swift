
//
//  SignInViewController.swift
//  RxSignInSignUpExample
//
//  Created by Chao Li on 9/27/16.
//  Copyright © 2016 ERStone. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import KRProgressHUD

class SignInViewController: UIViewController {
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signInActivityIndicator: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeTF()
        
        let viewModel = SignInViewModel(
            input: (username: usernameTF.rx.text.asDriver(), password: passwordTF.rx.text.asDriver(), signInTap: signInBtn.rx.tap.asDriver()),
            dependency: (API: GithubAPIProvider, other: "other dependency"))
        
        viewModel.signInEnabled
            .drive(onNext: { [weak self] valid in
                self?.signInBtn.alpha = valid ? 1.0 : 0.5
                self?.signInBtn.isEnabled = valid
                })
            .addDisposableTo(disposeBag)
        
        viewModel.signingIn
            .drive(signInActivityIndicator.rx.animating)
            .addDisposableTo(disposeBag)
        
        viewModel.signedIn
            .drive(onNext: { bool in
                bool ? KRProgressHUD.showSuccess() : KRProgressHUD.showError()
            })
            .addDisposableTo(disposeBag)
    }
}

extension SignInViewController {
    func customizeTF() {
        usernameTF.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        passwordTF.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
    }
}
