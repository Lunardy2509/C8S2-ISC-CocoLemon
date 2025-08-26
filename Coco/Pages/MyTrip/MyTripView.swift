//
//  MyTripView.swift
//  Coco
//
//  Created by Jackie Leonardy on 14/07/25.
//

import Foundation
import UIKit

protocol MyTripViewDelegate: AnyObject {
    func notifyTripListCardDidTap(at index: Int)
    func notifyTripListCardDidDelete(at index: Int)
    func notifyCreateTripDidTap()
}

final class MyTripView: UIView {
    weak var delegate: MyTripViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(datas: [MyTripListCardDataModel]) {
        if datas.isEmpty {
            showEmptyState()
        } else {
            showList(datas: datas)
        }
    }
    
    private lazy var contentStackView: UIStackView = createStackView()
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            image: UIImage(named: "emptyStateLogo"),
            caption: "No trips yet, let’s create your first one!",
            buttonTitle: "Create Trip"
        ) {
            [weak self] in
                    self?.delegate?.notifyCreateTripDidTap()
        }
        view.isHidden = true
        return view
    }()
}

private extension MyTripView {
    func setupView() {
        backgroundColor = Token.additionalColorsWhite
        
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.addSubviewAndLayout(contentStackView)
        contentStackView.layout {
            $0.widthAnchor(to: scrollView.widthAnchor)
        }
        
        addSubviewAndLayout(scrollView, insets: UIEdgeInsets(edges: 21.0))
        addSubviewAndLayout(emptyStateView, insets: .zero)
    }
    
    func showList(datas: [MyTripListCardDataModel]) {
        emptyStateView.isHidden = true
        contentStackView.isHidden = false
        
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        datas.enumerated().forEach { (index, data) in
            let view = MyTripListCardView()
            view.delegate = self
            view.configureView(dataModel: data, index: index)
            contentStackView.addArrangedSubview(view)
        }
    }
    
    func createStackView() -> UIStackView {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16.0
        
        return stackView
    }
    func showEmptyState() {
        contentStackView.isHidden = true
        emptyStateView.isHidden = false
    }
}

// MARK: - MyTripListCardViewDelegate
extension MyTripView: MyTripListCardViewDelegate {
    func notifyTripListCardDidTap(at index: Int) {
        delegate?.notifyTripListCardDidTap(at: index)
    }
}
