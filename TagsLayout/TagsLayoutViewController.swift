//
//  ViewController.swift
//  TagsLayout
//
//  Created by varunbhalla19 on 09/10/22.
//

import UIKit

class TagsLayoutViewController: UIViewController {

    fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, Tag.ID>
    fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Tag.ID>
    
    fileprivate lazy var dataSource: DataSource = {
        DataSource.init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.identifier, for: indexPath) as! TagCell
            let tag = Tag.tag(for: itemIdentifier)
            cell.label.text = tag.title
            return cell
        }
    }()
    
    lazy var tags = Tag.tags
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView.init(frame: view.bounds, collectionViewLayout: getLayout())
        view.delegate = self
        view.backgroundColor = .systemBackground
        view.register(TagCell.self, forCellWithReuseIdentifier: TagCell.identifier)
        return view
    }()
    
    private func getLayout() -> UICollectionViewCompositionalLayout {
        let spacing: CGFloat = 8
        let size: CGFloat = 20
        let item = NSCollectionLayoutItem.init(
            layoutSize: .init(widthDimension: .estimated(size),
                              heightDimension: .estimated(size)))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .estimated(size)), subitems: [item])
        group.interItemSpacing = .fixed(spacing)
        let section = NSCollectionLayoutSection.init(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = .init(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        
        return .init(section: section)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.fitIn(view)
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = Snapshot.init()
        snapshot.appendSections([Section.one])
        snapshot.appendItems(tags.map({ $0.id }))
        dataSource.apply(snapshot, animatingDifferences: true)
    }

}

extension TagsLayoutViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let id = dataSource.itemIdentifier(for: indexPath) {
            let tag = Tag.tag(for: id)
            print("Pressed: \(tag.title)")
        }
    }
}


class TagCell: UICollectionViewCell {
    
    static let identifier = "TagCell"
    
    lazy var label: UILabel = {
        let view = UILabel.init()
        view.textColor = .white
        view.text = "Tag"
        view.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 8
        
        contentView.addSubview(label)
        label.fitIn(contentView, padding: .init(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension UIView {
    func fitIn(_ view: UIView, padding: UIEdgeInsets = .zero) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.bottom),
            topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top)
        ])
    }
}
