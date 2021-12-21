//
//  LoginViewController.swift
//  Git-it
//
//  Created by 서시언 on 2021/05/13.
//

import UIKit
import Alamofire
import KeychainSwift
import SafariServices
import AuthenticationServices

class LoginViewController: UIViewController, UITextFieldDelegate { 
    
    static let shared = LoginViewController()
    private let clientId = "clientID"
    private let clientSecret = "secretcode"
    private var session: ASWebAuthenticationSession?
    
    private func authTokenWithWebLogin() {
        let scope = "user"
        let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientId)&scope=\(scope)")
        let callbackURLScheme = "gitit"
        
        self.session = ASWebAuthenticationSession(url: authURL!, callbackURLScheme: callbackURLScheme, completionHandler: { (callback: URL?, error: Error?) in
            guard error == nil, let successURL = callback else { return }
            print(successURL)
            if successURL.absoluteString.starts(with: "gitit://") {
                if let code = successURL.absoluteString.split(separator: "=").last.map({ String($0) }) {
                    LoginViewController.shared.requestAccessToken(with: code)
                }
            }
        })
        
        self.session?.prefersEphemeralWebBrowserSession = true
        self.session?.presentationContextProvider = self
        self.session?.start()
    }
    
    func requestAccessToken(with code: String) {
        let url = "https://github.com/login/oauth/access_token"
        
        let parameters = ["client_id": clientId,
                          "client_secret": clientSecret,
                          "code": code]
        
        let headers: HTTPHeaders = ["Accept": "application/json"]
        
        AF.request(url, method: .post, parameters: parameters, headers: headers).responseJSON { (response) in
            switch response.result {
            case let .success(json):
                if let dic = json as? [String: String] {
                    let accessToken = dic["access_token"] ?? ""
                    KeychainSwift().set(accessToken, forKey: "accessToken")
                    self.getUser()
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func logout() {
        KeychainSwift().clear()
    }
    
    // MARK: - property
    var labelUserName: UILabel?
    var buttonLogin: UIButton?
    var trialModeButton: UIButton?
    
    // MARK: - override method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLabelUsername()
        self.addBtnSubmit()
        self.addTrialModeButton()
        self.setAutoLayout()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - UI setting mothod
    func addLabelUsername() {
        labelUserName = {label in
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.boldSystemFont(ofSize: 100)
            label.text = "GIT-IT"
            return label
        }(UILabel())
        
        if let label = labelUserName {
            self.view.addSubview(label)
        }
    }
    
    func addBtnSubmit() {
        buttonLogin = {button in
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Login with GitHub", for: .normal)
            button.setImage(UIImage(named: "logo"), for: .normal)
            button.imageView?.translatesAutoresizingMaskIntoConstraints = false
            button.imageView?.contentMode = .scaleAspectFit
            button.imageView?.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.imageView?.widthAnchor.constraint(equalToConstant: 50).isActive = true
            button.imageView?.trailingAnchor.constraint(equalTo: button.titleLabel!.leadingAnchor).isActive = true
            button.setTitleColor(UIColor.white, for: .normal)
            button.titleLabel?.font = .boldSystemFont(ofSize: 12)
            button.contentHorizontalAlignment = .center
            button.backgroundColor = UIColor.black
            button.addTarget(self, action: #selector(touchUpBtnSubmit), for: UIControl.Event.touchUpInside)
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.white.cgColor
            
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 10
            
            return button
        }(UIButton())
        
        if let button = buttonLogin {
            self.view.addSubview(button)
        }
    }
    
    func addTrialModeButton() {
        trialModeButton = {button in
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("  trial mode  ", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 12)
            button.backgroundColor = UIColor.systemBlue
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 10
            button.addTarget(self, action: #selector(touchUpTrialButton), for: UIControl.Event.touchUpInside)
            
            return button
        }(UIButton())
        
        if let button = trialModeButton {
            self.view.addSubview(button)
        }
    }
    
    // MARK: - objc method
    @objc func touchUpBtnSubmit() {
        self.authTokenWithWebLogin()
    }
    
    @objc func touchUpTrialButton() {
        let trialModeAlert = UIAlertController(title: "Trial Mode", message: "체험모드 입니다.\n 현재 모드에서 추가한 친구는 저장되지 않습니다.\n 본인의 계정으로 로그인 하고싶으시면 로그아웃 후 이용해주세요.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            UserInfo.username = "eos-gitit"
            UserInfo.isTrial = true
            self.addUser()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        trialModeAlert.addAction(cancelAction)
        trialModeAlert.addAction(okAction)
        self.present(trialModeAlert, animated: true, completion: nil)
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
    
    // MARK: - method
    func addUser() {
        
        GitItApiProvider().postAddUser { result in
            switch result {
            case .success(_):
                UserInfo.loginSucces = true
                self.setInitialView()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func setAutoLayout() {
        if let label = self.labelUserName, let btn = self.buttonLogin, let trialBtn = trialModeButton {
            label.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 250).isActive = true
            
            btn.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15).isActive = true
            btn.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            btn.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
            btn.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            trialBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
            trialBtn.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        }
    }
    
    func getUser() {
        let url = "https://api.github.com/user"
        let accessToken = KeychainSwift().get("accessToken") ?? ""
        let headers: HTTPHeaders = ["Accept": "application/vnd.github.v3+json",
                                    "Authorization": "token \(accessToken)"]
        
        AF.request(url, method: .get, parameters: [:], headers: headers).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let json):
                if let jsonPrint: [String: Any] = json as? [String: Any] {
                    UserInfo.username = jsonPrint["login"] as? String
                    UserInfo.isTrial = false
                    self.addUser()
                }
            case .failure:
                print("here")
            }
        })
    }
    
    func setInitialView() {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let viewController = story.instantiateViewController(withIdentifier: "MainTabBar")
        UIApplication.shared.windows.first?.rootViewController = viewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}

extension LoginViewController: SFSafariViewControllerDelegate { }

extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
     func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
         return view.window!
     }
 }
