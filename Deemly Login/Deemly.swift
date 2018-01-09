//
//  Deemly.swift
//  Deemly Login
//
//  Created by Anders Borum on 09/01/2018.
//  Copyright © 2018 Anders Borum. All rights reserved.
//

import UIKit

class Deemly {
    private static var signUpCompletion = {}
    
    // used to make sure AppDelegate routes deemly-<APPID> URL's into this class.
    private static var schemeHandlingVerified = false
    
    // start sign-up flow in external browser, returning whether it was possible to
    // open a https:// URL. You need to
    @discardableResult static public func OpenSignUpFlow(email: String, fullName: String,
                                      completion: @escaping (() -> ())) -> Bool {
        // if we are getting crashes here, it is because the Info.plist is missing required configuration
        let returnUrl = try! INFO_PLIST_NOT_PROPERLY_CONFIGURED_FOR_DEEMLY()
        let escapedReturn = returnUrl.absoluteString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        try! APP_DELEGATE_DOES_NOT_HANDLE_DEEMLY_SCHEME()
        
        let escapedEmail = email.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let escapedName = fullName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = "https://trust.deemly.co/joindeemly?email=\(escapedEmail)&name=\(escapedName)&returnUrl=\(escapedReturn)&profileId="
        let url = URL(string: urlString)!

        signUpCompletion = completion
        
        // we use the deprecated call to allow using this Helper class on old versions of iOS
        return UIApplication.shared.openURL(url)
    }
    
    static public func open(url: URL) -> Bool {
        guard let scheme = url.scheme else { return false }
        guard scheme.hasPrefix("deemly-") else { return false }
        
        if scheme == "deemly-verify" {
            schemeHandlingVerified = true
            return true
        }
        
        signUpCompletion()
        return true
    }
    
    enum AuthenticationConfigurationError: Error {
        case MissingAppId
        case MissingUrlScheme(scheme: String)
        case NotHandlingDeemlyUrlScheme
    }
    
    // ensure that AppDelegate handles URL's with the "deemly-<APPID>://" scheme by calling
    // Deemly.open(url: url) in the app delegate methods.
    //
    // It has such a strange name to show up in crash reports.
    private static func APP_DELEGATE_DOES_NOT_HANDLE_DEEMLY_SCHEME() throws {
        let url = URL(string: "deemly-verify://")!
        
        let application = UIApplication.shared
        let appDelegate = application.delegate!
        
        // we call both modern and deprecated delegates to allow using this Helper class on old versions of iOS
        let _ = appDelegate.application?(application, open: url, sourceApplication: nil, annotation: "")
        let _ = appDelegate.application?(application, open: url, options: [:])
        
        if !schemeHandlingVerified {
            throw AuthenticationConfigurationError.NotHandlingDeemlyUrlScheme
        }
    }
    
    // determine URL to redirect to, aborting app with exception showing that Info.plist is misconfigured.
    // It has such a strange name to show up in crash reports.
    private static func INFO_PLIST_NOT_PROPERLY_CONFIGURED_FOR_DEEMLY() throws -> URL {
        guard let appId = Bundle.main.infoDictionary?["DeemlyAppIdentifier"] as? String else {
            throw AuthenticationConfigurationError.MissingAppId
        }
        
        // we require registration of the given URL scheme in the Info.plist file
        let scheme = "deemly-\(appId)"
        if let types = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String:Any]] {
            for type in types {
                let schemes: [String] = (type["CFBundleURLSchemes"] as? [String]) ?? [String]()
                if schemes.contains(scheme) {
                    // we found the required scheme
                    return URL(string: "\(scheme)://redirect")!
                }
            }
        }
        
        throw AuthenticationConfigurationError.MissingUrlScheme(scheme: scheme)
    }
}
