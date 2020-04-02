//
//  AppUsageViewController.swift
//  WhoTapFast
//
//  Created by JackSen on 2020/3/19.
//  Copyright © 2020 JackSen. All rights reserved.
//

import UIKit
import WebKit

class PrivicyViewController: BaseViewController {

    @IBOutlet fileprivate weak var backBtn: UIButton!
    @IBOutlet private weak var webRootView: UIView!
    @IBOutlet weak var navigationViewBottomConstraint: NSLayoutConstraint!
    
    private var needOpenBySafari = false
    private var initialUrl: String!
    private var inputTitle: String?
    private var isNeedUrlScheme: Bool = false
    private var hideNavigationView: Bool = false
    
    lazy var webview: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.selectionGranularity = WKSelectionGranularity.character
        configuration.userContentController = WKUserContentController()
        // 给webview与swift交互起名字，webview给swift发消息的时候会用到
        // 禁止自动全屏播放
        configuration.allowsInlineMediaPlayback = true
        

        var webView = WKWebView(frame: self.webRootView.bounds,
                                configuration: configuration)
        // 让webview翻动有回弹效果
        webView.scrollView.bounces = false
        // 只允许webview上下滚动
        webView.scrollView.alwaysBounceVertical = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.webRootView.addSubview(webView)
        return webView
    }()

    
    // MARK: - life cycle
    static func instance(url: String,
                         checkUrlScheme: Bool = false,
                         hideNavigationView: Bool = false) -> PrivicyViewController {
        let vc = PrivicyViewController()
        vc.initialUrl = url
        vc.isNeedUrlScheme = checkUrlScheme
        vc.hideNavigationView = hideNavigationView
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindAction()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.webview.frame = self.webRootView.bounds
    }
    
    private func setupView() {
        navigationViewBottomConstraint.constant = hideNavigationView ? Metric.navigationBottomWhenHide : Metric.navigationBottomWhenShow
        backBtn.isHidden = hideNavigationView
        
        print("Debug: 4444: \(initialUrl)")
        initialUrl = checkSafariPrefix(initialUrl)
        print("Debug: 5555: \(initialUrl)")
        guard let url = URL(string: initialUrl) else {
            backBtn.sendActions(for: .touchUpOutside)
            return
        }
        
        print("Debug: 666: \(url)")
        if needOpenBySafari {
            print("Debug: 777")
            GCD.after(sec: 1) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                
                LaunchViewController.showHomePage()  
            }
            return
        }
        print("Debug: 888")
        
        let request = URLRequest(url: url)
        self.webview.load(request)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - device configure
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    // MARK: - the logic
    func checkSafariPrefix(_ url: String) -> String {
        var truncatedUrl = url
        if url.hasPrefix(Metric.flagOfUseSafari),
            let range = url.range(of: Metric.flagOfUseSafari) {
            let realUrlStr = url.suffix(from: range.upperBound)
            if let subUrl = URL(string: String(realUrlStr)) {
                truncatedUrl = subUrl.absoluteString
                needOpenBySafari = true
            }
        }
        return truncatedUrl
    }
    
    static func show(with url: String,
                     checkUrlScheme: Bool = false,
                     hideNavigationView: Bool = false) {
        print("Debug: 1111")
        let webVC = PrivicyViewController.instance(url: url,
                                                    checkUrlScheme: checkUrlScheme,
                                                    hideNavigationView: hideNavigationView)
        print("Debug: 2222")
        webVC.modalPresentationStyle = .fullScreen
        UIApplication.topViewController?.present(webVC, animated: true, completion: nil)
    }
    
    private func bindAction() {
        backBtn.addTarget(self, action: #selector(backBtnTapped), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - action
    @objc func backBtnTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardHide() {
        if #available(iOS 12.0, *) {
            for view in self.webview.subviews {
                if let scrollClass = NSClassFromString("WKScrollView"),
                    view.isKind(of: scrollClass) {
                    let scrollView = view as! UIScrollView
                    scrollView.setContentOffset(.zero, animated: false)
                }
            }
        }
    }
    
    // MARK: - tools
    private func addCustomHeader(request: URLRequest, userAgent: String) -> URLRequest {
        var request = request
        request.setValue(userAgent, forHTTPHeaderField: Metric.userAgentKey)
        return request
    }
}

extension PrivicyViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        defer {
            needOpenBySafari = false
        }
        
        guard var url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if (url.scheme == "mqqwpa") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }

        let isMaybeUrlScheme = !(url.scheme ?? "").contains("http")
        
        if !needOpenBySafari,
            url.absoluteString.hasPrefix(Metric.flagOfUseSafari),
            let range = url.absoluteString.range(of: Metric.flagOfUseSafari) {
            let realUrlStr = url.absoluteString.suffix(from: range.upperBound)
            if let subUrl = URL(string: String(realUrlStr)) {
                url = subUrl
                needOpenBySafari = true
            }
        }
        
        if isMaybeUrlScheme || needOpenBySafari || navigationAction.targetFrame == nil {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            decisionHandler(.cancel)
            
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("navigation got error: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("provisional got error: \(error.localizedDescription)")
    }
}

extension PrivicyViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController: UIAlertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {(action: UIAlertAction) -> Void in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completionHandler(false)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: defaultText, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            completionHandler(alert.textFields?.first?.text ?? "")
        }))
        present(alert, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if !(navigationAction.targetFrame?.isMainFrame ?? false) {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension PrivicyViewController {
    struct Metric {
        private init() {}
        static let navigationBottomWhenShow: CGFloat = 44.0
        static let navigationBottomWhenHide: CGFloat = 0
        static let flagOfUseSafari = "safari:"
        static let userAgentKey = "navigator.userAgent"
    }
}
