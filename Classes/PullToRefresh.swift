//
//  PullToRefresh.swift
//  RefreshableKit
//
//  Created by Hoangtaiki on 5/3/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import SWActivityIndicatorView
import UIKit

public enum PullToRefreshState: Int {
    case idle = 0
    case pulling
    case refreshing
}

// Three func below can use to display custom text on refresh view
public protocol PullToRefreshable: class {
    // Height of Header View
    var headerHeight: CGFloat { get set }
    // Duration of hide animation
    var animationDuration: Double { get set }
    // Method call when view start to refresh
    func didBeginRefresh()
    // Method call when view start to hide
    func didBeginHideAnimation()
    // Mothod call when view completed hide animation
    func didCompletedHideAnimation()
}

open class DefaultPullToRefreshView: UIView, PullToRefreshable {
    open class func header() -> DefaultPullToRefreshView {
        return DefaultPullToRefreshView()
    }
    
    open lazy var spinner: SWActivityIndicatorView = {
        let retVal = SWActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 25, height: 25)))
        retVal.backgroundColor = UIColor.clear
        retVal.lineWidth = 2
        retVal.autoStartAnimating = true
        retVal.hidesWhenStopped = false
        retVal.color = UIColor(red: 48 / 255, green: 161 / 255, blue: 249 / 255, alpha: 1)
        return retVal
    }()
    
    open var animationDuration = 0.5
    public var headerHeight = Constants.defaultHeaderHeight
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(spinner)
        isHidden = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        spinner.center = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func didBeginHideAnimation() {
        spinner.stopAnimating()
    }
    
    open func didCompletedHideAnimation() {
        isHidden = true
    }
    
    open func didBeginRefresh() {
        isHidden = false
        spinner.startAnimating()
    }
}

open class ActivityIndicatorPullToRefreshView: UIView, PullToRefreshable {
    open class func header() -> DefaultPullToRefreshView {
        return DefaultPullToRefreshView()
    }
    
    public let spinner = UIActivityIndicatorView(style: .gray)
    open var animationDuration = 0.5
    public var headerHeight = Constants.defaultHeaderHeight
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(spinner)
        isHidden = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        spinner.center = CGPoint(x: frame.size.width * 0.5, y: frame.size.height * 0.5)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func didBeginHideAnimation() {
        spinner.stopAnimating()
    }
    
    open func didCompletedHideAnimation() {
        isHidden = true
    }
    
    open func didBeginRefresh() {
        isHidden = false
        spinner.startAnimating()
    }
}

open class PullToRefreshContainer: UIView {
    var refreshAction: (() -> ())?
    var attachedScrollView: UIScrollView!
    var originalInset: UIEdgeInsets?
    var durationOfEndRefreshing = 0.4
    weak var delegate: PullToRefreshable?
    
    fileprivate var _state: PullToRefreshState = .idle
    fileprivate var insetTopDelta: CGFloat = 0.0
    fileprivate var state: PullToRefreshState {
        get {
            return _state
        }
        
        set {
            if newValue == _state { return }
            
            let oldValue = _state
            _state = newValue
            
            switch newValue {
            case .idle:
                guard oldValue == .refreshing else { return }
                
                DispatchQueue.main.async {
                    self.animateHide()
                }
                
            case .refreshing:
                DispatchQueue.main.async {
                    self.animateRefresh()
                }
            default:
                break
            }
        }
    }
    
    // MARK: - Init -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard newSuperview is UIScrollView else {
            return
        }
        
        attachedScrollView = newSuperview as? UIScrollView
        attachedScrollView.alwaysBounceVertical = true
        originalInset = attachedScrollView?.contentInset
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Constants.keyPathOffSet {
            handleScrollOffSetChange(change)
        }
    }
    
    func beginRefreshing() {
        if window != nil {
            state = .refreshing
        } else {
            if state != .refreshing {
                state = .idle
            }
        }
    }
    
    func endRefreshing() {
        delegate?.didBeginHideAnimation()
        state = .idle
    }
}

extension PullToRefreshContainer {
    fileprivate func commonInit() {
        backgroundColor = UIColor.clear
        autoresizingMask = .flexibleWidth
    }
    
    fileprivate func addObservers() {
        attachedScrollView?.addObserver(self, forKeyPath: Constants.keyPathOffSet, options: [.old, .new], context: nil)
    }
    
    fileprivate func removeObservers() {
        attachedScrollView?.removeObserver(self, forKeyPath: Constants.keyPathOffSet, context: nil)
    }
    
    fileprivate func handleScrollOffSetChange(_ change: [NSKeyValueChangeKey: Any]?) {
        let insetHeight = delegate!.headerHeight
        let fireHeight = delegate!.headerHeight
        
        if state == .refreshing {
            if window == nil { return }
            
            let offset = attachedScrollView.contentOffset
            let inset = originalInset!
            var oldInset = attachedScrollView.contentInset
            
            var insetTop = -offset.y > inset.top ? -offset.y : inset.top
            insetTop = insetTop > insetHeight + inset.top ? insetHeight + inset.top : insetTop
            oldInset.top = insetTop
            
            attachedScrollView.contentInset = oldInset
            insetTopDelta = inset.top - insetTop
            return
        }
        
        originalInset = attachedScrollView.contentInset
        let offsetY = attachedScrollView.contentOffset.y
        let pullingOffSetY = -originalInset!.top - fireHeight
        
        // When pull to refresh offsetY <= -originalInset!.top
        if offsetY >= -originalInset!.top {
            return
        }
        
        if attachedScrollView.isDragging {
            if state == .idle, offsetY < pullingOffSetY {
                state = .pulling
            } else if state == .pulling, offsetY >= pullingOffSetY {
                state = .idle
            }
            
        } else if state == .pulling {
            beginRefreshing()
            return
        }
    }
    
    fileprivate func animateHide() {
        UIView.animate(withDuration: durationOfEndRefreshing, animations: {
            var oldInset = self.attachedScrollView.contentInset
            oldInset.top = oldInset.top + self.insetTopDelta
            
            self.attachedScrollView.contentInset = oldInset
        }, completion: { _ in
            self.delegate?.didCompletedHideAnimation()
        })
    }
    
    fileprivate func animateRefresh() {
        let insetHeight = delegate!.headerHeight
        
        let offsetY = attachedScrollView.contentOffset.y
        let pullingOffSetY = -originalInset!.top - insetHeight
        let currentOffset = attachedScrollView.contentOffset
        
        UIView.animate(withDuration: 0.4, animations: {
            let top = self.originalInset!.top + insetHeight
            var oldInset = self.attachedScrollView.contentInset
            oldInset.top = top
            self.attachedScrollView.contentInset = oldInset
            
            if offsetY > pullingOffSetY {
                self.attachedScrollView.contentOffset = CGPoint(x: 0, y: -top)
            } else {
                self.attachedScrollView.contentOffset = currentOffset
            }
        }, completion: { _ in
            self.refreshAction?()
        })
        delegate?.didBeginRefresh()
    }
}
