//
//  SocialViewFriendsTableViewCell.swift
//  Git-it
//
//  Created by 박윤배 on 2021/05/31.
//

import UIKit

class SocialViewFriendsTableViewCell: UITableViewCell {
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addUserNameLabel()
        addCommitsCountLabel()
        addGrassCollectionView()
        collectionViewCellFlowLayout()
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Property
    
    static let identifier = "SocialViewFriendsTableViewCell"
    var userNameLabel: UILabel?
    var grassCollectionView: GrassCollectionView?
    var commitsCount: UILabel?
    var currentDateIndex: Int {
        let numPerLine = 53
        let cal = Calendar(identifier: .gregorian)
        let now = Date()
        let comp = cal.dateComponents([.weekday], from: now)
        
        return ((numPerLine-1)*7 - 1) + comp.weekday!
    }
    
    var indexOfFriend: Int?
    var userName: String?
    var userCommitRecords: [CommitsRecord]?
    
    // MARK: - UIFunction
    
    func addUserNameLabel() {
        userNameLabel = { label in
            label.font = UIFont.boldSystemFont(ofSize: CGFloat(30))
            label.translatesAutoresizingMaskIntoConstraints = false
            label.adjustsFontSizeToFitWidth = true
            
            return label
        }(UILabel())
        
        if let label = userNameLabel {
            contentView.addSubview(label)
        }
    }
    
    func addCommitsCountLabel() {
        commitsCount = { label in
            label.font = UIFont.boldSystemFont(ofSize: CGFloat(15))
            label.adjustsFontSizeToFitWidth = true
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }(UILabel())
        
        if let label = commitsCount {
            contentView.addSubview(label)
        }
    }
    
    func addGrassCollectionView() {
        grassCollectionView = GrassCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        grassCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        grassCollectionView?.register(GrassCollectionViewCell.self, forCellWithReuseIdentifier: GrassCollectionViewCell.identifier)
        grassCollectionView?.delegate = self
        grassCollectionView?.dataSource = self
        grassCollectionView?.layer.masksToBounds = true
        grassCollectionView?.layer.cornerRadius = 5
                
        if let grass = grassCollectionView {
            contentView.addSubview(grass)
        }
    }
    
    func collectionViewCellFlowLayout() {
        let flowLayout: UICollectionViewFlowLayout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 2
        flowLayout.minimumLineSpacing = 2
        flowLayout.scrollDirection = .horizontal

        self.grassCollectionView?.collectionViewLayout = flowLayout
        
        DispatchQueue.main.async {
            self.grassCollectionView?.scrollToItem(at: IndexPath(item: self.currentDateIndex - 1, section: 0), at: .centeredHorizontally, animated: false)
            }
    }
    
    func setAutoLayout() {
        if let label = userNameLabel, let collectionView = grassCollectionView, let countLabel = commitsCount {
            label.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
            label.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
            
            countLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true
            countLabel.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
            countLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
            
            collectionView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
            collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
            collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10).isActive = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.gray.cgColor
        
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
    }
}

// MARK: - Extension

extension SocialViewFriendsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeOfCell = (collectionView.bounds.height - 22) / 7
            return CGSize(width: sizeOfCell, height: sizeOfCell)
        }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDateIndex + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: GrassCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: GrassCollectionViewCell.identifier, for: indexPath) as? GrassCollectionViewCell else {
            preconditionFailure("fail to load cell")
        }
        
        if let records = userCommitRecords {
            // cell.setColor(commitLevel: records[indexPath.item].level)
            if records.count > indexPath.item {
                cell.setColor(commitLevel: records[indexPath.item].level)
            } else {
                cell.setColor(commitLevel: 0)
            }
        } else {
            cell.setColor(commitLevel: 0)
        }

        return cell
    }
}
