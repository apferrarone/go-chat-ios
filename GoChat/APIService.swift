//
//  APIService.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/2/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import Foundation
import CoreLocation

typealias AuthenticationResultClosure = (_ newUser: Bool) -> Void
typealias AuthResponseClosure = (_ user: User?, _ token: String?, _ error: Error?) -> Void
typealias LocalTeamResponseClosure = (_ local: [Post]?, _ team: [Post]?, _ error: Error?) -> Void
typealias BooleanResponseClosure = (_ success: Bool, _ error: Error?) -> Void

protocol Router
{
    var urlRequest: URLRequest { get }
}

class APIService: NSObject
{
    // MARK: Authentication
    
    func verify(username: String, password: String, completion: @escaping (Bool, Error?) -> (Void))
    {
        self.request(router: UserRouter.checkUsername(username)) { response, error in
            
            #if DEBUG
                completion(true, nil)
                return
            #endif
            
            guard error == nil else {
                completion(false, error)
                return
            }
            
            //sucess
            if let result = response as? [String: AnyObject], let usernameIsAvailable = result[Constants.JSONResponseKeys.USERNAME_AVAILABLE] as? Bool {
                completion(usernameIsAvailable, nil)
                return
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(false, error)
        }
    }
    
    func signUp(newUser user: User, completion: @escaping AuthResponseClosure)
    {
        self.request(router: UserRouter.signUpNewUser(user)) { response, error in
            
            #if DEBUG
                completion(User(), nil, nil)
                return
            #endif
            
            guard error == nil else {
                completion(nil, nil, error)
                return
            }
            
            //success
            if let result = response as? [String: AnyObject],
                let userParams = result[Constants.JSONResponseKeys.USER] as? [String: AnyObject],
                let token = result[Constants.JSONResponseKeys.TOKEN] as? String {
                
                if let newUser = User.from(parameters: userParams) {
                    completion(newUser, token, nil)
                    return
                }
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(nil, nil, error)
        }
    }
    
    func login(user: User, completion: @escaping AuthResponseClosure)
    {
        self.request(router: UserRouter.login(user)) { response, error in
            
            guard error == nil else {
                completion(nil, nil, error)
                return
            }
            
            //success
            if let result = response as? [String: AnyObject],
                let userParams = result[Constants.JSONResponseKeys.USER] as? [String: AnyObject],
                let token = result[Constants.JSONResponseKeys.TOKEN] as? String {
                
                if let user = User.from(parameters: userParams) {
                    completion(user, token, nil)
                    return
                }
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(nil, nil, error)
        }
    }
    
    func logout(user: User, completion: @escaping BooleanResponseClosure)
    {
        self.request(router: UserRouter.logout(user)) { response, error in
            
            guard error == nil else {
                completion(false, error)
                return
            }
            
            if let result = response as? [String: AnyObject],
                let sucess = result[Constants.JSONResponseKeys.SUCCESS] as? Bool {
                completion(sucess, error)
                return
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(false, error)
        }
    }
    
    // MARK: Users
    
    func blockUser(withUserID userID: String, completion: @escaping BooleanResponseClosure)
    {
        self.request(router: UserRouter.block(userID)) { response, error in
            
            guard error == nil else {
                completion(false, error)
                return
            }
            
            if let result = response as? [String: AnyObject],
                let success = result[Constants.JSONResponseKeys.SUCCESS] as? Bool {
                completion(success, nil)
                return
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(false, error)
        }
    }
    
    // MARK: Posts
    
    func getPosts(forLocation location: CLLocationCoordinate2D, withinMiles radius: Double, completion: @escaping LocalTeamResponseClosure)
    {
        #if DEBUG
            completion(Post.dummyPosts, Post.dummyPosts, nil)
            return
        #endif
        
        self.request(router: PostRouter.postsForLocation(latitude: location.latitude, longitude: location.longitude, radius: radius)) { (response, error) in
            
            guard error == nil else {
                completion(nil, nil, error)
                return
            }
            
            if let result = response as? [String: AnyObject],
                let publicPostResponse = result[Constants.JSONResponseKeys.PUBLIC_POSTS] as? [[String: AnyObject]],
                let teamPostResponse = result[Constants.JSONResponseKeys.TEAM_POSTS] as? [[String: AnyObject]] {
                
                let publicPosts = self.posts(fromResponse: publicPostResponse)
                let teamPosts = self.posts(fromResponse: teamPostResponse)
                completion(publicPosts, teamPosts, nil)
                return
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(nil, nil, error)
        }
    }
    
    func getPosts(forUser user: User, withRouter router: Router, completion: @escaping LocalTeamResponseClosure)
    {
        self.request(router: router) { response, error in
            
            guard error == nil else {
                completion(nil, nil, error)
                return
            }
            
            if let result = response as? [String: AnyObject],
                let publicPostResponse = result[Constants.JSONResponseKeys.PUBLIC_POSTS] as? [[String: AnyObject]],
                let teamPostResponse = result[Constants.JSONResponseKeys.TEAM_POSTS] as? [[String: AnyObject]] {
                
                let publicPosts = self.posts(fromResponse: publicPostResponse)
                let teamPosts = self.posts(fromResponse: teamPostResponse)
                completion(publicPosts, teamPosts, nil)
                return
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 40, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(nil, nil, error)
        }
    }
    
    func getPosts(forUser user: User, completion: @escaping LocalTeamResponseClosure)
    {
        self.getPosts(forUser: user, withRouter: UserRouter.posts(user)) { localPosts, teamPosts, error in
            completion(localPosts, teamPosts, error)
        }
    }
    
    func getCommentedPosts(forUser user: User, completion: @escaping LocalTeamResponseClosure)
    {
        self.getPosts(forUser: user, withRouter: UserRouter.postsCommentedOn(user)) { localPosts, teamPosts, error in
            completion(localPosts, teamPosts, error)
        }
    }
    
    func delete(post: Post, completion: @escaping BooleanResponseClosure)
    {
        self.request(router: PostRouter.delete(post)) { response, error in
            
            guard error == nil else {
                completion(false, error)
                return
            }
            
            if let result = response as? [String: AnyObject],
                let success = result[Constants.JSONResponseKeys.SUCCESS] as? Bool {
                completion(success, nil)
                return
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(false, error)
        }
    }
    
    func report(post: Post, completion: @escaping BooleanResponseClosure)
    {
        self.request(router: PostRouter.report(post)) { response, error in
            
            guard error == nil else {
                completion(false, error)
                return
            }
            
            if let result = response as? [String: AnyObject],
                let success = result[Constants.JSONResponseKeys.SUCCESS] as? Bool {
                completion(success, nil)
                return
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(false, error)
        }
    }
    
    func create(post: Post, completion: @escaping (Post?, Error?) -> Void)
    {
        self.request(router: PostRouter.create(post)) { response, error in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            if let result = response as? [String: AnyObject], let newPost = Post.from(parameters: result) {
                completion(newPost, nil)
                return
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(nil, error)
        }
    }
    
    // MARK: Comments
    
    func create(comment: Comment, completion: @escaping (Comment?, Error?) -> Void)
    {
        self.request(router: CommentRouter.create(comment)) { response, error in
            
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            if let result = response as? [String: AnyObject],
                let newComment = Comment.from(parameters: result) {
                completion(newComment, nil)
                return
            }
            
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(nil, error)
            
        }
    }
    
    func getComments(forPost post: Post, completion: @escaping ([Comment]?, Error?) -> Void)
    {
        #if DEBUG
            completion(Comment.dummyComments, nil)
            return
        #endif
        
        self.request(router: CommentRouter.all(post)) { response, error in
            
            guard error == nil else {
                completion(nil, error)
                return
            }

            if let result = response as? [String: AnyObject],
                let commentsResponse = result[Constants.JSONResponseKeys.COMMENTS] as? [[String: AnyObject]] {
                
                let comments = self.comments(fromResponse: commentsResponse)
                completion(comments, nil)
                return
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(nil, error)
        }
    }
    
    func delete(comment: Comment, completion: @escaping BooleanResponseClosure)
    {
        self.request(router: CommentRouter.delete(comment)) { response, error in
            
            guard error == nil else {
                completion(false, error)
                return 
            }
            
            if let result = response as? [String: AnyObject],
                let success = result[Constants.JSONResponseKeys.SUCCESS] as? Bool {
                completion(success, nil)
                return
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(false, error)
        }
    }
    
    func report(comment: Comment, completion: @escaping BooleanResponseClosure)
    {
        self.request(router: CommentRouter.report(comment)) { response, error in
            
            guard error == nil else {
                completion(false, error)
                return
            }
            
            if let result = response as? [String: AnyObject],
                let success = result[Constants.JSONResponseKeys.SUCCESS] as? Bool {
                completion(success, nil)
                return
            }
            
            //catch errors
            let error = NSError(domain: "APIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Couldn't understand HTTP response"])
            completion(false, error)
        }
    }
    
    // MARK: Helpers
    
    private func request(router: Router, completion: @escaping (Any?, Error?) -> Void)
    {
        URLSession.shared.dataTask(with: router.urlRequest) { (data, response, error) in
            
            print(router.urlRequest.url!.absoluteString)
                        
            guard (error == nil) else {
                completion(response, error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(response, error)
                return
            }
            
            guard let data = data else {
                completion(response, error)
                return
            }
            
            do {
                
                if let response = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] {
                    completion(response, nil)
                }
                
            } catch let error {
                completion(nil, error)
            }
            
        }.resume()
    }
    
    private func posts(fromResponse response: [[String: AnyObject]]) -> [Post]
    {
        var posts = [Post]()
        for postDictionary in response {
            if let post = Post.from(parameters: postDictionary) {
                posts.append(post)
            }
        }
        return posts
    }
    
    private func comments(fromResponse response: [[String: AnyObject]]) -> [Comment]
    {
        var comments = [Comment]()
        for commentDictionary in response {
            if let comment = Comment.from(parameters: commentDictionary) {
                comments.append(comment)
            }
        }
        return comments
    }
}

// MARK: Class Functions

extension APIService
{
    class func url(fromPathParameters parameters: [String:AnyObject]?, withPath path: String? = nil) -> URL
    {
        var components = URLComponents()
        components.scheme = Constants.API.SCHEME
        components.host = Constants.API.HOST
        components.path = path ?? ""
        components.queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.url!
    }
    
    class func jsonBody(fromParameters params: [String: AnyObject]) -> Data?
    {
        do {
            let httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            return httpBody
            
        } catch let error {
            print(error)
            return nil
        }
    }
}



