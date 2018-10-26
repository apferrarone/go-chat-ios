//
//  PostRouter.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/10/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import Foundation

protocol PostRouterCompliant
{
    func postParameters() -> [String: AnyObject]
    static func from(parameters: [String: AnyObject]) -> Post?
}

enum PostRouter: Router
{    
    case postsForLocation(latitude: Double, longitude: Double, radius: Double)
    case delete(Post)
    case report(Post)
    case create(Post)
    
    var method: String
    {
        switch self {
        case .postsForLocation: return "GET"
        case .delete: return "DELETE"
        case .report: return "POST"
        case .create: return "POST"
        }
    }
    
    var path: String
    {
        switch self {
        case .postsForLocation: return Constants.Paths.POSTS_FOR_LOCATION
        case .delete(let post): return "\(Constants.Paths.POSTS)/\(post._id!)"
        case .report(let post): return "\(Constants.Paths.POSTS)/\(post._id!)\(Constants.Paths.REPORT)"
        case .create: return Constants.Paths.POSTS
        }
    }
    
    var urlRequest: URLRequest
    {
        var request = URLRequest(url: APIService.url(fromPathParameters: nil, withPath: self.path))
        request.httpMethod = self.method
        
        switch self {
        case .postsForLocation(latitude: let lat, longitude: let long, radius: let radius):
            request.url = APIService.url(fromPathParameters: [Constants.ParameterKeys.LATITUDE: lat as AnyObject, Constants.ParameterKeys.LONGITUDE: long as AnyObject, Constants.ParameterKeys.RADIUS: radius as AnyObject], withPath: self.path)
        case .create(let post):
            request.httpBody = APIService.jsonBody(fromParameters: post.postParameters())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        default:
            break
        }

        if let token = User.currentUserToken() {
            print("using User current token")
            request.addValue("\(Constants.HeaderKeys.BEARER) \(token)", forHTTPHeaderField: Constants.HeaderKeys.AUTHORIZATION)
        }
        
        return request
    }
}
