//
//  LKTwitterKit.swift
//  LKTwitterKit
//
//  Created by Lukas Kollmer on 8/2/15.
//  Copyright (c) 2015 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit
import Accounts
import Social


/**
The kind of request you want to make
*/
internal enum TwitterRequestType {
    case Follow
    case Unfollow
    case IsFollowing
    case Tweet
}

/**
Extension for creating the correct kind of SLRequestMethod from a value of TwitterRequestType
*/
internal extension SLRequestMethod {
    init(requestType: TwitterRequestType) {
        switch requestType {
        case .Follow, .Unfollow, .Tweet:
            self = .POST
            break
        case .IsFollowing:
            self = .GET
            break
        }
    }
}

public var LKTwitterKitVersionNumber: Double = 1.0

/**
Class for performing some basic Twitter actions (tweet, follow, etc.)
*/
public class Twitter: NSObject {
    /**
    Required. Needed to present a list of accounts if more than one acount is set up on the device
    */
    public static var viewController: UIViewController?

    /**
    You can specify an account which will be used for all actions
    */
    public static var defaultAccount: ACAccount?

    /**
    Follow someone

    :param: username The username of the account you wish to follow
    :param: completionHandler A closure which is called when the follow action is performed.
    :param: success A Bool indicating wheter the action was successfull
    */
    public class func follow(username: String, completionHandler: ((success: Bool) -> Void)) {

        let parameters = [
            "screen_name" : username,
            "follow" : "true"
        ]

        let apiEndpoint = "https://api.twitter.com/1.1/friendships/create.json"

        Twitter.makeRequest(.Follow, parameters, apiEndpoint) {(success: Bool) -> Void in
            completionHandler(success: success)
        }


    }

    /**
    Unfollow someone

    :param: username The username of the account you wish to unfollow
    :param: completionHandler A closure which is called when the unfollow action is performed.
    :param: success A Bool indicating wheter the action was successfull
    */
    public class func unfollow(username: String, completionHandler: ((success: Bool) -> Void)) {

        let parameters = [
            "screen_name" : username
        ]

        let apiEndpoint = "https://api.twitter.com/1.1/friendships/destroy.json"
        Twitter.makeRequest(.Unfollow, parameters, apiEndpoint) {(success: Bool) -> Void in
            completionHandler(success: success)
        }
    }

    /**
    Check if the account is currently following a certain user

    :param: username The username of the account you want to check for
    :param: completionHandler A closure which is called when the check action is performed.
    :param: success A Bool indicating wheter the user is following the account
    */
    public class func isFollowing(username: String, completionHandler: ((isFollowing: Bool) -> Void)) {
        Twitter.account {(account: ACAccount?) -> Void in
            if let _ = account {
                let parameters = [
                    "source_screen_name" : account!.username as String,
                    "target_screen_name" : username
                ]

                Twitter.makeRequest(TwitterRequestType.IsFollowing, parameters, "https://api.twitter.com/1.1/friendships/show.json") {(success: Bool) -> Void in
                    completionHandler(isFollowing: success)
                }
            }
        }
    }



    /**
    Tweet something

    :param: text The text you wish to tweet
    :param: completionHandler A closure which is called when the tweet action is performed.
    :param: success A Bool indicating wheter the action was successfull
    */
    public class func tweet(text: String, completionHandler: ((success: Bool) -> Void)) {
        let parameters = [
            "status" : text.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        ]

        let apiEndpoint = "https://api.twitter.com/1.1/statuses/update.json"

        Twitter.makeRequest(.Tweet, parameters, apiEndpoint) {(success: Bool) -> Void in
            completionHandler(success: success)
        }
    }



    /**
    Make a request to the Twitter API

    :param: requestType The kind of action you wish to perform (Tweet, Follow, etc.)
    :param: parameters The parameters you wish to send with the request
    :param: urlEndpoint The enspoint of the API you wish to hit
    :param: completionHandler A closure which is called when the action is performed.
    :param: success A Bool indicating wheter the action was successfull
    */
    private class func makeRequest(requestType: TwitterRequestType, _ parameters: [String : String]!, _ urlEndpoint: String, completionHandler: ((success: Bool) -> Void)) {

        var success: Bool = false
        var requestError: NSError? = nil


        Twitter.account {(account: ACAccount?) -> Void in
            if let _ = account {
                let requestMethod = SLRequestMethod(requestType: requestType)
                let postRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: requestMethod, URL: NSURL(string: urlEndpoint), parameters: parameters)
                postRequest.account = account

                postRequest.performRequestWithHandler({ (responseData: NSData!, urlResponse: NSHTTPURLResponse!, error: NSError!) -> Void in
                    let responseJSON: NSDictionary = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: nil) as! NSDictionary

                    if requestType == .IsFollowing {
                        let isFollowing = ((responseJSON["relationship"] as! NSDictionary)["source"] as! NSDictionary)["following"] as! NSNumber
                        completionHandler(success: isFollowing.boolValue)
                    } else {
                        if error == nil {
                            completionHandler(success: true)
                        } else {
                            completionHandler(success: false)
                        }
                    }
                })

            }
        }
    }


    /**
    Get the Twitter account configured in settings

    Note: If only one account is configured, this account will be returned in the closure. If more than one accounts are configured, an AlertView will be shown, prompting the user to select an account. That is the reason why the viewController property is necessary

    :param: username The username of the account you wich to follow
    :param: completionHandler A closure which is called when the follow action is performed.
    :param: success A Bool indicating wheter the action was successfull
    */
    public class func account(completionHandler: (account: ACAccount?) -> Void) {

        if Twitter.defaultAccount != nil {
            completionHandler(account: Twitter.defaultAccount)
            return
        }
        let accountStore = ACAccountStore()

        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error: NSError!) -> Void in
            if granted {
                let accounts: [ACAccount] = accountStore.accountsWithAccountType(accountType) as! [ACAccount]

                if accounts.isEmpty {
                    println("No twitter account configured")
                    return
                }
                if accounts.count > 1 {
                    let alertController = UIAlertController(title: "Select an account", message: nil, preferredStyle: .Alert)
                    for account in accounts {
                        let alertAction = UIAlertAction(title: account.username, style: .Default) { (alertAction: UIAlertAction!) -> Void in
                            completionHandler(account: account)
                        }
                        alertController.addAction(alertAction)
                    }
                    if Twitter.viewController == nil {
                        println("no view controller set. You save to provide a viewController. this will be used for displaying an alert when more than one twitter accounts are configured")
                        completionHandler(account: nil)
                        return
                    }
                    Twitter.viewController?.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    completionHandler(account: accounts.first!) // TODO: Add support for multiple accounts (show a list in ui)
                }
            }
        }
    }

}
