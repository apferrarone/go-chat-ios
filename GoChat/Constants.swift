//
//  Constants.swift
//  GoChat
//
//  Created by Andrew Ferrarone on 12/2/16.
//  Copyright © 2016 Andrew Ferrarone. All rights reserved.
//

import UIKit

class Constants: NSObject
{
    struct ColorHexValues
    {
        static let TEAM_INSTICT = 0xF0B922
        static let TEAM_MYSTIC = 0x4445BE
        static let TEAM_VALOR = 0xC54632
        static let DARK_GRAY = 0x323232
        static let CRYPTO_PINK = 0xDF11A8
    }
    
    struct Authentication
    {
        static let USERNAME_TAKEN = "🤔 that name is taken. try another"
        static let SIGNUP_ERROR_MESSAGE = "Something went wrong. Try again?"
        static let LOGIN_ERROR_MESSAGE = "Couldn't log in. Check your username and password."
        static let CHARACTERS_MAX_USERNAME = 20
        static let CHARACTERS_MAX_PASSWORD = 30
        static let CHOOSE_TEAM_MESSAGE = "choose your team"
        static let MAIN_STORYBOARD_ID = "Main"
        static let ROOT_NAVIGATION_CONTROLLER_ID = "signupNavigation"
    }
    
    struct NewPost
    {
        static let CHARACTERS_MAX = 300
        static let TITLE_DEFAULT = "new post"
        static let TITLE_MAP = "choose location"
        static let TITLE_TEAM = "team post"
    }
    
    struct ImageNames
    {
        static let TEAM_INSTINCT = "Zapdos"
        static let TEAM_MYSTIC = "Articuno"
        static let TEAM_VALOR = "Moltres"
        static let POKEBALL_GRAY = "PokeBall-Gray"
        static let POKEBALL_YELLOW = "PokeBall-Yellow"
        static let POKEBALL_BLUE = "PokeBall-Blue"
        static let POKEBALL_RED = "PokeBall-Red"
        static let PIN_YELLOW = "Pin-Yellow"
        static let PIN_BLUE = "Pin-Blue"
        static let PIN_RED = "Pin-Red"
        static let ADD_BLUE = "AddButton-Blue"
        static let ADD_YELLOW = "AddButton-Yellow"
        static let ADD_RED = "AddButton-Red"
        static let ADD_GRAY = "AddButton-Gray"
    }
    
    struct Notifications
    {
        static let NOTIFICATION_TEAM_CHANGE = "team_status_changed"
        static let NOTIFICATION_POST_DELETED = "post_deleted"
        static let NOTIFICATION_LOGGED_OUT = "User_Logged_Out"
    }
    
    struct API
    {
        static let SCHEME = "http"
        //static let HOST = "staging.ihwcepkydd.us-east-1.elasticbeanstalk.com"
        static let HOST = "api.pokemonteam.chat"
        static let HOST_PRODUCTION = "api.pokemonteam.chat"
    }
    
    struct Settings
    {
        static let EMAIL_FEEDBACK = "PokemonGoTeamChat@Gmail.com"
    }
    
    struct MyPosts
    {
        static let TITLE_NEARBY_POSTS = "my public posts"
        static let TITLE_TEAM_POSTS = "my team posts"
        static let TITLE_NEARBY_COMMENTS = "my comments"
        static let TITLE_TEAM_COMMENTS = "my team comments"
    }
    
    struct Paths
    {
        // Authentication
        static let CHECK_USERNAME = "/check_username"
        static let SIGNUP_NEW_USER = "/signup"
        static let LOGIN_USER = "/login"
        static let LOGOUT_USER = "/logout"
        
        static let USERS = "/users"
        static let BLOCK = "/block"
        
        // Posts
        static let POSTS_FOR_LOCATION = "/posts_by_location"
        static let POSTS = "/posts"
        static let COMMENTS = "/comments"
        static let REPORT = "/report"
        static let POSTS_COMMENTED_ON = "/commented_on"
    }
    
    struct ParameterKeys
    {
        static let USERNAME = "username"
        static let PASSWORD = "password"
        
        static let LATITUDE = "latitude"
        static let LONGITUDE = "longitude"
        static let RADIUS = "within"
        static let CONTENT = "content"
        static let TEAM_COLOR_NAME = "team"
        static let IS_PRIVATE = "is_private"
    }
    
    struct HeaderKeys
    {
        static let AUTHORIZATION = "Authorization"
        static let BEARER = "Bearer"
    }
    
    struct JSONResponseKeys
    {
        static let USERNAME_AVAILABLE = "available"
        static let USER = "user"
        static let TOKEN = "token"
        
        static let PUBLIC_POSTS = "public_posts"
        static let TEAM_POSTS = "team_posts"
        static let RADIUS = "radius"
        static let ID = "_id"
        static let CONTENT = "content"
        static let USER_ID = "user"
        static let USERNAME = "username"
        static let COMMENT_COUNT = "comment_count"
        static let LATITUDE = "latitude"
        static let LONGITUDE = "longitude"
        static let TEAM_COLOR_NAME = "team"
        static let IS_PRIVATE = "is_private"
        static let CREATED_AT = "createdAt"
        static let UPDATED_AT = "updatedAt"
        static let SUCCESS = "success"
        
        static let POST_ID = "parent_post"
        static let USER_TEAM = "user_team"
        static let COMMENTS = "comments"
    }
    
    struct Posts
    {
        static let IMAGE_NAME_FOR_EMPTY_LOCAL_POSTS = "PikachuUpset"
        static let TITLE_FOR_EMPTY_LOCAL_POSTS = "*sigh* no posts yet. let's make one!"
        static let TITLE_NEARBY = "nearby"
        static let TITLE_TEAM_ONLY = "team chat"
    }
    
    struct PostDetail
    {
        static let IMAGE_NAME_FOR_EMPTY_COMMENTS = "Snorlax"
        static let TITLE_FOR_EMPTY_COMMENTS = "no comments. yet.."
    }
}
