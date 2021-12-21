//
//  StatsViewController.swift
//  Git-it
//
//  Created by 서시언 on 2021/06/01.
//

import UIKit

class StatsViewController: UIViewController {
    // MARK: - property
    @IBOutlet var labelYourStats: UILabel!
    @IBOutlet var labelRankContent: UILabel!
    @IBOutlet var labelTotalCommitsContent: UILabel!
    @IBOutlet var labelAverageContent: UILabel!
    @IBOutlet var labelMaxCommitStreakContent: UILabel!
    
    @IBOutlet var tierImage: UIImageView!
    @IBOutlet var percentageLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var refreshButton: UIButton?
    var tmpStat: StatsData?
            
    // MARK: - override method
    override func viewDidLoad() {
        super.viewDidLoad()
        updateData()
        addLabelYourStats()
        addLabelRankContent()
        addLabelTotalCommitsContent()
        addLabelAverageContent()
        addLabelMaxCommitStreakContent()
        addRefreshButton()
        addPrograssBar()
        setAutoLayout()
        refreshStats()
    }
    
    // MARK: - UI setting mothod
    
    func updateData() {
        GitItApiProvider().fetchStatsData {result in
            switch result {
            case .success(let statsData):
                DispatchQueue.main.async {
                    print(statsData)
                    self.updateUI(statsData: statsData)
                }
            case .failure(let error):
                print("dd?")
                print(error.errorDescription!)
            }
        }
    }
    
    func updateUI(statsData: StatsData) {
        self.labelRankContent!.text = statsData.tier
        self.labelTotalCommitsContent!.text = String(statsData.totalCommits)
        self.labelAverageContent!.text = String(statsData.average)
        self.labelMaxCommitStreakContent!.text = String(statsData.streak)
        self.progressBar.progress = self.setPer(commitCount: statsData.totalCommits)
        self.percentageLabel.text = "다음 등급까지 \((1-self.setPer(commitCount: statsData.totalCommits))*100)%"
    }
    
    func addPrograssBar() {
        self.progressBar.progressViewStyle = .default
        self.progressBar.clipsToBounds = true
        self.progressBar.layer.cornerRadius = 10
        self.progressBar.clipsToBounds = true
        progressBar.layer.sublayers![1].cornerRadius = 8// 뒤에 있는 회색 track
        progressBar.subviews[1].clipsToBounds = true
        
    }
    
    func addLabelYourStats() {
        labelYourStats.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.largeTitle)
        // labelYourStats.textColor = UIColor.black
        labelYourStats.textAlignment = .center
        if let name = UserInfo.username {
            labelYourStats.text = "\(name)의 기록"
        } else {
            labelYourStats.text = "당신의 기록"
        }
        labelYourStats.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addLabelRankContent() {
            // labelRankContent.textColor = UIColor.darkGray
            labelRankContent.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addLabelTotalCommitsContent() {
            // labelTotalCommitsContent.textColor = UIColor.darkGray
            labelTotalCommitsContent.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addLabelAverageContent() {
            // labelAverageContent.textColor = UIColor.darkGray
            labelAverageContent.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addLabelMaxCommitStreakContent() {
            // labelMaxCommitStreakContent.textColor = UIColor.darkGray
            labelMaxCommitStreakContent.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addRefreshButton() {
        refreshButton = {btn in
            btn.translatesAutoresizingMaskIntoConstraints = false
            let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
            let largeBoldDoc = UIImage(systemName: "arrow.clockwise", withConfiguration: largeConfig)
            btn.setImage(largeBoldDoc, for: .normal)
            btn.addTarget(self, action: #selector(self.refreshStats), for: .touchUpInside)
            btn.contentMode = .scaleAspectFill
            btn.tintColor = UIColor.systemBlue
            return btn
        }(UIButton())
        
        if let btn = refreshButton {
            self.view.addSubview(btn)
        }
    }
    
    func setAutoLayout() {
        if let btn = refreshButton {
            btn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            btn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        }
    }
    
    func setPer(commitCount: Int) -> Float {
        if commitCount>=3000 {
            self.tierImage.image = UIImage(named: "challenger")
            return 1.0
        } else if commitCount>=1500 {
            self.tierImage.image = UIImage(named: "master")
            return Float(commitCount-1500)/1500
        } else if commitCount>=800 {
            self.tierImage.image = UIImage(named: "diamond")
            return Float(commitCount-800)/700
        } else if commitCount>=365 {
            self.tierImage.image = UIImage(named: "gold")
            return Float(commitCount-365)/435
        } else if commitCount>=150 {
            self.tierImage.image = UIImage(named: "silver")
            return Float(commitCount-150)/215
        } else if commitCount>=60 {
            self.tierImage.image = UIImage(named: "bronze")
            return Float(commitCount-60)/90
        } else {
            self.tierImage.image = UIImage(named: "iron")
            return Float(commitCount)/60
        }
    }
    
    // MARK: - objc method
    @objc func refreshStats() {
        GitItApiProvider().fetchStatsData { result in
            switch result {
            case .success(let statsData):
                
                DispatchQueue.main.async {
                    self.updateUI(statsData: statsData)

                }
               
            case .failure(let error):
                print(error.errorDescription!)
            }
        }
    }
}
