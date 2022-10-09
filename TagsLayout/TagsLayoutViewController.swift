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
    
    lazy var gradientView: GradientView = {
        let view = GradientView.init()
        view.setup(with: [.clear, .purple], locations: [0, 2], start: .init(x: 0.5, y: 0), end: .init(x: 1, y: 1))
        return view
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl.init()
        control.addTarget(self, action: #selector(refreshTags), for: .valueChanged)
        return control
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView.init(frame: view.bounds, collectionViewLayout: getLayout())
        view.delegate = self
        view.refreshControl = refreshControl
        view.backgroundColor = .clear
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

        gradientView.layer.frame = view.frame
        view.layer.addSublayer(gradientView.layer)

        applySnapshot(with: tags.map{ $0.id })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientView.layer.frame = view.bounds
    }
    
    func applySnapshot(with ids: [Tag.ID]) {
        var snapshot = Snapshot.init()
        snapshot.appendSections([Section.one])
        snapshot.appendItems(ids)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @objc func refreshTags(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: .init {
            self.tags = Tag.tags
            self.applySnapshot(with: Tag.tags.map { $0.id })
            self.refreshControl.endRefreshing()
        })
    }
    
}

extension TagsLayoutViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let id = dataSource.itemIdentifier(for: indexPath) {
            tags = tags.filter { $0.id != id }
            applySnapshot(with: tags.map{ $0.id })
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
    
    lazy var gradientView = GradientView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        contentView.addSubview(gradientView)
        contentView.addSubview(label)

        gradientView.setup(
            with: [.systemIndigo, .purple], locations: [-0.5, 1.5], start: .zero, end: .init(x: 1, y: 1)
        )
        
        label.fitIn(contentView, padding: .init(top: 8, left: 8, bottom: 8, right: 8))
        gradientView.fitIn(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        didSet {
            let duration = isHighlighted ? 0.5 : 0.4
            let transform = isHighlighted ? CGAffineTransform.init(scaleX: 0.95, y: 0.95): .identity
            let alpha = isHighlighted ? 0.7 : 1
            UIView.animate(
                withDuration: duration, delay: .zero, usingSpringWithDamping: 1, initialSpringVelocity: .zero, options: [.allowUserInteraction, .beginFromCurrentState]) {
                    self.alpha = alpha
                    self.transform = transform
            }
        }
    }
    
}

class GradientView: UIView {
    
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    func setup (with colors: [UIColor], locations: [NSNumber]? = nil, start: CGPoint = .init(x: 0.5, y: 0), end: CGPoint = .init(x: 0.5, y: 1)) {
        guard let layer = layer as? CAGradientLayer else { return }
        layer.colors = colors.map { $0.cgColor }
        layer.locations = locations
        layer.startPoint = start
        layer.endPoint = end
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
