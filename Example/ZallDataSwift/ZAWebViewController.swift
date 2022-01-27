//
//  JSCallOCViewController.swift
//  ZallDataSwift
//
//  Created by guo on 2021/12/10.
//  Copyright © 2021 Zall Data Co., Ltd. All rights reserved.
//

import UIKit
import WebKit
import ZallDataSDK
class ZAWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    lazy var webView:WKWebView = {
        let webView = WKWebView(frame: view.bounds)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view.addSubview(webView)
       return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
//
//        let url = Bundle.main.resourceURL!.appendingPathComponent("test2.html");
//
//        let request = URLRequest(url: url)
//        webView.load(request)
        // Do any additional setup after loading the view.
        
        if let url = Bundle.main.url(forResource: "test", withExtension: "html") {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
        
        
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (ZallDataSDK.sharedInstance()?.showUpWebView(webView, with: navigationAction.request))! {
            decisionHandler(WKNavigationActionPolicy.cancel)
            return;
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    
    
    
     

}
