//
//  UserService.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/5/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import Foundation

protocol UserRouterCompliant
{
    func userParameters() -> [String: AnyObject]
    static func from(parameters: [String: AnyObject]) -> User?
}

enum UserRouter: Router
{    
    case checkUsername(String)
    case signUpNewUser(User)
    case login(User)
    case block(String)
    case posts(User)
    case postsCommentedOn(User)
    case logout(User)
    
    var method: String
    {
        switch self {
        case .checkUsername: return "GET"
        case .signUpNewUser: return "POST"
        case .login: return "POST"
        case .block: return "POST"
        case .posts: return "GET"
        case .postsCommentedOn: return "GET"
        case .logout: return "POST"
        }
    }
    
    var path: String
    {
        switch self {
        case .checkUsername(let username):
            return Constants.Paths.CHECK_USERNAME + "/\(username)"
        case .signUpNewUser:
            return Constants.Paths.SIGNUP_NEW_USER
        case .login:
            return Constants.Paths.LOGIN_USER
        case .block(let userID):
            return "\(Constants.Paths.USERS)/\(userID)\(Constants.Paths.BLOCK)"
        case .posts(let user):
            return Constants.Paths.USERS + "/\(user._id!)" + Constants.Paths.POSTS
        case .postsCommentedOn(let user):
            return Constants.Paths.USERS + "/\(user._id!)" + Constants.Paths.POSTS_COMMENTED_ON
        case .logout:
            return Constants.Paths.LOGOUT_USER
        }
    }
    
    var urlRequest: URLRequest
    {
        var request = URLRequest(url: APIService.url(fromPathParameters: nil, withPath: self.path))
        request.httpMethod = self.method

        switch self {
        case .signUpNewUser(let user):
            request.httpBody = APIService.jsonBody(fromParameters: user.userParameters())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        case .login(let user):
            request.httpBody = APIService.jsonBody(fromParameters: user.userParameters())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        default: break
        }
        
        if let token = User.currentUserToken() {
            request.addValue("\(Constants.HeaderKeys.BEARER) \(token)", forHTTPHeaderField: Constants.HeaderKeys.AUTHORIZATION)
        }

        return request
    }    
}
