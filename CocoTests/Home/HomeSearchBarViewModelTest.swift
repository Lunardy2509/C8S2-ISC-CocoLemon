//
//  HomeSearchBarViewModelTest.swift
//  CocoTests
//
//  Created by Ferdinand Lunardy on 27/08/25.
//

import Foundation
import Testing
import SwiftUI
@testable import Coco

struct HomeSearchBarViewModelTest {
    
    // MARK: - Test Context Setup
    private struct TestContext {
        let viewModel: HomeSearchBarViewModel
        let mockDelegate: MockHomeSearchBarViewModelDelegate
        
        static func setup() -> TestContext {
            // --- GIVEN ---
            let mockDelegate = MockHomeSearchBarViewModelDelegate()
            let leadingIcon = UIImage(systemName: "magnifyingglass")
            let trailingIcon: ImageHandler? = UIImage(systemName: "slider.horizontal.3").map { image in
                (image: image, didTap: { })
            }
            
            let viewModel = HomeSearchBarViewModel(
                leadingIcon: leadingIcon,
                placeholderText: "Search...",
                currentTypedText: "",
                trailingIcon: trailingIcon,
                isTypeAble: false,
                delegate: mockDelegate
            )
            
            return TestContext(
                viewModel: viewModel,
                mockDelegate: mockDelegate
            )
        }
        
        static func setupTypeableSearchBar() -> TestContext {
            // --- GIVEN ---
            let mockDelegate = MockHomeSearchBarViewModelDelegate()
            let leadingIcon = UIImage(systemName: "magnifyingglass")
            
            let viewModel = HomeSearchBarViewModel(
                leadingIcon: leadingIcon,
                placeholderText: "Type to search...",
                currentTypedText: "initial text",
                trailingIcon: nil,
                isTypeAble: true,
                delegate: mockDelegate
            )
            
            return TestContext(
                viewModel: viewModel,
                mockDelegate: mockDelegate
            )
        }
    }
    
    // MARK: - Mock Delegate
    private class MockHomeSearchBarViewModelDelegate: HomeSearchBarViewModelDelegate {
        var invokedNotifyHomeSearchBarDidTap = false
        var invokedNotifyHomeSearchBarDidTapCount = 0
        var invokedNotifyHomeSearchBarDidTapParameters: (isTypeAble: Bool, viewModel: HomeSearchBarViewModel)?
        var invokedNotifyHomeSearchBarDidTapParametersList = [(isTypeAble: Bool, viewModel: HomeSearchBarViewModel)]()
        
        func notifyHomeSearchBarDidTap(isTypeAble: Bool, viewModel: HomeSearchBarViewModel) {
            invokedNotifyHomeSearchBarDidTap = true
            invokedNotifyHomeSearchBarDidTapCount += 1
            invokedNotifyHomeSearchBarDidTapParameters = (isTypeAble, viewModel)
            invokedNotifyHomeSearchBarDidTapParametersList.append((isTypeAble, viewModel))
        }
    }
    
    // MARK: - Initialization Tests
    @Test("initialization - should set up correctly with provided parameters")
    func initialization_withProvidedParameters_shouldSetupCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        let viewModel = context.viewModel
        
        // --- THEN ---
        #expect(viewModel.placeholderText == "Search...")
        #expect(viewModel.currentTypedText == "")
        #expect(viewModel.isTypeAble == false)
        #expect(viewModel.leadingIcon != nil)
        #expect(viewModel.trailingIcon != nil)
    }
    
    @Test("initialization - should set up typeable search bar correctly")
    func initialization_withTypeableParameters_shouldSetupCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setupTypeableSearchBar()
        
        // --- WHEN ---
        let viewModel = context.viewModel
        
        // --- THEN ---
        #expect(viewModel.placeholderText == "Type to search...")
        #expect(viewModel.currentTypedText == "initial text")
        #expect(viewModel.isTypeAble == true)
        #expect(viewModel.leadingIcon != nil)
        #expect(viewModel.trailingIcon == nil)
    }
    
    // MARK: - Text Field Focus Change Tests
    @Test("text field focus - should notify delegate when focus becomes true")
    func textFieldFocus_whenFocusBecomesTrue_shouldNotifyDelegate() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onTextFieldFocusDidChange(to: true)
        
        // --- THEN ---
        #expect(context.mockDelegate.invokedNotifyHomeSearchBarDidTap == true)
        #expect(context.mockDelegate.invokedNotifyHomeSearchBarDidTapCount == 1)
        #expect(context.mockDelegate.invokedNotifyHomeSearchBarDidTapParameters?.isTypeAble == false)
    }
    
    @Test("text field focus - should not notify delegate when focus becomes false")
    func textFieldFocus_whenFocusBecomesFalse_shouldNotNotifyDelegate() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onTextFieldFocusDidChange(to: false)
        
        // --- THEN ---
        #expect(context.mockDelegate.invokedNotifyHomeSearchBarDidTap == false)
        #expect(context.mockDelegate.invokedNotifyHomeSearchBarDidTapCount == 0)
    }
    
    @Test("text field focus - should pass correct isTypeAble value to delegate")
    func textFieldFocus_whenNotified_shouldPassCorrectIsTypeAbleValue() async throws {
        // --- GIVEN ---
        let context = TestContext.setupTypeableSearchBar()
        
        // --- WHEN ---
        context.viewModel.onTextFieldFocusDidChange(to: true)
        
        // --- THEN ---
        #expect(context.mockDelegate.invokedNotifyHomeSearchBarDidTap == true)
        #expect(context.mockDelegate.invokedNotifyHomeSearchBarDidTapParameters?.isTypeAble == true)
    }
    
    @Test("text field focus - should pass correct viewModel reference to delegate")
    func textFieldFocus_whenNotified_shouldPassCorrectViewModelReference() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onTextFieldFocusDidChange(to: true)
        
        // --- THEN ---
        #expect(context.mockDelegate.invokedNotifyHomeSearchBarDidTap == true)
        #expect(context.mockDelegate.invokedNotifyHomeSearchBarDidTapParameters?.viewModel === context.viewModel)
    }
    
    // MARK: - Multiple Focus Change Tests
    @Test("text field focus - should handle multiple focus changes correctly")
    func textFieldFocus_withMultipleChanges_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        
        // --- WHEN ---
        context.viewModel.onTextFieldFocusDidChange(to: true)
        context.viewModel.onTextFieldFocusDidChange(to: false)
        context.viewModel.onTextFieldFocusDidChange(to: true)
        
        // --- THEN ---
        #expect(context.mockDelegate.invokedNotifyHomeSearchBarDidTapCount == 2) // Only true cases should trigger
        #expect(context.mockDelegate.invokedNotifyHomeSearchBarDidTapParametersList.count == 2)
        #expect(context.mockDelegate.invokedNotifyHomeSearchBarDidTapParametersList.allSatisfy { $0.isTypeAble == false })
    }
    
    // MARK: - Delegate Weak Reference Tests
    @Test("delegate reference - should handle nil delegate gracefully")
    func delegateReference_whenNil_shouldHandleGracefully() async throws {
        // --- GIVEN ---
        let viewModel = HomeSearchBarViewModel(
            leadingIcon: nil,
            placeholderText: "Test",
            currentTypedText: "",
            trailingIcon: nil,
            isTypeAble: true,
            delegate: nil
        )
        
        // --- WHEN ---
        viewModel.onTextFieldFocusDidChange(to: true)
        
        // --- THEN ---
        // Should not crash and complete successfully
        #expect(viewModel.delegate == nil)
    }
    
    // MARK: - Published Property Tests
    @Test("published properties - should allow currentTypedText to be modified")
    func publishedProperties_currentTypedText_shouldAllowModification() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let initialText = context.viewModel.currentTypedText
        
        // --- WHEN ---
        context.viewModel.currentTypedText = "new search text"
        
        // --- THEN ---
        #expect(initialText == "")
        #expect(context.viewModel.currentTypedText == "new search text")
    }
    
    // MARK: - Property Immutability Tests
    @Test("property immutability - should maintain immutable properties")
    func propertyImmutability_shouldMaintainImmutableProperties() async throws {
        // --- GIVEN ---
        let context = TestContext.setup()
        let originalPlaceholder = context.viewModel.placeholderText
        let originalIsTypeAble = context.viewModel.isTypeAble
        
        // --- WHEN ---
        // These properties should be immutable after initialization
        
        // --- THEN ---
        #expect(context.viewModel.placeholderText == originalPlaceholder)
        #expect(context.viewModel.isTypeAble == originalIsTypeAble)
        #expect(context.viewModel.placeholderText == "Search...")
        #expect(context.viewModel.isTypeAble == false)
    }
    
    // MARK: - Icon Configuration Tests
    @Test("icon configuration - should handle different icon combinations")
    func iconConfiguration_withDifferentCombinations_shouldHandleCorrectly() async throws {
        // --- GIVEN ---
        let noIconsViewModel = HomeSearchBarViewModel(
            leadingIcon: nil,
            placeholderText: "No icons",
            currentTypedText: "",
            trailingIcon: nil,
            isTypeAble: true,
            delegate: nil
        )
        
        let onlyLeadingIconViewModel = HomeSearchBarViewModel(
            leadingIcon: UIImage(systemName: "magnifyingglass"),
            placeholderText: "Leading only",
            currentTypedText: "",
            trailingIcon: nil,
            isTypeAble: true,
            delegate: nil
        )
        
        // --- WHEN & THEN ---
        #expect(noIconsViewModel.leadingIcon == nil)
        #expect(noIconsViewModel.trailingIcon == nil)
        
        #expect(onlyLeadingIconViewModel.leadingIcon != nil)
        #expect(onlyLeadingIconViewModel.trailingIcon == nil)
    }
}
