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
    var team : Team?
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
    
    func currentColor() -> UIColor
    {
        switch self.teamMode {
        case .local:
            return UIColor(hex: Constants.ColorHexValues.DARK_GRAY)
        case .team:
            if let currentTeam = self.team {
                return currentTeam.color
            } else {
                return UIColor(hex: Constants.ColorHexValues.DARK_GRAY)
            }
        }
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
    
    // MARK: Utilities
    
    //remove local user
    func destroy(completion: BooleanResponseClosure)
    {
        _currentUser = nil //destroy memory reference
        User.userDefaults.removeSuite(named: USER_DEFAULT_SUITE) //destroy defaults
        keychain[KEYCHAIN_KEY_TOKEN] = nil //destroy local token
        completion(true, nil) //let caller do something first
        
        //notify anyone who is listening:
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.NOTIFICATION_LOGGED_OUT), object: nil)
    }
    
    func update(fromUser user: User, withToken token: String)
    {
        self._id = user._id
        self.username = user.username
        self.team = user.team
        self.save(authToken: token)
        self.persistUserData()
        _currentUser = self //become active client
    }
    
    private func save(authToken token: String)
    {
        keychain[KEYCHAIN_KEY_TOKEN] = token
    }
    
    private func persistUserData()
    {
        User.userDefaults.set(self._id, forKey: "_id")
        User.userDefaults.set(self.username, forKey: "username")
        User.userDefaults.set(self.team?.rawValue, forKey: "team")
        User.userDefaults.synchronize()
    }
    
    private class func fromDefaults() -> User?
    {
        if let id = User.userDefaults.string(forKey: "_id"),
            let username = User.userDefaults.string(forKey: "username"),
            let teamName = User.userDefaults.string(forKey: "team") {
            let user = User()
            user._id = id
            user.username = username
            user.team = Team(rawValue:teamName)
            return user
        } else {
            return nil
        }
    }
}

extension User: UserRouterCompliant
{
    class func from(parameters: [String: AnyObject]) -> User?
    {
        let newUser = User()
        newUser._id = parameters[Constants.JSONResponseKeys.ID] as? String
        newUser.username = parameters[Constants.JSONResponseKeys.USERNAME] as? String
        
        if let teamName = parameters[Constants.JSONResponseKeys.TEAM_COLOR_NAME] as? String {
            newUser.team = Team(rawValue: teamName)
        }
        
        if newUser.team != nil && newUser.username != nil {
            return newUser
        } else {
            return nil
        }
    }
    
    func userParameters() -> [String : AnyObject]
    {
        let params : [String: AnyObject?] = [
            Constants.ParameterKeys.USERNAME : self.username as AnyObject?,
            Constants.ParameterKeys.PASSWORD : self.password as AnyObject?,
            Constants.ParameterKeys.TEAM_COLOR_NAME : self.team?.rawValue as AnyObject?
        ]
        return params.safeFromNil()
    }
}
