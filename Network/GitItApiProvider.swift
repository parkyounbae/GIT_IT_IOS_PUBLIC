//
//  CommitsApiProvider.swift
//  Git-it
//
//  Created by 정성훈 on 2021/05/18.
//

import Foundation
import Alamofire

enum ApiError: LocalizedError {
    case noUsernameError
    case noFriendListError
    case clientError(Error)
    case serverError(URLResponse?)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .noUsernameError: return "no username error"
        case .noFriendListError: return "no friendList error"
        case .clientError: return "client error"
        case .serverError: return "server error"
        case .unknownError: return "unknown error"
        }
    }
}

enum GitItApi {
    case userData(String)
    case friendCommits(String)
    case stats(String)
    case addUser
    case addFriend
    case deleteFriend
    case deleteUser(String)
    case isExistUser(String)
    
    static let baseUrl = "serverURL"
    
    var queryItem: String? {
        switch self {
        case .userData(let username): return "user/\(username)"
        case .friendCommits(let username): return "commit/\(username)"
        case .stats(let username): return "user/stats/\(username)"
        case .addUser: return "user"
        case .addFriend: return "user/friend/add"
        case .deleteFriend: return "user/friend/delete"
        case .deleteUser(let username): return "user/\(username)"
        case .isExistUser(let username): return "user/github/\(username)"
        }
    }
    
    var url: URL { URL(string: GitItApi.baseUrl + (self.queryItem ?? ""))! }
}

// MARK: - APIs
/*
    // asynchronously fetch
     GitItApiProvider().fetchCommitsSummary { result in
         switch result {
         case .failure(let error):
            // error handling
         case .success(let commitsSummary):
            // UI must be handled in Main Queue
         }
     }
 */
class GitItApiProvider {
    let session: URLSessionProtocol
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func getIsExistUser(name: String, completion: @escaping(Result<Int, AFError>) -> Void) {
        let url = GitItApi.isExistUser(name).url
        
        AF.request(url, method: .get).responseJSON { response in
            switch response.result {
            case let .success(json):
                if let dic = json as? [String: Int] {
                    completion(.success(dic["result"] ?? 0))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func postAddUser(completion: @escaping(Result<Int, AFError>) -> Void) {
        let url = GitItApi.addUser.url
        let param = ["userName": UserInfo.username]
        let headers: HTTPHeaders = ["Accept": "application/json"]
        
        AF.request(url, method: .post, parameters: param, headers: headers).responseJSON { (response) in
            switch response.result {
            case let .success(json):
                if let dic = json as? [String: Int] {
                    completion(.success(dic["result"] ?? 0))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteUser(completion: @escaping(Result<Int, AFError>) -> Void) {
        let url = GitItApi.deleteUser(UserInfo.username!).url
        AF.request(url, method: .delete).responseJSON { (response) in
            switch response.result {
            case let .success(json):
                if let dic = json as? [String: Int] {
                    completion(.success(dic["result"] ?? 0))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func postAddFriend(username: String, completion: @escaping (Result<Int, AFError>) -> Void) {
        let url = GitItApi.addFriend.url
        let param = ["userName": UserInfo.username, "friendName": username]
        print("addfriendAPICalled")
        let headers: HTTPHeaders = ["Accept": "application/json"]
        
        AF.request(url, method: .put, parameters: param, headers: headers).responseJSON { (response) in
            switch response.result {
            case let .success(json):
                if let dic = json as? [String: Int] {
                    completion(.success(dic["result"] ?? 0))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func putDeleteFriend(username: String, completion: @escaping (Result<Int, AFError>) -> Void) {
        let url = GitItApi.deleteFriend.url
        let param = ["userName": UserInfo.username, "friendName": username]
        
        let headers: HTTPHeaders = ["Accept": "application/json"]
        
        AF.request(url, method: .put, parameters: param, headers: headers).responseJSON { (response) in
            switch response.result {
            case let .success(json):
                if let dic = json as? [String: Int] {
                    completion(.success(dic["result"] ?? 0))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchSocialCommitSummary(username: String, completion: @escaping (Result<FriendCommits, ApiError>) -> Void) {
        let request = URLRequest(url: GitItApi.friendCommits(username).url)
        let task: URLSessionTask = self.session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(ApiError.clientError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
               (200...399).contains(httpResponse.statusCode) else {
                completion(.failure(ApiError.serverError(response)))
                return
            }
            
            if let data = data, let commitsSummary = try? JSONDecoder().decode(FriendCommits.self, from: data) {
                completion(.success(commitsSummary))
                return
            }
            completion(.failure(ApiError.unknownError))
        }
        
        task.resume()
    }
    
    func fetchUserData(completion: @escaping (Result<UserData, AFError>) -> Void) {
        let headers: HTTPHeaders = ["Accept": "application/json"]
        let url = GitItApi.userData(UserInfo.username!).url
        
        AF.request(url, method: .get, headers: headers).responseJSON { (response) in
            var data: UserData
            do {
                let decoder = JSONDecoder()
                switch response.result {
                case .success(_):
                    data = try decoder.decode(UserData.self, from: response.data!)
                    completion(.success(data))
                case let .failure(error):
                    completion(.failure(error))
                }
            } catch let parsingError {
                print(parsingError)
                print("here parsing")
            }
        }
    }
    
    func fetchStatsData(completion: @escaping (Result<StatsData, ApiError>) -> Void) {
        guard let username = UserInfo.username else {
            completion(.failure(ApiError.noUsernameError))
            return
        }
        
        let request = URLRequest(url: GitItApi.stats(username).url)
        let task: URLSessionTask = self.session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(ApiError.clientError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...399).contains(httpResponse.statusCode) else {
                completion(.failure(ApiError.serverError(response)))
                return
            }
            
            if let data = data, let statsData = try? JSONDecoder().decode(StatsData.self, from: data) {
                completion(.success(statsData))
                return
            }
            completion(.failure(ApiError.unknownError))
        }
        
        task.resume()
    }
}
