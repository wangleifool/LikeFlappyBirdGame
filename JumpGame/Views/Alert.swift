//
//  Alert.swift
//  WhoTapFast
//
//  Created by JackSen on 2020/3/14.
//  Copyright © 2020 JackSen. All rights reserved.
//

import Foundation
import UIKit

typealias TextfieldHandler = (UITextField) -> Void

// ----- AlertActionType -----
protocol AlertActionType {
    var title: String? { get }
    var style: UIAlertAction.Style { get }
}

extension AlertActionType {
    var style: UIAlertAction.Style {
        return .default
    }
}

// ----- Action -----

enum DefaultAlertAction: AlertActionType {
    case ok(Error?)
    case no
    case yes

    var title: String? {
        switch self {
        case .ok:
            return "Ok"
        case .no:
            return "No"
        case .yes:
            return "Yes"
        }
    }

    var style: UIAlertAction.Style {
        switch self {
        case .no:
            return .cancel
        default:
            return .default
        }
    }
}

// ----- Alert -----

protocol AlertType: class {
    func show<Action: AlertActionType>(title: String?,
                                       message: String?,
                                       preferredStyle: UIAlertController.Style,
                                       actions: [Action],
                                       textFieldConfigurationHandlers: [(UITextField) -> Void],
                                       completion: ((Action) -> Void)?)
    
    func show<Action: AlertActionType>(title: String?,
                                       message: String?,
                                       preferredStyle: UIAlertController.Style,
                                       actions: [Action]) -> Observable<Action>
}

final class Alert: AlertType {

    func show<Action>(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style,
                      actions: [Action],
                      textFieldConfigurationHandlers: [(UITextField) -> Void] = [],
                      completion: ((Action) -> Void)? = nil) where Action: AlertActionType {
        guard let message = message else { return }
        Alert.makeAlertController(title: title,
                                  message: message,
                                  preferredStyle: preferredStyle,
                                  actions: actions,
                                  textFieldConfigurationHandlers: textFieldConfigurationHandlers,
                                  completion: completion)
    }
    
    func show<Action>(title: String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style,
                      actions: [Action]) -> Observable<Action> where Action: AlertActionType {
        guard let message = message else { return Observable<Action>.empty() }
        return Observable<Action>.create { observer in
            let alert = Alert.makeAlertController(title: title,
                                                  message: message,
                                                  preferredStyle: preferredStyle,
                                                  actions: actions,
                                                  textFieldConfigurationHandlers: []) { action in
                observer.onNext(action)
                observer.onCompleted()
            }
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }

//    @discardableResult
//    private static func makeAlertController<Action>(title: String?,
//                                                    message: String?,
//                                                    preferredStyle: UIAlertController.Style,
//                                                    actions: [Action],
//                                                    completion: ((Action) -> Void)?) -> UIAlertController where Action: AlertActionType {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
//
//        for action in actions {
//            let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
//                completion?(action)
//            }
//            alert.addAction(alertAction)
//        }
//
//        UIApplication.topViewController?.present(alert, animated: true, completion: nil)
//
//        return alert
//    }
    
    @discardableResult
    private static func makeAlertController<Action>(title: String?,
                                                    message: String?,
                                                    preferredStyle: UIAlertController.Style,
                                                    actions: [Action],
                                                    textFieldConfigurationHandlers: [TextfieldHandler],
                                                    completion: ((Action) -> Void)?) -> UIAlertController where Action: AlertActionType {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)

        for action in actions {
            let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                
                completion?(action)
            }
            alert.addAction(alertAction)
        }
        
        for textFieldConfigure in textFieldConfigurationHandlers {
            alert.addTextField(configurationHandler: textFieldConfigure)
        }

        UIApplication.topViewController?.present(alert, animated: true, completion: nil)

        return alert
    }
}
