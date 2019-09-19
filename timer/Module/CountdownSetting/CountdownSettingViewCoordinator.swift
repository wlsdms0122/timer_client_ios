//
//  CountdownSettingViewCoordinator.swift
//  timer
//
//  Created by JSilver on 19/09/2019.
//  Copyright © 2019 Jeong Jin Eun. All rights reserved.
//

import UIKit

class CountdownSettingViewCoordinator: CoordinatorProtocol {
    // MARK: - route enumeration
    enum CountdownSettingRoute {
        case empty
    }
    
    // MARK: - properties
    weak var viewController: UIViewController!
    let provider: ServiceProviderProtocol
    
    // MARK: - constructor
    required init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    // MARK: - presentation
    func present(for route: CountdownSettingRoute) -> UIViewController? {
        return get(for: route)
    }
    
    func get(for route: CountdownSettingRoute) -> UIViewController? {
        return nil
    }
}
