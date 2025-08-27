//
//  SignInViewController.swift
//  Coco
//
//  Created by Jackie Leonardy on 15/07/25.
//

import Foundation
import UIKit

final class SignInViewController: UIViewController {
    init(viewModel: SignInViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.actionDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onViewDidLoad()
        title = "Sign In"
    }
    
    override func loadView() {
        view = thisView
    }
    
    private let viewModel: SignInViewModelProtocol
    private let thisView: SignInView = SignInView()
    private var statusSignInVC: CocoStatusLabelHostingController?
}

extension SignInViewController: SignInViewModelAction {

    func configureView(
        emailInputVM: HomeSearchBarViewModel,
        passwordInputVM: CocoSecureInputTextFieldViewModel,
        rememberCheckBoxVM: CocoCheckBoxViewModel
        
    ) {
        let emailInputVC: HomeSearchBarHostingController = HomeSearchBarHostingController(viewModel: emailInputVM)
        addChild(emailInputVC)
        
        let passwordInputVC: SecureInputTextFieldController = SecureInputTextFieldController(viewModel: passwordInputVM)
        addChild(passwordInputVC)
        
        thisView.configureInputView(datas: [
            ("Email Address", emailInputVC.view),
            ("Password", passwordInputVC.view)
        ])
        
        emailInputVC.didMove(toParent: self)
        passwordInputVC.didMove(toParent: self)
       
        let rememberMeCheckboxVC: CocoCheckBoxHostingController = CocoCheckBoxHostingController(viewModel: rememberCheckBoxVM)
        addChild(rememberMeCheckboxVC)
        thisView.configureAddHorizontalElement(with: rememberMeCheckboxVC.view)
        rememberMeCheckboxVC.didMove(toParent: self)
        
        let forgotPasswordButtonVC: CocoButtonHostingController = CocoButtonHostingController(
            action: {},
            text: "Forgot Password?",
            style: .thin,
            type: .forgot
    )
        addChild(forgotPasswordButtonVC)
        thisView.configureAddHorizontalElement(with: forgotPasswordButtonVC.view)
        forgotPasswordButtonVC.didMove(toParent: self)
        
        // --- Yang ditambahkan ---
        
        statusSignInVC = CocoStatusLabelHostingController(
                   title: "",
                   style: .plain
               )
               
               if let statusVC = statusSignInVC {
                   addChild(statusVC)
                   thisView.addStatusLabel(with: statusVC.view)
                   statusVC.didMove(toParent: self)
                   statusVC.view.isHidden = true // Hide initially
               }
        
        let buttonHostingVC: CocoButtonHostingController = CocoButtonHostingController(
            action: { [weak self] in
                self?.viewModel.onSignInDidTap()
            },
            text: "Sign In",
            style: .large,
            type: .primary
        )
        addChild(buttonHostingVC)
        thisView.addActionButton(with: buttonHostingVC.view)
        buttonHostingVC.didMove(toParent: self)
    }

        func showStatusMessage(message: String, style: CocoStatusLabelStyle) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let statusVC = self.statusSignInVC else { return }
                
                // Update the status label with new message and style
                statusVC.updateTitle(message)
                statusVC.updateStyle(style)
                statusVC.view.isHidden = false
            }
        }
        
        func hideStatusMessage() {
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let statusVC = self.statusSignInVC else { return }
                statusVC.view.isHidden = true
            }
        }
}
