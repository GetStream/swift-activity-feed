//
//  WebViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 29/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

open class WebViewController: UIViewController {
    
    public private(set) lazy var activityIndicatorView = UIActivityIndicatorView(style: .gray)
    public private(set) lazy var webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    private lazy var goBackButton = UIBarButtonItem(title: "←", style: .plain, target: self, action: #selector(goBack))
    private lazy var goForwardButton = UIBarButtonItem(title: "→", style: .plain, target: self, action: #selector(goForward))
    public var url: URL?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupWebView()
        
        if navigationController != nil {
            setupToolbar()
        }
        
        if let url = self.url {
            open(url)
        }
    }
    
    public func open(_ url: URL) {
        open(URLRequest(url: url))
    }
    
    public func open(_ request: URLRequest) {
        activityIndicatorView.startAnimating()
        webView.load(request)
        
        if title == nil {
            title = request.url?.absoluteString
        }
    }
    
    @IBAction public func close(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - WebView

extension WebViewController: WKNavigationDelegate {
    open func setupWebView() {
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        webView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicatorView.startAnimating()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
        
        webView.evaluateJavaScript("document.title") { data, _ in
            if let title = data as? String {
                self.title = title
            }
        }
        
        goBackButton.isEnabled = webView.canGoBack
        goForwardButton.isEnabled = webView.canGoForward
    }
    
    @objc func goBack() {
        if let item = webView.backForwardList.backItem {
            webView.go(to: item)
        }
    }
    
    @objc func goForward() {
        if let item = webView.backForwardList.forwardItem {
            webView.go(to: item)
        }
    }
}

// MARK: - Edditional Views

extension WebViewController {
    private func setupToolbar() {
        let closeButton = UIBarButtonItem(image: .closeIcon, style: .plain, target: self, action: #selector(close(_:)))
        navigationItem.leftBarButtonItem = closeButton
        
        goBackButton.isEnabled = false
        goForwardButton.isEnabled = false
        let activityIndicator = UIBarButtonItem(customView: activityIndicatorView)
        navigationItem.rightBarButtonItems = [goForwardButton, goBackButton, activityIndicator]
        activityIndicatorView.startAnimating()
    }
}
