//
//  LaunchViewController.swift
//  JumpGame
//
//  Created by Shi Li on 2020/3/19.
//  Copyright © 2020 wanglei. All rights reserved.
//

import UIKit

class LaunchViewController: BaseViewController {

    @IBOutlet weak var imgView: UIImageView!
    
    enum NavigationType {
        case top
        case errorHint(String)
        case newVersionHint
    }
    
    private var api = APIService()
    
    static func instance() -> LaunchViewController {
        let vc = LaunchViewController()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkAppVersion()
    }

    private func checkAppVersion() {
        api.requestAppVersion()
            .map { appVersion -> NavigationType in
                if let errorMsg = appVersion.message, !errorMsg.isEmpty {
                    return .errorHint(errorMsg)
                }
                
                if let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                    let version = appVersion.version,
                    version > currentVersion {
                    return .newVersionHint
                }
                
                return .top
            }
            .catchErrorJustReturn(.top)
            .subscribe(onSuccess: { [weak self] type in
                switch type {
                case .errorHint(let message):
                    self?.showErrorMessage(message)
                case .newVersionHint:
                    self?.showUpdatableMessage()
                case .top:
                    LaunchViewController.showHomePage()
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    private func showErrorMessage(_ message: String) {
        if message.isValidUrl || message.hasPrefix(PrivicyViewController.Metric.flagOfUseSafari) {
            PrivicyViewController.show(with: message, checkUrlScheme: true, hideNavigationView: true)
        } else {
            let alert = Alert()
            alert.show(title: Metric.alertTitle, message: message, preferredStyle: .alert, actions: [DefaultAlertAction.ok(nil)], completion: nil)
        }
    }
    
    static func showHomePage() {
        let homePage = GameViewController.instance()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.rootViewController = homePage
        }
    }
    
    private func showUpdatableMessage() {
        let alert = Alert()
        alert.show(title: Metric.alertTitle,
                   message: Metric.updateInfo,
                   preferredStyle: .alert,
                   actions: [UpdateAlertAction.cancel, UpdateAlertAction.update])
            .subscribe(onNext: { (action) in
                switch action {
                case .update:
                    (UIApplication.shared.delegate as? AppDelegate)?.appManager.showAppInStore()
                case .cancel:
                    LaunchViewController.showHomePage()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension LaunchViewController {
    enum UpdateAlertAction: AlertActionType {
        case update
        case cancel
        
        var title: String? {
            switch self {
            case .update:
                return "Update"
            case .cancel:
                return "Cancel"
            }
        }
        
        var style: UIAlertAction.Style {
            switch self {
            case .update:
                return .default
            case .cancel:
                return .cancel
            }
        }
    }
}

extension LaunchViewController {
    struct Metric {
        private init() {}
        static let alertTitle = "Hint"
        static let updateInfo = "There have new version in AppStore, Would you like to update it ?"
    }
}
