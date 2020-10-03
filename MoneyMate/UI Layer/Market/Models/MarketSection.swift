//
//  MarketSection.swift
//  MoneyMate
//
//  Created by Luboslav  Ivanov on 3.10.20.
//  Copyright © 2020 Luboslav  Ivanov. All rights reserved.
//

import Foundation

struct MarketSection: Codable {
    var title: String
    var items: [MarketItemModel]
}
