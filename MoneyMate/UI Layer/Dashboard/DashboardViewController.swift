//
//  DashboardViewController.swift
//  MoneyMate
//
//  Created by Luboslav  Ivanov on 3.10.20.
//  Copyright © 2020 Luboslav  Ivanov. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var dateLabel: UIButton!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        moneyLabel.text = Double(GameDataStore.shared.account.money).moneyString
        dateLabel.setTitle(GameDataStore.shared.date.dashboardDataFormat, for: .normal)
        GameDataStore.shared.account.dummyNetWorth = GameDataStore.shared.account.netWorth
        let all = (GameDataStore.shared.ranking + [GameDataStore.shared.account])
            .sorted { $0.dummyNetWorth > $1.dummyNetWorth }
        let index = all.firstIndex { $0.names == GameDataStore.shared.account.names } ?? 0
        let rank = index + 1
        let rankStr: String
        if rank == 1 {
            rankStr = "1st"
        } else if rank == 2 {
            rankStr = "2nd"
        } else if rank == 3 {
            rankStr = "3rd"
        } else {
            rankStr = "\(rank)th"
        }
        rankLabel.text = "Rank\n\(rankStr)"
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidChange), name: .dataStoreWasUpdated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func onTapDebugDate(_ sender: Any) {
        GameDataStore.shared.send(.forwardTimeWith1Day)
    }
    
    @IBAction func onTapProfile(_ sender: Any) {
        let rankVC = LeaderboardViewController.instantiateFromStoryboard()
        present(rankVC, animated: true)
    }
}

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DashboardSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(of: DashboardSectionTableViewCell.self, for: indexPath),
              let dashboardSection = DashboardSection(rawValue: indexPath.row)
        else {
            fatalError("TableView could not dequeue MarketSectionTableViewCell or dashbord section is invalid for index path \(indexPath)")
        }
        
        cell.configure(with: dashboardSection)
        cell.onTapItem = { [unowned self] name, isQuest in
            if isQuest {
                let questVC = QuestDetailsViewController.instantiateFromStoryboard()
                if GameDataStore.shared.account.completedQuests.map({$0.name}).contains(name) {
                    questVC.buttonsConfig = .noButtons
                } else if let quest = GameDataStore.shared.account.ongoingQuests.first(where: { $0.name == name }) {
                    questVC.buttonsConfig = quest.isCompleted ? .collectReward : .noButtons
                } else {
                    questVC.buttonsConfig = .acceptAndDismiss
                }
                questVC.quest = GameDataStore.shared.quests.first { $0.name == name }
                questVC.delegate = self
                self.present(questVC, animated: true)
            } else {
                self.presentItemActionsSheetIfNeeded(forItemWithName: name)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let items = DashboardSection(rawValue: indexPath.row)?.itemViewModels, items.isEmpty {
            return 0.1
        }
        
        return 280
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}


private extension DashboardViewController {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 200 // TODO: Check which is perfect
//        tableView.rowHeight = 200// UITableView.automaticDimension
        tableView.register(cellType: DashboardSectionTableViewCell.self)
    }
    
    @objc func dataDidChange() {
        moneyLabel.text = Double(GameDataStore.shared.account.money).moneyString
        dateLabel.setTitle(GameDataStore.shared.date.dashboardDataFormat, for: .normal)
        var acc = GameDataStore.shared.account
        acc.dummyNetWorth = GameDataStore.shared.account.netWorth
        let all = (GameDataStore.shared.ranking + [acc])
            .sorted { $0.dummyNetWorth > $1.dummyNetWorth }
        let index = all.firstIndex { $0.names == acc.names } ?? 0
        let rank = index + 1
        let rankStr: String
        if rank == 1 {
            rankStr = "1st"
        } else if rank == 2 {
            rankStr = "2nd"
        } else if rank == 3 {
            rankStr = "3rd"
        } else {
            rankStr = "\(rank)th"
        }
        rankLabel.text = "Rank\n\(rankStr)"
        tableView.reloadData()
    }
}

extension DashboardViewController: QuestDetailsViewControllerDelegate {
    func collectReward(_ quest: QuestData) {
        GameDataStore.shared.send(.accomplishQuest(quest))
    }
    
    func acceptQuest(_ quest: QuestData) {
        GameDataStore.shared.send(.acceptQuest(quest))
    }
}
