//
//  Comment.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/14/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import Foundation

class Comment: NSObject
{
    var _id: String?
    var postID: String?
    var userID: String?
    var username: String?
    var user_team: Team?
    var content: String?
    var createdAt: NSDate?
    
    func save(completion: @escaping (Comment, Error?) -> Void)
    {
        //check if comment already exists first
        guard self._id == nil else {
            let error = NSError(domain: "Comment", code: 500, userInfo: [NSLocalizedDescriptionKey: "trying to save a comment that already exists"])
            completion(self, error)
            return
        }
        
        APIService().create(comment: self) { comment, error in
            
            self.copy(comment: comment)
            completion(self, error)
        }
    }
    
    func delete(completion: @escaping BooleanResponseClosure)
    {
        APIService().delete(comment: self) { success, error in
            completion(success, error)
        }
    }
    
    func report(completion: @escaping BooleanResponseClosure)
    {
        APIService().report(comment: self) { success, error in
            completion(success, error)
        }
    }
    
    private func copy(comment:Comment?)
    {
        if let comment = comment {
            self._id = comment._id
            self.postID = comment.postID
            self.userID = comment.userID
            self.username = comment.username
            self.user_team = comment.user_team
            self.content = comment.content
            self.user_team = comment.user_team
            self.createdAt = comment.createdAt
        }
    }

    var isValid: Bool {
        let commentIsValid = self.postID != nil
            && self.userID != nil
            && self.user_team != nil
            && self.username != nil
            && self.content != nil
        
        return commentIsValid
    }
}

extension Comment: CommentRouterCompliant
{
    class func from(parameters: [String : AnyObject]) -> Comment?
    {
        let comment = Comment()
        
        comment._id = parameters[Constants.JSONResponseKeys.ID] as? String
        comment.content = parameters[Constants.JSONResponseKeys.CONTENT] as? String
        comment.userID = parameters[Constants.JSONResponseKeys.USER_ID] as? String
        comment.username = parameters[Constants.JSONResponseKeys.USERNAME] as? String
        comment.postID = parameters[Constants.JSONResponseKeys.POST_ID] as? String

        if let teamName = parameters[Constants.JSONResponseKeys.USER_TEAM] as? String {
            comment.user_team = Team(rawValue: teamName)
        }
        
        let createdISO = parameters[Constants.JSONResponseKeys.CREATED_AT] as? String
        
        if let createdISO = createdISO {
            comment.createdAt = NSDate(iso8601: createdISO)
        }
        
        // validate the comment
        if comment.isValid {
            return comment
        } else {
            print("Comment is invalid.")
            return nil
        }
    }
    
    func commentParameters() -> [String : AnyObject]
    {
        let dictionary : [String: AnyObject?] = [
            "content" : self.content as AnyObject?
        ]
        
        return dictionary.safeFromNil()
    }
}

