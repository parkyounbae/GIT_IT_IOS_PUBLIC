//
//  CodableStructs.swift
//  Git-it
//
//  Created by 정성훈 on 2021/05/19.
//

import Foundation

// MARK: - Decodable
struct UserData: Decodable {
    var commitsRecord: [CommitsRecord]
    var friendList: [String]
    var profileImageUrl: String
    var streak: Int
    var userName: String
    var validation: Int
}

struct CommitsRecord: Decodable, Equatable {
    var count: Int
    var date: String
    var level: Int
}

struct FriendCommits: Decodable {
    var userName: String
    var commitsRecord: [CommitsRecord]
    var totalCommits: Int
}

struct StatsData: Decodable {
    var validation: Int
    var average: Float
    var streak: Int
    var tier: String
    var totalCommits: Int
}
