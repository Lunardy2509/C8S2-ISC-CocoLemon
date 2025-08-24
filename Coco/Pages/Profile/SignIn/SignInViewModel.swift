//
//  SignInViewModel.swift
//  Coco
//
//  Created by Jackie Leonardy on 15/07/25.
//

import Foundation

final class SignInViewModel {
    weak var delegate: (any SignInViewModelDelegate)?
    weak var actionDelegate: (any SignInViewModelAction)?
    
    init(fetcher: SignInFetcherProtocol = SignInFetcher()) {
        self.fetcher = fetcher
    }

    private lazy var emailInputVM: HomeSearchBarViewModel = HomeSearchBarViewModel(
        leadingIcon: nil,
        placeholderText: "Enter your email address",
        currentTypedText: "",
        trailingIcon: nil,
        isTypeAble: true,
        delegate: nil
    )
    
    private lazy var passwordInputVM: CocoSecureInputTextFieldViewModel = CocoSecureInputTextFieldViewModel(
        leadingIcon: nil,
        placeholderText: "Enter your password",
        currentTypedText: ""
    )
    
    private lazy var rememberCheckBoxVM: CocoCheckBoxViewModel = CocoCheckBoxViewModel(
        label: "Remember Me",
        isChecked: false
    )
    
    private let fetcher: SignInFetcherProtocol
}

extension SignInViewModel: SignInViewModelProtocol {
    func onViewDidLoad() {
        actionDelegate?.configureView(
            emailInputVM: emailInputVM,
            passwordInputVM: passwordInputVM
            passwordInputVM: passwordInputVM,
            rememberCheckBoxVM: rememberCheckBoxVM
        )
    }
    
    func onSignInDidTap() {
        actionDelegate?.hideStatusMessage()
        
        // Validate input fields
        let email = emailInputVM.currentTypedText.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordInputVM.currentTypedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if email or password is empty
        if email.isEmpty || password.isEmpty {
            actionDelegate?.showStatusMessage(
                message: "Please fill out Email Address and Password",
                style: .failed
            )
            return
        }
        
        
        fetcher.signIn(
            spec: SignInSpec(
                email: emailInputVM.currentTypedText,
                password: passwordInputVM.currentTypedText
            )
        ) { [weak self] result in
            guard let self else { return }
            
            
            switch result {
            case .success(let success):
                
//                delegate?.notifySignInDidSuccess()
                
                self.actionDelegate?.hideStatusMessage()
                UserDefaults.standard.setValue(success.userId, forKey: "user-id")
                UserDefaults.standard.setValue(success.name, forKey: "user-name")
                UserDefaults.standard.setValue(success.email, forKey: "user-email")
                
                self.delegate?.notifySignInDidSuccess()
                
            case .failure(let failure):
                // Handle different NetworkServiceError cases
                let errorMessage: String
                
                switch failure {
                case .invalidURL, .bodyParsingFailed, .invalidResponse:
                    errorMessage = "Something went wrong. Please try again."
                    
                case .requestFailed(_):
                    errorMessage = "Network connection error. Please try again."
                    
                case .decodingFailed(_):
                    errorMessage = "Something went wrong. Please try again."
                    
                case .statusCode(let code):
                    switch code {
                    case 401, 403:
                        errorMessage = "Email or password Invalid"
                    case 500...599:
                        errorMessage = "Server error. Please try again later."
                    case 400, 422:
                        errorMessage = "Email or password Invalid"
                    default:
                        errorMessage = "Something went wrong. Please try again."
                    }
                    
                case .noInternetConnection:
                    errorMessage = "No internet connection. Please check your network."
                }
                
                self.actionDelegate?.showStatusMessage(
                    message: errorMessage,
                    style: .failed
                )
            }
        }
    }
}
