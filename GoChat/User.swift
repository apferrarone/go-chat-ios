//
//  User.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/5/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import Foundation
import KeychainAccess

//important keys - do not change
private let keychain = Keychain(service: "com.PokemonGOTeamChat")
private let KEYCHAIN_KEY_TOKEN = "LOGIN___TOKEN"
private let USER_DEFAULT_SUITE = "CurrentUser"

//current user global var
private var _currentUser: User? = nil

enum TeamMode
{
    case local
    case team
}

class User: NSObject
{
    private static var userDefaults = UserDefaults(suiteName: USER_DEFAULT_SUITE)!
    
    var _id : String?
    var username: String?
    var password : String?
    var teamMode = TeamMode.local
    
    class func currentUser() -> User?
    {
        if _currentUser == nil {
            _currentUser = User.fromDefaults()
        }
        return _currentUser
    }
    
    class func currentUserToken() -> String?
    {
        // for the current user session
        return keychain[KEYCHAIN_KEY_TOKEN]
    }
    
    func signUp(completion: ((User?, Error?) -> Void)?)
    {
        APIService().signUp(newUser: self) { (user, token, error) in
            
            if let user = user, let token = token {
                self.update(fromUser: user, withToken: token)
            }
            
            completion?(self, error)
        }
    }
    
    func login(completion: ((User?, Error?) -> Void)?)
    {
        APIService().login(user: self) { (user, token, error) in
            
            if let user = user, let token = token {
                self.update(fromUser: user, withToken: token)
            }
            
            completion?(self, error)
        }
    }
    
    func logout(completion: @escaping BooleanResponseClosure)
    {
        APIService().logout(user: self) { success, error in
            
            DispatchQueue.main.async {
                guard success && error == nil else {
                    print("error logging out")
                    completion(false, error)
                    return
                }
                
                self.destroy(completion: completion)
            }
        }
    }
    
    func blockUser(withUserID userID: String, completion: @escaping BooleanResponseClosure)
    {
        APIService().blockUser(withUserID: userID) { success, error in
            completion(success, error)
        }
    }
    
// MARK: - Utilities
    
    // remove local user
    func destroy(completion: BooleanResponseClosure)
    {
        _currentUser = nil // destroy memory reference
        User.userDefaults.removeSuite(named: USER_DEFAULT_SUITE) // destroy defaults
        keychain[KEYCHAIN_KEY_TOKEN] = nil // destroy local token
        completion(true, nil) // let caller do something first
        
        // notify anyone who is listening:
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.NOTIFICATION_LOGGED_OUT), object: nil)
    }
    
    func update(fromUser user: User, withToken token: String)
    {
        self._id = user._id
        self.username = user.username
        self.save(authToken: token)
        self.persistUserData()
        _currentUser = self // become active client
    }
    
    private func save(authToken token: String)
    {
        keychain[KEYCHAIN_KEY_TOKEN] = token
    }
    
    private func persistUserData()
    {
        User.userDefaults.set(self._id, forKey: "_id")
        User.userDefaults.set(self.username, forKey: "username")
        User.userDefaults.synchronize()
    }
    
    private class func fromDefaults() -> User?
    {
        guard let id = User.userDefaults.string(forKey: "_id"),
            let username = User.userDefaults.string(forKey: "username")
            else { return nil }
        
        let user = User()
        user._id = id
        user.username = username
        
        return user
    }
}

extension User: UserRouterCompliant
{
    class func from(parameters: [String: AnyObject]) -> User?
    {
        let newUser = User()
        newUser._id = parameters[Constants.JSONResponseKeys.ID] as? String
        newUser.username = parameters[Constants.JSONResponseKeys.USERNAME] as? String
        
        guard newUser.username != nil else {
            return nil
        }
        
        return newUser
    }
    
    func userParameters() -> [String : AnyObject]
    {
        let params : [String: AnyObject?] = [
            Constants.ParameterKeys.USERNAME : self.username as AnyObject?,
            Constants.ParameterKeys.PASSWORD : self.password as AnyObject?,
        ]
        
        return params.safeFromNil()
    }
}
