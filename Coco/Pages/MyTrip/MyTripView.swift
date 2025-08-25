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
        self.tripData = datas
        updateCollectionView()
    }
    
    func configureRecommendations(recommendations: [MyTripRecommendationDataModel]) {
        self.recommendations = recommendations
        updateCollectionView()
    }
    
    private var tripData: [MyTripListCardDataModel] = []
    private var recommendations: [MyTripRecommendationDataModel] = []
    private lazy var collectionView: UICollectionView = createCollectionView()
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>?
    
    enum Section: Int, CaseIterable {
        case trips
        case empty
    }
}

private extension MyTripView {
    func setupView() {
        backgroundColor = Token.additionalColorsWhite
        addSubviewAndLayout(collectionView, insets: UIEdgeInsets(edges: 21.0))
        configureDataSource()
    }
    
    func createCollectionView() -> UICollectionView {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .trips:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(200)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(200)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 16
                return section
                
            case .empty:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                return section
            }
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        return collectionView
    }
    
    func configureDataSource() {
        let tripCellRegistration = UICollectionView.CellRegistration<MyTripCollectionViewCell, MyTripListCardDataModel> { [weak self] cell, indexPath, item in
            cell.configure(with: item, index: indexPath.item)
            cell.delegate = self
        }
        
        let emptyCellRegistration = UICollectionView.CellRegistration<MyTripNoTripYet, MyTripNoTripYetDataModel> { [weak self] cell, indexPath, item in
            // Pass recommendations to the empty state cell
            if let recommendations = self?.recommendations {
                cell.configureRecommendations(recommendations)
            }
            cell.delegate = self
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            switch item {
            case let tripItem as MyTripListCardDataModel:
                return collectionView.dequeueConfiguredReusableCell(
                    using: tripCellRegistration,
                    for: indexPath,
                    item: tripItem
                )
            case let emptyItem as MyTripNoTripYetDataModel:
                return collectionView.dequeueConfiguredReusableCell(
                    using: emptyCellRegistration,
                    for: indexPath,
                    item: emptyItem
                )
            default:
                return UICollectionViewCell()
            }
        }
    }
    
    func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        
        if tripData.isEmpty {
            snapshot.appendSections([.empty])
            snapshot.appendItems([MyTripNoTripYetDataModel()], toSection: .empty)
        } else {
            snapshot.appendSections([.trips])
            snapshot.appendItems(tripData, toSection: .trips)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        // Update recommendations for empty state cells after applying snapshot
        if tripData.isEmpty && !recommendations.isEmpty {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // Find and update the empty state cell with recommendations
                if let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? MyTripNoTripYet {
                    cell.configureRecommendations(self.recommendations)
                }
            }
        }
    }
}

extension MyTripView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.notifyTripListCardDidTap(at: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        // Only show context menu for trip cards, not empty state
        guard indexPath.section == Section.trips.rawValue else { return nil }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let deleteAction = UIAction(
                title: "Delete Trip",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self?.delegate?.notifyTripListCardDidDelete(at: indexPath.item)
            }
            
            return UIMenu(title: "", children: [deleteAction])
        }
    }
}

extension MyTripView: MyTripCollectionViewCellDelegate {
    func notifyTripListCardDidTap(at index: Int) {
        delegate?.notifyTripListCardDidTap(at: index)
    }
    
    func notifyTripListCardDidDelete(at index: Int) {
        delegate?.notifyTripListCardDidDelete(at: index)
    }
}

extension MyTripView: MyTripNoTripYetDelegate {
    func didTapRecommendationItem(_ recommendation: MyTripRecommendationDataModel) {
        // TODO: Handle recommendation tap
        print("Tapped recommendation: \(recommendation.title)")
    }
    
    func didTapCreateTrip() {
        delegate?.notifyCreateTripDidTap()
    }
}

// Extension to find parent view controller
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            parentResponder = responder.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
