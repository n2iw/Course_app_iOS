//
//  WebViewController.swift
//  Shaban
//
//  Created by Ming Ying on 10/9/17.
//  Copyright © 2017 University at Albany. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    var url: NSURL?

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let request = NSURLRequest(URL: url!)
        self.webView.scalesPageToFit = true
        self.webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
