//
//  UIScrollView+PullToRefresh.swift
//  RefreshableKit
//
//  Created by Hoangtaiki on 5/5/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import Foundation

public extension UIScrollView {
    func addPullToRefresh(with refresher: UIView & PullToRefreshable = DefaultPullToRefreshView.header(),
                          container object: AnyObject,
                          action: @escaping () -> ()) {
        removeAllOldContainer()
        
        // Create Header Container
        let refreshHeight = refresher.headerHeight
        
        let containerFrame = CGRect(x: 0, y: -refreshHeight, width: frame.width, height: refreshHeight)
        let container = PullToRefreshContainer(frame: containerFrame)
        container.tag = Constants.headerTag
        container.delegate = refresher
        container.refreshAction = action
        addSubview(container)
        
        // Setup position then add refresher into container
        let bounds = CGRect(x: 0, y: containerFrame.height - refreshHeight, width: frame.width, height: refreshHeight)
        refresher.frame = bounds
        refresher.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(refresher)
        
        configAssociatedObject(object: object)
    }
    
    func startPullToRefreshAnimating() {
        let header = viewWithTag(Constants.headerTag) as? PullToRefreshContainer
        header?.beginRefreshing()
    }
    
    func stopPullToRefreshAnimating() {
        let header = viewWithTag(Constants.headerTag) as? PullToRefreshContainer
        header?.endRefreshing()
    }
    
    private func removeAllOldContainer() {
        let oldContain = viewWithTag(Constants.headerTag)
        oldContain?.removeFromSuperview()
    }
}
