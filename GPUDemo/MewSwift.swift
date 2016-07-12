//
//  MewSwift.swift
//  FlyGift
//
//  Created by Darcy on 16/7/12.
//  Copyright © 2016年 Crzlink. All rights reserved.
//

import Foundation

@objc  class WebViewController : UIViewController  {
    
    var data : NSData!
    var selected : Bool!
    var webView : UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = UIWebView.init()
        webView.frame = self.view.bounds
        webView.scalesPageToFit = true
        webView.scrollView.backgroundColor = UIColor.greenColor()
        self.view.addSubview(webView)
        
        loadContent("https://www.baidu.com/s?wd=class%20xx%20has%20no%20initializers&rsv_spt=1&rsv_iqid=0xdf1f9b370000eb5b&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&rqlang=cn&tn=baiduhome_pg&rsv_enter=1&oq=class%20xx%20has%20no%20initializers&rsv_t=0774FbGMoIHPf%2FxcWjYgESLMI2Ase6GXgcg%2FcHuglMLjh%2FdZqZcKJVXYCcnILHMcBB%2F%2B&inputT=17167&rsv_pq=a99c39c40002421e&rsv_sug3=42&bs=class%20xx%20has%20no%20initializers")
    }
    
    func loadContent(string : NSString) {
        
        let url : NSURL = NSURL.init(string: string as String)!
        let request : NSURLRequest = NSURLRequest.init(URL: url)
        self.webView.loadRequest(request)
    }
}