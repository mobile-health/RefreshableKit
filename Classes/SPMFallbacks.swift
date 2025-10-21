// This file provides a minimal shim for projects that use Swift Package Manager
// where `SWActivityIndicatorView` (a CocoaPods library) may not be available.
// The real `SWActivityIndicatorView` contains more features; this shim only
// implements the interface used by RefreshableKit so the package builds
// without adding an external dependency.

import UIKit

// Only define the type if the module isn't imported via CocoaPods.
#if canImport(SWActivityIndicatorView)
// When the real module is available, nothing to do.
#else
@objc open class SWActivityIndicatorView: UIView {
    @objc open var lineWidth: CGFloat = 2 {
        didSet {}
    }
    @objc fileprivate(set) open var isAnimating: Bool = false
    @objc open var autoStartAnimating: Bool = false {
        didSet {
            if autoStartAnimating && self.superview != nil {
                startAnimating()
            }
        }
    }
    @objc open var hidesWhenStopped: Bool = false
    @objc open var color: UIColor = .lightGray {
        didSet {}
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc open func startAnimating() {
        isAnimating = true
    }

    @objc open func stopAnimating() {
        isAnimating = false
    }
}
#endif
