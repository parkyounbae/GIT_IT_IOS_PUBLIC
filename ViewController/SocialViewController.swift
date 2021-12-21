//
//  SocialViewController.swift
//  Git-it
//
//  Created by 박윤배 on 2021/06/02.
//

import UIKit

class SocialViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate {

    // MARK: - Property
    
    var friendAddButton: UIButton?
    var friendsTableView: UITableView?
    var commitsSummary: [FriendCommits] = []
    var tempFriendCommit: FriendCommits?
    let refershControl = UIRefreshControl()
    lazy var activityIndicator = UIActivityIndicatorView()
    private var action: UIAlertAction!
    private var friendIdTypedInAlert: String?
    
    var addFriendAlert = UIAlertController(title: "친구 추가", message: "깃 허브 아이디를 입력해주세요. \n 영문 및 숫자만 입력가능합니다.", preferredStyle: .alert)
    
    // MARK: - ViewLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        updateFriends()
        addTableView()
        addFriendAddButton()
        setAutoLayout()
        setAddFriendAlert()
        refershControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refershControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        friendsTableView?.addSubview(refershControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        var tempList: [FriendCommits] = []
        let loadDataGroup = DispatchGroup()
        
        for commitData in commitsSummary {
            loadDataGroup.enter()
            GitItApiProvider().fetchSocialCommitSummary(username: commitData.userName) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    tempList.append(data)
                }
                loadDataGroup.leave()
            }
        }
        
        loadDataGroup.notify(queue: .main) {
            self.refershControl.endRefreshing()
            tempList = tempList.sorted(by: {$0.totalCommits > $1.totalCommits})
            self.commitsSummary = tempList
            self.friendsTableView?.reloadData()
        }
    }
    
    // MARK: - UIFunction
    
    private func setAddFriendAlert() {
        activityIndicator = {
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.frame = addFriendAlert.view.bounds
            activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.large
            activityIndicator.stopAnimating()
            
            return activityIndicator
        }()
        
        addFriendAlert.addTextField { textField in
            let searchButton = UIButton()
            searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            searchButton.addTarget(self, action: #selector(self.isExistId), for: .touchUpInside)
            textField.rightView = searchButton
            textField.rightViewMode = .always
            textField.returnKeyType = .done
        }
        
        action = UIAlertAction(title: "추가", style: .default) { _ in
            guard self.addFriendAlert.textFields != nil else {
                preconditionFailure("fail to load textfield")
            }
            
            if let friendName = self.friendIdTypedInAlert {
                if !UserInfo.isTrial! {
                    self.addFriendSever(name: friendName)
                }
                UserInfo.friendList?.append(friendName)
            }
            
            self.updateFriends()
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
            print("cancel button clicked")
        }
        
        action.isEnabled = false
        addFriendAlert.view.addSubview(self.activityIndicator)
        addFriendAlert.addAction(action)
        addFriendAlert.addAction(cancel)
    }
    
    private func addFriendAddButton() {
        friendAddButton = { addButton in
            
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
            let largeBoldDoc = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)
            addButton.setImage(largeBoldDoc, for: .normal)
            addButton.tintColor = UIColor.systemBlue
            
            addButton.addTarget(self, action: #selector(touchUpAddButton(_:)), for: .touchUpInside)
            addButton.contentMode = UIView.ContentMode.scaleAspectFill
            
            addButton.translatesAutoresizingMaskIntoConstraints = false
            
            return addButton
        }(UIButton())
        
        if let addButton = friendAddButton {
            self.view.addSubview(addButton)
        }
    }
    
    private func addTableView() {
        friendsTableView = { tableView in
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.dataSource = self
            tableView.register(SocialViewFriendsTableViewCell.self, forCellReuseIdentifier: SocialViewFriendsTableViewCell.identifier)
            
            tableView.rowHeight = CGFloat(220)
            tableView.estimatedRowHeight = CGFloat(220)
            tableView.separatorStyle = .none
            tableView.allowsSelection = false
            
            return tableView
        }(UITableView())
        
        if let tableView = friendsTableView {
            self.view.addSubview(tableView)
        }
    }
    
    // MARK: - Function
    
    func updateFriends() {
        let loadDataGroup = DispatchGroup()
        self.commitsSummary = []
        
        loadDataGroup.enter()
        GitItApiProvider().fetchSocialCommitSummary(username: UserInfo.username!) {result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                self.commitsSummary.append(data)
            }
            loadDataGroup.leave()
        }
        
        if let friendList = UserInfo.friendList {
            for friends in friendList {
                loadDataGroup.enter()
                GitItApiProvider().fetchSocialCommitSummary(username: friends) { result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let data):
                        self.commitsSummary.append(data)
                    }
                    loadDataGroup.leave()
                }
            }
        }
        
        loadDataGroup.notify(queue: .main) {
            self.commitsSummary = self.commitsSummary.sorted(by: {$0.totalCommits > $1.totalCommits})
            self.friendsTableView?.reloadData()
        }
    }
    
    func setAutoLayout() {
        if let tableView = friendsTableView, let addButton = friendAddButton {
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            
            addButton.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -10).isActive = true
            addButton.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -10).isActive = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commitsSummary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: SocialViewFriendsTableViewCell =  tableView.dequeueReusableCell(withIdentifier: SocialViewFriendsTableViewCell.identifier, for: indexPath) as? SocialViewFriendsTableViewCell else {
            preconditionFailure("fail to load cell")
        }
        
        cell.userName = self.commitsSummary[indexPath.row].userName
        cell.indexOfFriend = indexPath.row + 1
        cell.userCommitRecords = self.commitsSummary[indexPath.row].commitsRecord
        cell.userNameLabel?.text = "\(indexPath.row + 1). \(self.commitsSummary[indexPath.row].userName)"
        cell.commitsCount?.text = " : \(self.commitsSummary[indexPath.row].totalCommits)commits"
        
        cell.grassCollectionView?.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if self.commitsSummary[indexPath.row].userName == UserInfo.username {
                let alert = UIAlertController(title: "알림", message: "자기자신은 삭제할 수 없습니다.", preferredStyle: UIAlertController.Style.alert)
                let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                if !UserInfo.isTrial! {
                    self.deleteFriendServer(name: self.commitsSummary[indexPath.row].userName)
                }
                if let indexOfFriend = UserInfo.friendList?.firstIndex(of: self.commitsSummary[indexPath.row].userName) {
                    UserInfo.friendList?.remove(at: indexOfFriend)
                }
                updateFriends()
            }
        }
    }
    
    // MARK: - IBAction

    @IBAction func touchUpAddButton(_ sender: UIButton) {
        if let list = UserInfo.friendList {
            if list.count > 5 {
                let alert = UIAlertController(title: "알림", message: "친구는 최대 5명까지 추가 가능합니다.", preferredStyle: UIAlertController.Style.alert)
                let action = UIAlertAction(title: "확인", style: UIAlertAction.Style.default)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.friendIdTypedInAlert = ""
                self.action.isEnabled = false
                self.addFriendAlert.textFields![0].text = ""
                self.addFriendAlert.message = "깃 허브 아이디를 입력해주세요. \n 영문 및 숫자만 입력가능합니다."
                self.present(addFriendAlert, animated: true, completion: nil)
            }
        }
    }
    
    func deleteFriendServer(name: String) {
        DispatchQueue.main.async {
            GitItApiProvider().putDeleteFriend(username: name) { result in
                switch result {
                case .success(_):
                    print("friend deleted : \(name)")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func addFriendSever(name: String) {
        DispatchQueue.main.async {
            GitItApiProvider().postAddFriend(username: name) { result in
                switch result {
                case .success(_):
                    print("friend added : \(name)")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    @objc private func textFieldDidChange(_ field: UITextField) {
        field.text = self.removeSpecialChar(text: field.text ?? "")
        self.friendIdTypedInAlert = field.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func removeSpecialChar(text: String) -> String {
        let okayChar: Set<Character> = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        
        return String(text.filter {okayChar.contains($0)})
    }
    
    @objc func isExistId(sender: UIButton) {
        guard let friendId = self.friendIdTypedInAlert else {
            action.isEnabled = false
            return
        }
        
        if let list = UserInfo.friendList {
            let lowercasedList = list.map {$0.lowercased()}
            if lowercasedList.contains(friendId.lowercased()) {
                self.addFriendAlert.message = "이미 존재하는 친구입니다."
                return
            }
            
            if friendId.lowercased() == UserInfo.username?.lowercased() {
                self.addFriendAlert.message = "자기 자신은 추가할 수 없습니다."
                return
            }
        }
        
        self.activityIndicator.startAnimating()
        
        GitItApiProvider().getIsExistUser(name: friendId) { result in
            switch result {
            case .failure(let error):
                print(error)
                self.activityIndicator.stopAnimating()
                self.action.isEnabled = false
            case .success(let result):
                if result == 1 {
                    self.action.isEnabled = true
                    self.addFriendAlert.message = "추가 버튼을 눌러주세요."
                    self.activityIndicator.stopAnimating()
                } else {
                    self.action.isEnabled = false
                    self.activityIndicator.stopAnimating()
                    self.addFriendAlert.message = "존재하지 않는 아이디입니다."
                }
            }
        }
    }
}
