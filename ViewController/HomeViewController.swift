//
//  HomeViewController.swift
//  Git-it
//
//  Created by 박윤배 on 2021/06/11.
//

import UIKit
import Alamofire
import KeychainSwift

class HomeViewController: UIViewController {
    
    // MARK: - Property
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var settingButton: UIButton!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var todayCommitLabel: UILabel!
    @IBOutlet var todayCommitCountLabel: UILabel!
    @IBOutlet var commitStreakLabel: UILabel!
    @IBOutlet var commitStreakCountLabel: UILabel!
    @IBOutlet var grassCollectionView: GrassCollectionView!
    
    let refershControl = UIRefreshControl()
    var userData: UserData?
    var currentDateIndex: Int {
        let numPerLine = 53
        let cal = Calendar(identifier: .gregorian)
        let now = Date()
        let comp = cal.dateComponents([.weekday], from: now)
        
        return ((numPerLine-1)*7 - 1) + comp.weekday!
    }
    
    // MARK: - ViewLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateUserData()
        addSettingButton()
        addProfileImage()
        addUserNameLabel()
        addTodayCommitLabel()
        addCommitStreakLabel()
        addGrassCollectionView()
        
        refershControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refershControl.addTarget(self, action: #selector(self.touchUpRefreshButton(_:)), for: .valueChanged)
        scrollView.refreshControl = refershControl
        
        DispatchQueue.main.async {
            self.grassCollectionView.scrollToItem(at: IndexPath(item: self.currentDateIndex - 1, section: 0), at: .centeredHorizontally, animated: false)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchUpUsernameLabel(_:)))
        userNameLabel?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - UIFunction
    
    func addSettingButton() {
        settingButton.tintColor = UIColor.systemBlue
        settingButton.addTarget(self, action: #selector(touchUpSettingButton(_:)), for: .touchUpInside)
        settingButton.contentMode = UIView.ContentMode.scaleAspectFill
        settingButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addProfileImage() {
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        guard let key = UserInfo.profileImageKey else {
            // set default
            profileImage.image = UIImage(systemName: "person")
            return
        }
        ImageCache.shared.load(url: key) { profile in
            self.profileImage.image = profile
        }
    }
    
    func addUserNameLabel() {
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.adjustsFontSizeToFitWidth = true
        if let user = UserInfo.username {
            userNameLabel.text = user
            userNameLabel.isUserInteractionEnabled = false
        } else {
            userNameLabel.text = "submit username"
            userNameLabel.isUserInteractionEnabled = true
        }
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 30)
    }
    
    func addTodayCommitLabel() {
        todayCommitLabel.translatesAutoresizingMaskIntoConstraints = false
        todayCommitLabel.text = "Today's Commit"
        
        todayCommitCountLabel.translatesAutoresizingMaskIntoConstraints = false
        if let data = userData {
            todayCommitCountLabel.text = "\(data.commitsRecord.count)"
        } else {
            todayCommitCountLabel.text = "0"
        }
        todayCommitCountLabel.font = UIFont.boldSystemFont(ofSize: 40)
    }
    
    func addCommitStreakLabel() {
        commitStreakLabel.translatesAutoresizingMaskIntoConstraints = false
        commitStreakLabel.text = "Commit Streak"
    
        commitStreakCountLabel.translatesAutoresizingMaskIntoConstraints = false
        if let data = userData {
            commitStreakCountLabel.text = "\(data.streak) days"
        } else {
            commitStreakCountLabel.text = "0 days"
        }
        commitStreakCountLabel.font = UIFont.boldSystemFont(ofSize: 40)
    }
    
    func addGrassCollectionView() {
        grassCollectionView?.register(GrassCollectionViewCell.self, forCellWithReuseIdentifier: GrassCollectionViewCell.identifier)
        grassCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        grassCollectionView?.delegate = self
        grassCollectionView?.dataSource = self
        grassCollectionView?.backgroundColor = UIColor.white
        grassCollectionView.layer.borderWidth = 2
        grassCollectionView.layer.borderColor = UIColor.gray.cgColor
    }
    
    // MARK: - Function
    
    func updateUserData() {
        GitItApiProvider().fetchUserData { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let commitSummary):
                self.userData = commitSummary
                UserInfo.username = commitSummary.userName
                UserInfo.friendList = commitSummary.friendList
                UserInfo.profileImageKey = URL(string: commitSummary.profileImageUrl)
            
                DispatchQueue.main.async {
                    self.updateView()
                }
            }
        }
    }
    
    func updateView() {
        if let data = userData {
            if let name = userNameLabel, let todayCommit = todayCommitCountLabel, let commitStreak = commitStreakCountLabel, let grass = grassCollectionView {
                name.text = data.userName
                if let lastData = data.commitsRecord.last {
                    todayCommit.text = "\(lastData.count)"
                } else {
                    todayCommit.text = "0"
                }
                
                commitStreak.text = "\(data.streak) days"
                
                if data.profileImageUrl != UserInfo.profileImageKey?.absoluteString {
                    UserInfo.profileImageKey = URL(string: data.profileImageUrl)
                }
                if let imageView = profileImage {
                    if let key = UserInfo.profileImageKey {
                        ImageCache.shared.load(url: key) { profileImage in
                            imageView.image = profileImage
                        }
                    } else {
                        imageView.image = UIImage(named: "profile.png")
                    }
                }
                grass.reloadData()
                self.refershControl.endRefreshing()
            }
        }
    }
    
    // MARK: - IBAction func

    @IBAction func touchUpSettingButton(_ sender: UIButton) {
        if let settingVc = self.storyboard?.instantiateViewController(identifier: "SettingView") {
            self.navigationController?.pushViewController(settingVc, animated: true)
        }
    }
    
    @IBAction func touchUpUsernameLabel(_ sender: UITapGestureRecognizer) {
        if let settingVc = self.storyboard?.instantiateViewController(identifier: "SettingView") {
            self.navigationController?.pushViewController(settingVc, animated: true)
        }
    }
    
    @IBAction func touchUpRefreshButton(_ sender: UIButton) {
        updateUserData()
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeOfCell = (collectionView.bounds.height - 12) / 7
            return CGSize(width: sizeOfCell, height: sizeOfCell)
        }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDateIndex + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: GrassCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: GrassCollectionViewCell.identifier, for: indexPath) as? GrassCollectionViewCell else {
            preconditionFailure("fail to load cell")
        }
        
        if let records = userData {
            if records.commitsRecord.count > indexPath.item { // 4 , 01234
                cell.setColor(commitLevel: records.commitsRecord[indexPath.item].level)
            } else {
                cell.setColor(commitLevel: 0)
            }
            
        } else {
            cell.setColor(commitLevel: 0)
        }

        return cell
    }
}
