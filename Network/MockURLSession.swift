//
//  MockURL.swift
//  Git-it
//
//  Created by 정성훈 on 2021/06/01.
//

import Foundation

// https://woowabros.github.io/swift/2020/12/20/ios-networking-and-testing.html
// MARK: - MockURLSession
class MockURLSession: URLSessionProtocol {
    enum FetchCase {
        case userData, friendCommits, stats
    }
    
    var makeRequestFail = false
    var fetchCase: FetchCase = .userData
    required init(makeRequestFail: Bool = false, fetchCase: FetchCase = .userData) {
        self.makeRequestFail = makeRequestFail
        self.fetchCase = fetchCase
    }
    
    var sessionDataTask: MockURLSessionDataTask?
    
    func dataTask(with: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let successResponse = HTTPURLResponse(url: with.url!,
                                              statusCode: 200,
                                              httpVersion: "2",
                                              headerFields: nil)
        
        let failureResponse = HTTPURLResponse(url: with.url!,
                                              statusCode: 400,
                                              httpVersion: "2",
                                              headerFields: nil)
        
        let sessionDataTask = MockURLSessionDataTask()
        
        sessionDataTask.resumeDidCall = {
            if self.makeRequestFail {
                completionHandler(nil, failureResponse, nil)
            } else {
                switch self.fetchCase {
                case .userData:
                    completionHandler(GitItApi.userData("jeong").sampleData, successResponse, nil)
                case .friendCommits:
                    completionHandler(GitItApi.friendCommits("park").sampleData, successResponse, nil)
                case .stats:
                    completionHandler(GitItApi.stats("jeong").sampleData, successResponse, nil)
                }
            }
        }
        self.sessionDataTask = sessionDataTask
        return sessionDataTask
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    override init() {}
    var resumeDidCall: () -> Void = {}
    
    override func resume() {
        self.resumeDidCall()
    }
}

protocol URLSessionProtocol {
    func dataTask(with: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol { }
