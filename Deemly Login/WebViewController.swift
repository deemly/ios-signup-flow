//
//  WebViewController.swift
//  Deemly Login
//
//  Created by Anders Borum on 06/12/2017.
//  Copyright © 2017 Anders Borum. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    public var email = ""
    public var name = ""
    public var redirectUrl = URL(string: "http://laernogetnyt.dk/")!
    
    @IBOutlet weak var webView: WKWebView!

    func quoteJavascript(string: String) -> String {
        var escaped = string.replacingOccurrences(of: "\\", with: "\\\\")
        escaped = escaped.replacingOccurrences(of: "\"", with: "\\\"")
        escaped = escaped.replacingOccurrences(of: "\n", with: "\\n")
        escaped = escaped.replacingOccurrences(of: "\r", with: "\\r")
        return "\"\(escaped)\""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        
        // load sign-up page from resource bundle
        guard let url = Bundle.main.url(forResource: "signup", withExtension: "html") else { return }
        guard var string = try? String.init(contentsOf: url) else { return }

        // insert known values for email, name and returnUrl
        string = string.replacingOccurrences(of: "$(EMAIL)", with: quoteJavascript(string: email))
        string = string.replacingOccurrences(of: "$(NAME)", with: quoteJavascript(string: name))
        string = string.replacingOccurrences(of: "$(RETURNURL)", with: quoteJavascript(string: redirectUrl.absoluteString))
        
        // run as static html page that submits itself to start flow
        webView.loadHTMLString(string, baseURL: nil)
    }

    // called when webView redirects to the redirectUrl and the app might dismiss the webView
    func flowCompleted() {
        let title = NSLocalizedString("Done", comment: "")
        let message = NSLocalizedString("You are back at redirectUrl which indicates sign up flow is done or aborted by user.", comment: "")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default,
                                      handler: { _ in

            // dismiss web view
            self.navigationController?.popViewController(animated: true)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func show(error: Error) {
        let title = NSLocalizedString("Error", comment: "")
        let message = error.localizedDescription
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }
    
    func isGoogleAuth(url: URL) -> Bool {
        let googleHost = (url.host ?? "").contains("google.com")
        let oAuthPath = url.path.contains("oauth")
        return googleHost && oAuthPath
    }
    
    // MARK: WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        show(error: error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        show(error: error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        
        print("decidePolicyFor: \(navigationAction.request.url?.absoluteString ?? "")")
        
        // we assume flow is completed as soon as we are back at the hostname of the redirectUrl
        // and more precise checks might be needed
        if navigationAction.request.url?.host == redirectUrl.host {
            flowCompleted()
        }
        
        // Google does not allow WebView OAuth and we jump out to external browser that will
        // bring back result when done
        if let url = navigationAction.request.url {
            if isGoogleAuth(url: url) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }

}
