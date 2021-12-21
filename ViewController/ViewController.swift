//
//  ViewController.swift
//  Git-it
//
//  Created by 정성훈 on 2021/05/02.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        print("이 줄은 스쿼시를 위한 임시 줄입니다.")
    }

    private func setUI() {
        let button: UIButton = { btn in
            btn.setTitle("임시버튼", for: .normal)
            btn.setTitleColor(.systemBlue, for: .normal)
            btn.translatesAutoresizingMaskIntoConstraints = false
            return btn
        }(UIButton(type: .system))
        self.view.addSubview(button)
        
        button.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        button.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    }

}
