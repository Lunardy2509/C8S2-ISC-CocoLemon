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
    func notifyDestinationSelected(_ destination: TopDestinationCardDataModel)
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
        self.tripData = datas
        if datas.isEmpty {
            showEmptyState()
        } else {
            showList()
        }
    }
    
    func updateData(_ data: [MyTripListCardDataModel]) {
        self.tripData = data
        collectionView.reloadData()
        
        if data.isEmpty {
            showEmptyState()
        } else {
            showList()
        }
    }

    private var tripData: [MyTripListCardDataModel] = []
    private lazy var collectionView: UICollectionView = createCollectionView()
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView(
            image: UIImage(named: "emptyStateLogo"),
            caption: "No trips yet, let's create your first one!",
            primaryButtonTitle: "Create Trip",
            action: { [weak self] in
                self?.delegate?.notifyCreateTripDidTap()
            },
            onDestinationSelected: { [weak self] destination in
                self?.delegate?.notifyDestinationSelected(destination)
            }
        )
        view.isHidden = true
        return view
    }()
}

private extension MyTripView {
    func setupView() {
        backgroundColor = Token.additionalColorsWhite
        
        addSubviewAndLayout(collectionView, insets: UIEdgeInsets(edges: 21.0))
        addSubviewAndLayout(emptyStateView, insets: .zero)
    }
    
    func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16.0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MyTripCollectionViewCell.self, forCellWithReuseIdentifier: "MyTripCollectionViewCell")
        
        return collectionView
    }
    
    func showList() {
        emptyStateView.isHidden = true
        collectionView.isHidden = false
        collectionView.reloadData()
    }
    
    func showEmptyState() {
        collectionView.isHidden = true
        emptyStateView.isHidden = false
    }
}

// MARK: - UICollectionViewDataSource
extension MyTripView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tripData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyTripCollectionViewCell", for: indexPath) as? MyTripCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let data = tripData[indexPath.item]
        cell.configure(with: data, index: indexPath.item)
        cell.delegate = self
        
        // Add long press gesture for delete functionality
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressGesture)
        
        return cell
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            delegate?.notifyTripListCardDidDelete(at: indexPath.item)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyTripView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        // Calculate height based on your cell's content
        // This should match the height needed for your MyTripCollectionViewCell
        let height: CGFloat = 200 // Increased height to ensure visibility
        return CGSize(width: width, height: height)
    }
}

// MARK: - MyTripCollectionViewCellDelegate
extension MyTripView: MyTripCollectionViewCellDelegate {
    func notifyTripListCardDidTap(at index: Int) {
        delegate?.notifyTripListCardDidTap(at: index)
    }
    
    func notifyTripListCardDidDelete(at index: Int) {
        delegate?.notifyTripListCardDidDelete(at: index)
    }
}
