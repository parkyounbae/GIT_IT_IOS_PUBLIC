//
//  UserSettingViewController.swift
//  Git-it
//
//  Created by 박윤배 on 2021/05/16.
//

import UIKit
import Alamofire
import KeychainSwift

class UserSettingViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Property

    var userNameLabel: UILabel?
    var userProfileImage: UIImageView?
    var logoutButton: UIButton?
    var quitButton: UIButton?
    var leftCancelButton: UIBarButtonItem?
    var rightInfoButton: UIBarButtonItem?
    
    // MARK: - ViewLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addUserProfileImage()
        addUserNameLabel()
        addLogoutButton()
        addQuitButton()
        setLeftCancelButton()
        setRightInfoButton()
        self.navigationController?.delegate = self
        setAutoLayout()
    }
    
    // MARK: - UIFunction
    
    private func addUserNameLabel() {
        userNameLabel = { label in
            if let name = UserInfo.username {
                label.text = name
            } else {
                label.text = "error : no name"
            }
            label.font = label.font.withSize(33)
            label.textAlignment = .center
            // label.textColor = UIColor.black
            label.translatesAutoresizingMaskIntoConstraints = false
            
            return label
        }(UILabel())
        
        if let label = userNameLabel {
            self.view.addSubview(label)
        }
    }
    
    private func addUserProfileImage() {
        userProfileImage = { imageView in
            imageView.translatesAutoresizingMaskIntoConstraints = false
            guard let key = UserInfo.profileImageKey else {
                imageView.image = UIImage(named: "profile.png")
                return imageView
            }
            
            ImageCache.shared.load(url: key) { profileImage in
                imageView.image = profileImage
            }
            
            return imageView
        }(UIImageView())
        
        if let imgView = userProfileImage {
            self.view.addSubview(imgView)
        }
    }
    
    private func addQuitButton() {
        quitButton = { button in
            button.setTitle("QUIT", for: .normal)
            button.backgroundColor = UIColor.red
            button.layer.cornerRadius = 8
            button.addTarget(self, action: #selector(touchUpQuitButton(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }(UIButton())
        
        if let btn = quitButton {
            self.view.addSubview(btn)
        }
    }
    
    private func addLogoutButton() {
        logoutButton = { button in
            button.setTitle("LOGOUT", for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.backgroundColor = UIColor.gray
            button.layer.cornerRadius = 8
            button.addTarget(self, action: #selector(touchUpLogoutButton(_:)), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            return button
        }(UIButton())
        
        if let btn = logoutButton {
            self.view.addSubview(btn)
        }
    }
    
    private func setLeftCancelButton() {
        leftCancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(touchUpCancelButton(_:)))
        self.navigationItem.leftBarButtonItem = leftCancelButton
    }
    
    private func setRightInfoButton() {
        rightInfoButton = UIBarButtonItem(image: UIImage(systemName: "info.circle"), landscapeImagePhone: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(touchUpInfoButton(_:)))
        self.navigationItem.rightBarButtonItem = rightInfoButton
    }

    func setAutoLayout() {
        if let imageView = userProfileImage, let logoutBtn = logoutButton, let quitBtn = quitButton, let label = userNameLabel {
            
            // userProfileImage
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 165).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            
            // nameLable
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
            
            // doneButton
            logoutBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            logoutBtn.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 46).isActive = true
            logoutBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 86).isActive = true
            logoutBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -86).isActive = true
            
            // quitButton
            quitBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            quitBtn.topAnchor.constraint(equalTo: logoutBtn.bottomAnchor, constant: 20).isActive = true
            quitBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 86).isActive = true
            quitBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -86).isActive = true
        }
    }

    // MARK: - Function
    
    private func gotoMain() {
        navigationController?.popViewController(animated: true)
    }
    
    func setInitialView() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let viewController = story.instantiateViewController(withIdentifier: "LoginView")
        UIApplication.shared.windows.first?.rootViewController = viewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

    // MARK: - IBAction
    
    @IBAction func touchUpCancelButton(_ sender: UIButton) {
        gotoMain()
    }
    
    @IBAction func touchUpInfoButton(_ sender: UIButton) {
        if let infoVc = self.storyboard?.instantiateViewController(identifier: "appExplainView") {
            self.present(infoVc, animated: true, completion: nil)
        }
    }
    
    @IBAction func touchUpLogoutButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "예", style: .default) { _ in
            UserInfo.reset()
            KeychainSwift().clear()
            self.setInitialView()
            self.performSegue(withIdentifier: "unwindToLoginView", sender: self)
        }
        let cancelAction = UIAlertAction(title: "아니요", style: .destructive, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func touchUpQuitButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "탈퇴", message: "탈퇴 하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "예", style: .default) { _ in
            if UserInfo.isTrial! {
                self.setInitialView()
                UserInfo.reset()
                self.performSegue(withIdentifier: "unwindToLoginView", sender: self)
            } else {
                GitItApiProvider().deleteUser { result in
                    switch result {
                    case .success( _):
                        self.setInitialView()
                        UserInfo.reset()
                        KeychainSwift().clear()
                        self.performSegue(withIdentifier: "unwindToLoginView", sender: self)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "아니요", style: .destructive, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension UserSettingViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? HomeViewController {
            controller.updateUserData()
        }
    }
}
