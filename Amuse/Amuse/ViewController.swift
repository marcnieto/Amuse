//
//  ViewController.swift
//  Amuse
//
//  Created by Marc Nieto on 6/8/17.
//  Copyright © 2017 KandidProductions. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIWebViewDelegate {
    
    /* Elements */
    fileprivate var webView: UIWebView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    
    /* Vars */
    let date = Date()
    let formatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.showInstagramAuth()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func showInstagramAuth() {
        let url = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=code", INSTAGRAM_IDS.INSTAGRAM_AUTHURL,  INSTAGRAM_IDS.INSTAGRAM_CLIENT_ID, INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI)
        let request = URLRequest.init(url: URL.init(string: url)!)
        
        webView = UIWebView(frame: self.view.frame);
        webView.scrollView.isScrollEnabled = false;
        webView.scrollView.bounces = false;
        webView.delegate = self
        webView.loadRequest(request)
        
        self.view.addSubview(webView)
    }
    
    
    func checkRequestForCallbackURL(_ request: URLRequest) -> Bool {
        
        let requestURLString = (request.url?.absoluteString)! as String
        
        if requestURLString.hasPrefix(INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI) {
            let range: Range<String.Index> = requestURLString.range(of: "code=")!
            handleAuth(requestURLString.substring(from: range.upperBound))
            
            webView.removeFromSuperview()
            
            return false;
        }
        return true
    }

    func handleAuth(_ code: String)  {
        print("Instagram authentication code ==", code)
        
        let parameters: Parameters = [
            "client_id": INSTAGRAM_IDS.INSTAGRAM_CLIENT_ID,
            "client_secret": INSTAGRAM_IDS.INSTAGRAM_CLIENTSERCRET,
            "grant_type": INSTAGRAM_IDS.INSTAGRAM_GRANT_TYPE,
            "redirect_uri": INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI,
            "code": code
        ]
        
        Alamofire.request(INSTAGRAM_IDS.INSTAGRAM_ACCESS_URL, method: .post, parameters: parameters).responseJSON { response in
            if let value = response.result.value {
                let json = JSON(value)
                let username = json["user"]["username"].string
                let imageURL = json["user"]["profile_picture"].string
                
                /* label formatting */
                self.formatter.timeStyle = .short
                let timeString = self.formatter.string(from: self.date)
                
                self.timeLabel.text = "Hello \(username!),\nThe current date and time is\n\(timeString)"
                self.profilePicture.imageFromServerURL(urlString: imageURL!);
            }
        }
    }
    
    // MARK: - UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return checkRequestForCallbackURL(request)
    }
}

