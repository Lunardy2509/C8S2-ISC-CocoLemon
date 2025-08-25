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
    let shouldAutoFocus: Bool
    
    @FocusState private var isTextFieldFocused: Bool
    
    init(
        viewModel: HomeSearchBarViewModel, 
        onReturnKeyAction: (() -> Void)? = nil,
        onClearAction: (() -> Void)? = nil,
        shouldAutoFocus: Bool = false
    ) {
        self.viewModel = viewModel
        self.onReturnKeyAction = onReturnKeyAction
        self.onClearAction = onClearAction
        self.shouldAutoFocus = shouldAutoFocus
    }
    
    var body: some View {
        let showClearButton = !viewModel.currentTypedText.isEmpty
        
        // Create custom search bar with both clear and filter buttons when needed
        HStack(alignment: .center, spacing: 8.0) {
            // Leading icon (search icon)
            if let leadingIcon = viewModel.leadingIcon {
                Image(uiImage: leadingIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18.0, height: 18.0)
            }
            
            // Text field area
            ZStack {
                GeometryReader { proxy in
                    TextField(viewModel.placeholderText, text: $viewModel.currentTypedText)
                        .focused($isTextFieldFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            onReturnKeyAction?()
                        }
                        .disabled(!viewModel.isTypeAble)
                        .font(.jakartaSans(forTextStyle: .body, weight: .medium))
                    
                    // Transparent layer to intercept taps when not typeable
                    if !viewModel.isTypeAble {
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: proxy.size.width, height: 52.0)
                            .onTapGesture {
                                viewModel.onTextFieldFocusDidChange(to: true)
                            }
                    } else {
                        // Even when typeable, add tap gesture to ensure focus
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: proxy.size.width, height: 52.0)
                            .onTapGesture {
                                isTextFieldFocused = true
                            }
                    }
                }
            }
            
            Spacer()
            
            // Trailing icons area
            HStack(spacing: 8.0) {
                if showClearButton {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10.0, height: 10.0)
                        .foregroundColor(Token.additionalColorsBlack.toColor())
                        .onTapGesture {
                            viewModel.currentTypedText = ""
                            onClearAction?()
                        }
                }
                
                if let filterIcon = viewModel.trailingIcon {
                    Rectangle()
                        .frame(width: 1.0, height: 18.0)
                        .foregroundStyle(Token.additionalColorsLine.toColor())
                    
                    Image(uiImage: filterIcon.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18.0, height: 18.0)
                        .onTapGesture {
                            filterIcon.didTap?()
                        }
                }
            }
        }
        .padding(.vertical, 14.0)
        .padding(.horizontal, 16.0)
        .background(Token.mainColorSecondary.toColor())
        .clipShape(Capsule(style: .continuous))
        .frame(height: 52.0)
        .onAppear {
            if shouldAutoFocus && viewModel.isTypeAble {
                // Use a small delay to ensure the view is fully rendered
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
        }
    }
}

final class HomeSearchBarHostingController: UIHostingController<HomeSearchBarView> {
    init(
        viewModel: HomeSearchBarViewModel, 
        onReturnKeyAction: (() -> Void)? = nil,
        onClearAction: (() -> Void)? = nil,
        shouldAutoFocus: Bool = false
    ) {
        let view = HomeSearchBarView(
            viewModel: viewModel, 
            onReturnKeyAction: onReturnKeyAction,
            onClearAction: onClearAction,
            shouldAutoFocus: shouldAutoFocus
        )
        super.init(rootView: view)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
