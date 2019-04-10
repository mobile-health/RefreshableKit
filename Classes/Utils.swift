//
//  Utils.swift
//  RefreshableKit
//
//  Created by Hoangtaiki on 5/5/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import Foundation
import ObjectiveC

struct Constants {
    static let keyPathOffSet = "contentOffset"
    static let keyPathPanState = "state"
    static let keyPathContentSize = "contentSize"

    static let defaultHeaderHeight: CGFloat = 50.0
    static let defaultFooterHeight: CGFloat = 50.0

    static let headerTag = 3121992
    static let footerTag = 3121993
}

@objc class AttachObject: NSObject {
    init(closure: @escaping () -> ()) {
        onDeinit = closure
        super.init()
    }

    var onDeinit: () -> ()

    deinit {
        onDeinit()
    }
}

public extension UIScrollView {
    func invalidateRefreshControls() {
        let tags = [Constants.headerTag, Constants.footerTag]
        tags.forEach { tag in
            let oldContain = self.viewWithTag(tag)
            oldContain?.removeFromSuperview()
        }
    }

    func configAssociatedObject(object: AnyObject) {
        guard objc_getAssociatedObject(object, &AssociatedObject.key) == nil else {
            return
        }

        let attach = AttachObject { [weak self] in
            self?.invalidateRefreshControls()
        }
        objc_setAssociatedObject(object, &AssociatedObject.key, attach, .OBJC_ASSOCIATION_RETAIN)
    }
}

struct AssociatedObject {
    static var key: UInt8 = 0
}

func <= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    case (nil, _?):
        return true
    default:
        return false
    }
}

func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
