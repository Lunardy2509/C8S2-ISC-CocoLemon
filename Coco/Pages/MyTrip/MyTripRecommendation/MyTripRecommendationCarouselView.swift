//
//  MyTripRecommendationCarouselView.swift
//  Coco
//
//  Created by Ferdinand Lunardy on 24/08/25.
//

import UIKit

protocol MyTripRecommendationCarouselViewDelegate: AnyObject {
    func didTapRecommendationItem(_ recommendation: MyTripRecommendationDataModel)
}

final class MyTripRecommendationCarouselView: UIView {
    weak var delegate: MyTripRecommendationCarouselViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureRecommendations(_ recommendations: [MyTripRecommendationDataModel]) {
        self.recommendations = recommendations
        updateRecommendationCollectionView()
    }
    
    private var recommendations: [MyTripRecommendationDataModel] = []
    
    // UI Components
    private lazy var titleLabel: UILabel = createTitleLabel()
    private lazy var recommendationsCollectionView: UICollectionView = createRecommendationsCollectionView()
    private var recommendationsDataSource: UICollectionViewDiffableDataSource<Int, MyTripRecommendationDataModel>?
    
    private func setupView() {
        addSubviews([titleLabel, recommendationsCollectionView])
        
        titleLabel.layout {
            $0.top(to: topAnchor)
            $0.leading(to: leadingAnchor)
            $0.trailing(to: trailingAnchor)
        }
        
        recommendationsCollectionView.layout {
            $0.top(to: titleLabel.bottomAnchor, constant: 16)
            $0.leading(to: leadingAnchor, constant: -21)
            $0.trailing(to: trailingAnchor, constant: 21)
            $0.bottom(to: bottomAnchor)
            $0.height(318)
        }
        
        configureRecommendationsDataSource()
    }
    
    private func updateRecommendationCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, MyTripRecommendationDataModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(recommendations, toSection: 0)
        recommendationsDataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UI Creation
private extension MyTripRecommendationCarouselView {
    func createTitleLabel() -> UILabel {
        let label = UILabel(
            font: .jakartaSans(forTextStyle: .title3, weight: .semibold),
            textColor: Token.additionalColorsBlack,
            numberOfLines: 1
        )
        label.text = "Place Recommendation"
        return label
    }
    
    func createRecommendationsCollectionView() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 238, height: 318)
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        
        return collectionView
    }
    
    func configureRecommendationsDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MyTripRecommendationCollectionCell, MyTripRecommendationDataModel> { cell, _, item in
            cell.configure(with: item)
        }
        
        recommendationsDataSource = UICollectionViewDiffableDataSource<Int, MyTripRecommendationDataModel>(
            collectionView: recommendationsCollectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
}

// MARK: - UICollectionViewDelegate
extension MyTripRecommendationCarouselView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < recommendations.count else { return }
        let recommendation = recommendations[indexPath.item]
        delegate?.didTapRecommendationItem(recommendation)
    }
}
