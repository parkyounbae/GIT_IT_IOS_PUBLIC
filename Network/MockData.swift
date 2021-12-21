//
//  MockData.swift
//  Git-it
//
//  Created by 정성훈 on 2021/06/01.
//

import Foundation

// MARK: - Test Data
extension GitItApi {
    var sampleData: Data {
        switch self {
        case .userData(let username):
            return Data(
                """
                {
                  "validtion": 1,
                  "userName": "\(username)",
                  "commitsRecord": [
                                {
                                    "date": "2021-05-05",
                                    "count": 3,
                                    "level": 1
                                },
                                {
                                    "date": "2021-05-06",
                                    "count": 5,
                                    "level": 2
                                }
                            ],
                  "profileImageUrl": "임시.url",
                  "streak": 30,
                "friendsList": ["jeong","seong"],
                }
                """.utf8
            )
        case .friendCommits(let friendName):
            return Data(
            """
            
              {
                "userName": "\(friendName)",
                "commitsRecord": [
                  {
                    "date": "2021-05-05",
                    "count": 3,
                    "level": 1
                  },
                  {
                    "date": "2021-05-06",
                    "count": 5,
                    "level": 2
                  }
                ],
                "totalCommits": 2
              }
            
            """.utf8
            )
        case .stats:
            return Data(
            """
            {
              "validation": 1,
                          "average": 3,
                          "streak": 40,
              "tier": "Silver",
              "totalCommits": 50
              
            }
            """.utf8
            )
        case .addUser:
            return Data(
                """
                {
                "result": 1
                }
                """.utf8)
        case .addFriend:
            return Data(
                """
                {
                "result": 1
                }
                """.utf8)
        case .deleteFriend:
            return Data(
                """
                {
                "result": 1
                }
                """.utf8)
        case .deleteUser(_):
            return Data(
                """
                {
                "result": 1
                }
                """.utf8)
        case .isExistUser(_):
            return Data(
                """
                {
                "result": 1
                }
                """.utf8)
        }
        
    }
}
