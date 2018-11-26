//
//  Post.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/8/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import Foundation

extension Post
{
    static var bayAreaCoordinates: [(Double, Double)] {
        return [
            (37.7839089, -122.4101843),
            (37.7880413, -122.4171345),
            (37.7766702, -122.4304827),
            (37.7839089, -122.4101843),
            (37.7718441, -122.4306450),
            (37.7644590, -122.4378934),
            (37.7552230, -122.4474025),
            (37.7458377, -122.4405390),
            (37.7394473, -122.4445797),
            (37.7134808, -122.4447480),
            (37.7506301, -122.4604054),
            (37.6852401, -122.4654561),
            (37.6713822, -122.4654561),
            (37.7068212, -122.4218512),
            (37.6803102, -122.4275754),
            (37.7809749, -122.4785881),
            (37.7124153, -122.4910467),
            (37.6387261, -122.4630991),
            (37.6589879, -122.4267336),
            (37.7060220, -122.4267336),
            (37.6629863, -122.4743792)
        ]
    }
    
    static var dummyPosts: [Post] {
        var posts = [Post]()
        
        for i in 0..<20 {
            let (lat, long) = bayAreaCoordinates[i]
            posts.append(Post(id: String(i), lat: lat, long: long))
        }
        
        return posts
    }
    
    convenience init(id: String,
                     content: String = "This is a dummy post that hopefully takes up more than one line. There is nothing meaningful about this post.",
                     userID: String = "0123456789",
                     username: String = "username",
                     commentCount: Int = 6,
                     lat: Double = 37.7749,
                     long: Double = -122.4194,
                     isPrivate: Bool = false,
                     createdAt: NSDate = NSDate())
    {
        self.init()
        self._id = id
        self.content = content
        self.userID = userID
        self.username = username
        self.commentCount = commentCount
        self.latitude = lat
        self.longitude = long
        self.isPrivate = isPrivate
        self.createdAt = createdAt
    }
}

class Post: NSObject
{
    var _id : String!
    var content : String!
    var userID : String!
    var username : String!
    var commentCount: Int = 0
    var latitude : Double!
    var longitude : Double!
    var isPrivate = false
    var createdAt : NSDate!
    
    func delete(completion: @escaping BooleanResponseClosure)
    {
        APIService().delete(post: self) { success, error in
            completion(success, error)
        }
    }
    
    func report(completion: @escaping BooleanResponseClosure)
    {
        APIService().report(post: self) { success, error in
            completion(success, error)
        }
    }
    
    func save(completion: @escaping (Post, Error?) -> Void)
    {
        if self._id != nil {
            
            // we must have already saved
            let error = NSError(domain: "PostModel",
                                code: 500,
                                userInfo: [NSLocalizedDescriptionKey: "Trying to save an existing Post"])
            
            completion(self, error)
        }
        else {
            APIService().create(post: self) { (newPost, error) in
                self.copy(post: newPost)
                completion(self, error)
            }
        }
    }
    
    var isValid: Bool {
        let valid = (self._id != nil
            && self.content != nil
            && self.userID != nil
            && self.latitude != nil
            && self.longitude != nil
            && self.createdAt != nil)
        
        return valid
    }
    
    private func copy(post: Post?)
    {
        if let post = post {
            self._id = post._id
            self.userID = post.userID
            self.username = post.username
            self.content = post.content
            self.latitude = post.latitude
            self.longitude = post.longitude
            self.createdAt = post.createdAt
        }
    }
}

extension Post: PostRouterCompliant
{
    class func from(parameters: [String : AnyObject]) -> Post?
    {
        let post = Post()
        post._id = parameters[Constants.JSONResponseKeys.ID] as? String
        post.content = parameters[Constants.JSONResponseKeys.CONTENT] as? String
        post.userID = parameters[Constants.JSONResponseKeys.USER_ID] as? String
        post.username = parameters[Constants.JSONResponseKeys.USERNAME] as? String
        post.latitude = parameters[Constants.JSONResponseKeys.LATITUDE] as? Double
        post.longitude = parameters[Constants.JSONResponseKeys.LONGITUDE] as? Double
        
        let numComments = parameters[Constants.JSONResponseKeys.COMMENT_COUNT] as? Int
        
        if let commentCount = numComments {
            post.commentCount = commentCount
        }
        
        let createdISO = parameters[Constants.JSONResponseKeys.CREATED_AT] as? String
        
        if let createdISO = createdISO {
            post.createdAt = NSDate(iso8601: createdISO)
        }
        
        let isPrivate = parameters[Constants.JSONResponseKeys.IS_PRIVATE] as? Bool
       
        if let isPrivate = isPrivate {
            post.isPrivate = isPrivate
        }
        
        // validate the post
        if post.isValid {
            return post
        } else {
            print("Post is invalid.")
            return nil
        }
    }
    
    func postParameters() -> [String : AnyObject]
    {
        let dictionary: [String: AnyObject?] = [
            Constants.ParameterKeys.CONTENT: self.content as AnyObject?,
            Constants.ParameterKeys.LATITUDE: self.latitude as AnyObject?,
            Constants.ParameterKeys.LONGITUDE: self.longitude as AnyObject?,
            Constants.ParameterKeys.IS_PRIVATE: self.isPrivate as AnyObject?
        ]
        
        return dictionary.safeFromNil()
    }
}
