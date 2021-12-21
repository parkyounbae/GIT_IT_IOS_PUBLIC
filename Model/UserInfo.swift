//
//  UserInfo.swift
//  Git-it
//
//  Created by 정성훈 on 2021/05/13.
//

import Foundation

struct UserInfo {
    enum Key: String {
        case username
        case friendList
        case profileImageData
        case profileImageKey
        case loginSucces
        case isTrial
    }
    
    private init() {}
    
    static var isTrial: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: Key.isTrial.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.isTrial.rawValue)
        }
    }
    
    static var loginSucces: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: Key.loginSucces.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.loginSucces.rawValue)
        }
    }
    
    static var username: String? {
        get {
            return UserDefaults.standard.string(forKey: Key.username.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.username.rawValue)
        }
    }
    
    static var friendList: [String]? {
        get {
            return UserDefaults.standard.stringArray(forKey: Key.friendList.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.friendList.rawValue)
        }
    }
    
    static var profileImageKey: URL? {
        get {
            guard let urlStr = UserDefaults.standard.string(forKey: Key.profileImageKey.rawValue) else {
                return nil
            }
            return URL(string: urlStr)
        }
        set {
            let value = newValue?.absoluteString
            return UserDefaults.standard.set(value, forKey: Key.profileImageKey.rawValue)
        }
    }
    
    static func remove(forKey key: UserInfo.Key) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
    static func reset() {
        remove(forKey: Key.username)
        remove(forKey: Key.friendList)
        remove(forKey: Key.profileImageData)
        remove(forKey: Key.profileImageKey)
        loginSucces = false
        isTrial = false
//        remove(forKey: Key.loginSucces)
//        remove(forKey: Key.isTrial)
    }
}
