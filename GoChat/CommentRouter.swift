//
//  CommentRouter.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/16/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import Foundation

protocol CommentRouterCompliant
{
    func commentParameters() -> [String: AnyObject]
    static func from(parameters: [String: AnyObject]) -> Comment?
}

enum CommentRouter: Router
{
    case all(Post)
    case create(Comment)
    case delete(Comment)
    case report(Comment)
    
    var method: String
    {
        switch self {
        case .all: return "GET"
        case .create: return "POST"
        case .delete: return "DELETE"
        case .report: return "POST"
        }
    }
    
    var path: String
    {
        switch self {
        case .all(let post):
            return "\(Constants.Paths.POSTS)/\(post._id!)\(Constants.Paths.COMMENTS)"
        case .create(let comment):
            return "\(Constants.Paths.POSTS)/\(comment.postID!)\(Constants.Paths.COMMENTS)"
        case .delete(let comment):
            return "\(Constants.Paths.POSTS)/\(comment.postID!)\(Constants.Paths.COMMENTS)/\(comment._id!)"
        case .report(let comment):
            return "\(Constants.Paths.POSTS)/\(comment.postID!)\(Constants.Paths.COMMENTS)/\(comment._id!)\(Constants.Paths.REPORT)"
        }
    }
    
    var urlRequest: URLRequest
    {
        var request = URLRequest(url: APIService.url(fromPathParameters: nil, withPath: self.path))
        request.httpMethod = self.method
        
        if let token = User.currentUserToken() {
            request.addValue("\(Constants.HeaderKeys.BEARER) \(token)", forHTTPHeaderField: Constants.HeaderKeys.AUTHORIZATION)
            print("token: \(token)")
        }
        
        switch self {
        case .create(let comment):
            request.httpBody = APIService.jsonBody(fromParameters: comment.commentParameters())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            return request
        default:
            return request
        }
    }
}
