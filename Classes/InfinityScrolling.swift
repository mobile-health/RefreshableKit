//
//  InfinityScrolling.swift
//  RefreshableKit
//
//  Created by Hoangtaiki on 5/3/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import Foundation
import UIKit

enum InfinityScrollingState {
    case idle
    case refreshing
}

@objc public protocol InfinityScrollable: class {
    
    var footerHeight: CGFloat { get set }
    
    func didEndRefreshing()
    func didBeginRefreshing()
}


open class DefaultRefreshFooter: UIView, InfinityScrollable {
    
    open var footerHeight = Constants.defaultFooterHeight
    open let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    open static func footer() -> DefaultRefreshFooter {
        return DefaultRefreshFooter()
    }
    
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
    
    open func didBeginRefreshing() {
        isHidden = false
        spinner.startAnimating()
    }
    
    open func didEndRefreshing() {
        isHidden = true
        spinner.stopAnimating()
    }
    
}

class InfinityScrollingContainer: UIView {
    
    var isEnabled = true {
        didSet {
            if isEnabled != oldValue {
                !isEnabled ? self.hide() : self.show()
            }
        }
    }
    var refreshAction: (()->())?
    var attachedScrollView: UIScrollView!
    weak var delegate: InfinityScrollable?
    fileprivate var _state: InfinityScrollingState = .idle
    var state: InfinityScrollingState {
        get {
            return _state
        }
        set {
            guard newValue != _state else{
                return
            }
            _state =  newValue
            if newValue == .refreshing {
                DispatchQueue.main.async(execute: {
                    self.delegate?.didBeginRefreshing()
                    self.refreshAction?()
                })
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        autoresizingMask = .flexibleWidth
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard newSuperview != nil else {
            if !isHidden {
                var inset = attachedScrollView.contentInset
                inset.bottom = inset.bottom - self.frame.height
                attachedScrollView.contentInset = inset
            }
            return
        }
        
        guard newSuperview is UIScrollView else {
            return
        }
        
        attachedScrollView = newSuperview as? UIScrollView
        attachedScrollView.alwaysBounceVertical = true
        
        if !isHidden {
            var contentInset = attachedScrollView.contentInset
            contentInset.bottom = contentInset.bottom + self.frame.height
            attachedScrollView.contentInset = contentInset
        }
        
        frame = CGRect(x: 0, y: attachedScrollView.contentSize.height, width: frame.width, height: frame.height)
        addObservers()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if !isEnabled { return }
        
        if keyPath == Constants.keyPathOffSet {
            handleScrollOffSetChange(change)
        }
        
        if isHidden { return }

        if keyPath == Constants.keyPathPanState {
            handlePanStateChange(change)
        }
        
        if keyPath == Constants.keyPathContentSize {
            handleContentSizeChange(change)
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
        state = .idle
        delegate?.didEndRefreshing()
    }

    deinit{
        removeObservers()
    }
}

extension InfinityScrollingContainer {
    
    fileprivate func addObservers() {
        attachedScrollView?.addObserver(self, forKeyPath: Constants.keyPathOffSet, options: [.old,.new], context: nil)
        attachedScrollView?.addObserver(self, forKeyPath: Constants.keyPathContentSize, options:[.old,.new] , context: nil)
        attachedScrollView?.panGestureRecognizer.addObserver(self, forKeyPath: Constants.keyPathPanState, options:[.old, .new], context: nil)
    }
    
    fileprivate func removeObservers() {
        attachedScrollView?.removeObserver(self, forKeyPath: Constants.keyPathContentSize, context: nil)
        attachedScrollView?.removeObserver(self, forKeyPath: Constants.keyPathOffSet, context: nil)
        attachedScrollView?.panGestureRecognizer.removeObserver(self, forKeyPath: Constants.keyPathPanState, context: nil)
    }
    
    fileprivate func handleScrollOffSetChange(_ change: [NSKeyValueChangeKey : Any]?) {
        if state != .idle && frame.origin.y != 0 {
            return
        }
        
        let insetTop = attachedScrollView.contentInset.top
        let contentHeight = attachedScrollView.contentSize.height
        let scrollViewHeight = attachedScrollView.frame.size.height
        
        if insetTop + contentHeight > scrollViewHeight {
            let offSetY = attachedScrollView.contentOffset.y
            if offSetY > self.frame.origin.y - scrollViewHeight + attachedScrollView.contentInset.bottom {
                let oldOffset = (change?[NSKeyValueChangeKey.oldKey] as AnyObject).cgPointValue
                let newOffset = (change?[NSKeyValueChangeKey.newKey] as AnyObject).cgPointValue
                if newOffset?.y <= oldOffset?.y {
                    return
                }
                
                beginRefreshing()
            }
        }
    }
    
    fileprivate func handlePanStateChange(_ change: [NSKeyValueChangeKey : Any]?) {
        guard state == .idle else { return }
        
        if attachedScrollView.panGestureRecognizer.state == .ended {
            let scrollInset = attachedScrollView.contentInset
            let scrollOffset = attachedScrollView.contentOffset
            let contentSize = attachedScrollView.contentSize
            
            if scrollInset.top + contentSize.height <= attachedScrollView.frame.height {
                if scrollOffset.y >= -1 * scrollInset.top {
                    beginRefreshing()
                }
            } else {
                if scrollOffset.y > contentSize.height + scrollInset.bottom - attachedScrollView.frame.height {
                    beginRefreshing()
                }
            }
        }
    }
    
    fileprivate func handleContentSizeChange(_ change: [NSKeyValueChangeKey : Any]?) {
        frame = CGRect(x: 0, y: attachedScrollView.contentSize.height, width: frame.size.width, height: frame.size.height)
    }
    
    fileprivate func hide() {
//        state = .idle
//        var inset = attachedScrollView.contentInset
//        inset.bottom = inset.bottom - frame.height
//        attachedScrollView.contentInset = inset

        isHidden = true
    }
    
    fileprivate func show() {
//        var contentInset = attachedScrollView.contentInset
//        contentInset.bottom = contentInset.bottom + frame.height
//        attachedScrollView.contentInset = contentInset
//        
//        frame = CGRect(x: 0,
//                       y: attachedScrollView.contentSize.height,
//                       width: frame.width,
//                       height: frame.height)
        
        isHidden = false
    }
}

