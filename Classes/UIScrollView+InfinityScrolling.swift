//
//  UIScrollView+InfinityScrolling.swift
//  RefreshableKit
//
//  Created by Hoangtaiki on 5/3/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import Foundation
import UIKit

public extension UIScrollView {
    public func addInfiniteScrolling(with refrehser: UIView & InfinityScrollable = DefaultRefreshFooter.footer(),
                                     container object: AnyObject,
                                     action: @escaping () -> ()) {
        self.removeAllOldContainer()
        
        let containerSize = CGSize(width: frame.size.width, height: refrehser.footerHeight)
        let containComponent = InfinityScrollingContainer(frame: CGRect(origin: .zero, size: containerSize))
        containComponent.tag = Constants.footerTag
        containComponent.refreshAction = action
        containComponent.delegate = refrehser
        insertSubview(containComponent, at: 0)
        
        refrehser.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        refrehser.frame = containComponent.bounds
        containComponent.addSubview(refrehser)
        
        configAssociatedObject(object: object)
    }
    
    public func startScrollingAnimating() {
        let footer = self.viewWithTag(Constants.footerTag) as? InfinityScrollingContainer
        footer?.beginRefreshing()
    }
    
    public func stopScrollingAnimating() {
        let footer = self.viewWithTag(Constants.footerTag) as? InfinityScrollingContainer
        footer?.endRefreshing()
    }
    
    public func setScrollingEnabled(_ enable: Bool) {
        let footer = self.viewWithTag(Constants.footerTag) as? InfinityScrollingContainer
        footer?.isEnabled = enable
    }
    
    private func removeAllOldContainer() {
        let oldContain = viewWithTag(Constants.footerTag)
        oldContain?.removeFromSuperview()
    }
}
