//
//  HomeSearchBarView.swift
//  Coco
//
//  Created by Jackie Leonardy on 06/07/25.
//

import Foundation
import SwiftUI

struct HomeSearchBarView: View {
    @ObservedObject var viewModel: HomeSearchBarViewModel
    let onReturnKeyAction: (() -> Void)?
    let onClearAction: (() -> Void)?
    
    init(
        viewModel: HomeSearchBarViewModel, 
        onReturnKeyAction: (() -> Void)? = nil,
        onClearAction: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onReturnKeyAction = onReturnKeyAction
        self.onClearAction = onClearAction
    }
    
    var body: some View {
        let showClearButton = !viewModel.currentTypedText.isEmpty && viewModel.isTypeAble
        let trailingIcon: ImageHandler? = showClearButton ? 
            (image: CocoIcon.icCross.image, didTap: {
                viewModel.currentTypedText = ""
                onClearAction?()
            }) : viewModel.trailingIcon
        
        CocoInputTextField(
            leadingIcon: viewModel.leadingIcon,
            currentTypedText: $viewModel.currentTypedText,
            trailingIcon: trailingIcon,
            placeholder: viewModel.placeholderText,
            shouldInterceptFocus: !viewModel.isTypeAble,
            onFocusedAction: viewModel.onTextFieldFocusDidChange(to:),
            onReturnKeyAction: onReturnKeyAction
        )
    }
}

final class HomeSearchBarHostingController: UIHostingController<HomeSearchBarView> {
    init(viewModel: HomeSearchBarViewModel, onClearAction: (() -> Void)? = nil) {
        let view = HomeSearchBarView(viewModel: viewModel, onClearAction: onClearAction)
        super.init(rootView: view)
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
