//
//  GrassCollectionViewCell.swift
//  Git-it
//
//  Created by 박윤배 on 2021/06/01.
//

import UIKit

class GrassCollectionView: UICollectionView {
    
}

class GrassCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let identifier = "grassCollectionViewCell"
    
    func setColor(commitLevel: Int) {
        switch commitLevel {
        case 0:
            self.backgroundColor = UIColor(displayP3Red: 235/255, green: 237/255, blue: 240/255, alpha: 1)
        case 1:
            self.backgroundColor = UIColor(displayP3Red: 172/255, green: 230/255, blue: 174/255, alpha: 1)
        case 2:
            self.backgroundColor = UIColor(displayP3Red: 105/255, green: 192/255, blue: 110/255, alpha: 1)
        case 3:
            self.backgroundColor = UIColor(displayP3Red: 83/255, green: 158/255, blue: 87/255, alpha: 1)
        case 4:
            self.backgroundColor = UIColor(displayP3Red: 56/255, green: 108/255, blue: 62/255, alpha: 1)
        default:
            self.backgroundColor = UIColor(displayP3Red: 235/255, green: 237/255, blue: 240/255, alpha: 1)
        }
    }
}
