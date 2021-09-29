import Foundation
import UIKit

class List: UIViewController {

    enum Section: Hashable, CaseIterable {
        case sectionOne
        case sectionTwo
    }
    
    private lazy var collectionView = UICollectionView(
        frame: view.bounds,
        collectionViewLayout: UICollectionViewCompositionalLayout.list(
            using: UICollectionLayoutListConfiguration(appearance: .grouped)
        )
    )
    private lazy var dataSource = makeDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = dataSource
        collectionView.delegate = self

        // Build and apply the initial snapshot, as a NSDiffableDataSourceSnapshot - NOT as a set of NSDiffableDataSourceSectionSnapshots.
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        for section in Section.allCases {
            initialSnapshot.appendSections([section])
            initialSnapshot.appendItems([UUID(), UUID(), UUID()], toSection: section)
        }
        dataSource.apply(initialSnapshot, animatingDifferences: false)

        // Stick the collection view on screen
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0)
        ])
        
        let alert = UIAlertController(title: "Instructions", message: "To reproduce the bug, first reorder some cells in the second section, then reorder some cells in the first section.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, UUID> {
        return UICollectionView.CellRegistration { cell, _, listItem in
            var config = cell.defaultContentConfiguration()
            config.text = listItem.uuidString
            cell.accessories = [.reorder(displayed: .always)]
            cell.contentConfiguration = config
        }
    }

    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, UUID> {
        let cellRegistration = makeCellRegistration()
        let dataSource = UICollectionViewDiffableDataSource<Section, UUID>(collectionView: collectionView) { view, indexPath, item in
            view.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        dataSource.reorderingHandlers.canReorderItem = { _ in true }
        dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
            guard let self = self else { return }
            for section in transaction.sectionTransactions.map(\.sectionIdentifier) {
                let items = transaction.finalSnapshot.itemIdentifiers(inSection: section)

                DispatchQueue.main.async {
                    var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<UUID>()
                    sectionSnapshot.append(items)
                    self.dataSource.apply(sectionSnapshot, to: section)
                }
            }
        }
        
        return dataSource
    }
}

extension List: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt currentIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        
        // Force the reordering to be the same section
        if currentIndexPath.section == proposedIndexPath.section {
            return proposedIndexPath
        } else {
            return currentIndexPath
        }
    }
}
