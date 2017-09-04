//
//  SimpleLayoutObject.swift
//  SimpleLayout
//
//  Created by pisces on 02/01/2017.
//  Copyright © 2016 Steve Kim. All rights reserved.
//
//

import UIKit

public class SimpleLayoutObject: NSObject {
    
    // MARK: - Properties
    
    private weak var view: UIView!
    
    private(set) public var constraints = NSLayoutConstraints()
    
    // MARK: - Con(De)structor
    
    convenience public init(view: UIView) {
        self.init()
        
        self.view = view
    }
    
    // MARK: - Public methods
    
    public func apply() {
        view.layoutIfNeeded()
        view.superview?.layoutIfNeeded()
    }
    
    @discardableResult
    public func bottom(by target: UIView? = nil, attribute: NSLayoutAttribute = .bottom, multiplier: CGFloat = 1.0, _ constant: CGFloat = 0) -> SimpleLayoutObject {
        removeBottom()
        
        let targetView = target != nil ? target! : view.superview
        constraints.bottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: targetView, attribute: attribute, multiplier: multiplier, constant: constant)
        constraints.bottom?.isActive = true
        return self
    }
    @discardableResult
    public func center(by target: UIView? = nil, centerX: Bool = true, centerY: Bool = true, x: CGFloat = 0, y: CGFloat = 0) -> SimpleLayoutObject {
        if centerX {
            self.centerX(by: target, x)
        }
        if centerY {
            self.centerY(by: target, y)
        }
        return self
    }
    @discardableResult
    public func centerX(by target: UIView? = nil, multiplier: CGFloat = 1.0, _ constant: CGFloat = 0) -> SimpleLayoutObject {
        removeHorizontalConstraints()
        
        let targetView = target != nil ? target! : view.superview
        constraints.centerX = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: targetView, attribute: .centerX, multiplier: multiplier, constant: constant)
        constraints.centerX?.isActive = true
        return self
    }
    @discardableResult
    public func centerY(by target: UIView? = nil, multiplier: CGFloat = 1.0, _ constant: CGFloat = 0) -> SimpleLayoutObject {
        removeVerticalConstraints()
        
        let targetView = target != nil ? target! : view.superview
        constraints.centerY = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: targetView, attribute: .centerY, multiplier: multiplier, constant: constant)
        constraints.centerY?.isActive = true
        return self
    }
    @discardableResult
    public func trailing(by target: UIView? = nil, attribute: NSLayoutAttribute = .trailing, relation: NSLayoutRelation = .equal, multiplier: CGFloat = 1.0, _ constant: CGFloat = 0) -> SimpleLayoutObject {
        removeTrailing()
        
        let targetView = target != nil ? target! : view.superview
        constraints.trailing = NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: relation, toItem: targetView, attribute: attribute, multiplier: multiplier, constant: constant)
        constraints.trailing?.isActive = true
        return self
    }
    @discardableResult
    public func fill(matchParent: Bool = false, multiplier: CGFloat = 1.0, leading: CGFloat = 0, top: CGFloat = 0, trailing: CGFloat = 0, bottom: CGFloat = 0) -> SimpleLayoutObject {
        removeHorizontalConstraints()
        removeVerticalConstraints()
        
        if matchParent {
            self.leading(multiplier: multiplier, leading)
            self.top(multiplier: multiplier, top)
            self.width(multiplier: multiplier, -(leading + trailing))
            self.height(multiplier: multiplier, -(top + bottom))
        } else {
            self.leading(multiplier: multiplier, leading)
            self.top(multiplier: multiplier, top)
            self.trailing(multiplier: multiplier, trailing)
            self.bottom(multiplier: multiplier, bottom)
        }
        return self
    }
    @discardableResult
    public func height(by target: UIView? = nil, fixed: CGFloat = -1, relation: NSLayoutRelation = .equal, attribute: NSLayoutAttribute = .height, multiplier: CGFloat = 1.0, _ constant: CGFloat = 0) -> SimpleLayoutObject {
        if let height = constraints.height {
            view.removeConstraint(height)
            view.superview?.removeConstraint(height)
        }
        
        let targetView = target != nil ? target! : view.superview
        if fixed > -1 {
            constraints.height = NSLayoutConstraint(item: view, attribute: .height, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: multiplier, constant: fixed)
        } else {
            constraints.height = NSLayoutConstraint(item: view, attribute: .height, relatedBy: relation, toItem: targetView, attribute: attribute, multiplier: multiplier, constant: constant)
        }
        constraints.height?.isActive = true
        return self
    }
    @discardableResult
    public func leading(by target: UIView? = nil, attribute: NSLayoutAttribute = .leading, relation: NSLayoutRelation = .equal, multiplier: CGFloat = 1.0, _ constant: CGFloat = 0) -> SimpleLayoutObject {
        removeLeading()
        
        let targetView = target != nil ? target! : view.superview
        constraints.leading = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: relation, toItem: targetView, attribute: attribute, multiplier: multiplier, constant: constant)
        constraints.leading?.isActive = true
        return self
    }
    @discardableResult
    public func top(by target: UIView? = nil, attribute: NSLayoutAttribute = .top, multiplier: CGFloat = 1.0, _ constant: CGFloat = 0) -> SimpleLayoutObject {
        removeTop()
        
        let targetView = target != nil ? target! : view.superview
        constraints.top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: targetView, attribute: attribute, multiplier: multiplier, constant: constant)
        constraints.top?.isActive = true
        return self
    }
    @discardableResult
    public func width(by target: UIView? = nil, fixed: CGFloat = -1, relation: NSLayoutRelation = .equal, attribute: NSLayoutAttribute = .width, multiplier: CGFloat = 1.0, _ constant: CGFloat = 0) -> SimpleLayoutObject {
        if let width = constraints.width {
            view.removeConstraint(width)
            view.superview?.removeConstraint(width)
        }
        
        let targetView = target != nil ? target! : view.superview
        if fixed > -1 {
            constraints.width = NSLayoutConstraint(item: view, attribute: .width, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: multiplier, constant: fixed)
        } else {
            constraints.width = NSLayoutConstraint(item: view, attribute: .width, relatedBy: relation, toItem: targetView, attribute: attribute, multiplier: multiplier, constant: constant)
        }
        constraints.width?.isActive = true
        return self
    }
    
    // MARK: - Remove constraint
    
    @discardableResult
    public func removeBottom() -> SimpleLayoutObject {
        if let bottom = constraints.bottom {
            view.superview?.removeConstraint(bottom)
            constraints.bottom = nil
        }
        return self
    }
    @discardableResult
    public func removeCenterX() -> SimpleLayoutObject {
        if let centerX = constraints.centerX {
            view.superview?.removeConstraint(centerX)
            constraints.centerX = nil
        }
        return self
    }
    @discardableResult
    public func removeCenterY() -> SimpleLayoutObject {
        if let centerY = constraints.centerY {
            view.superview?.removeConstraint(centerY)
            constraints.centerY = nil
        }
        return self
    }
    @discardableResult
    public func removeLeading() -> SimpleLayoutObject {
        if let leading = constraints.leading {
            view.superview?.removeConstraint(leading)
            constraints.leading = nil
        }
        return self
    }
    @discardableResult
    public func removeTop() -> SimpleLayoutObject {
        if let top = constraints.top {
            view.superview?.removeConstraint(top)
            constraints.top = nil
        }
        return self
    }
    @discardableResult
    public func removeTrailing() -> SimpleLayoutObject {
        if let trailing = constraints.trailing {
            view.superview?.removeConstraint(trailing)
            constraints.trailing = nil
        }
        return self
    }
    
    // MARK: - Private methods
    
    private func removeHorizontalConstraints() {
        removeLeading()
        removeTrailing()
        removeCenterX()
    }
    private func removeVerticalConstraints() {
        removeTop()
        removeCenterY()
        removeBottom()
    }
}

public struct NSLayoutConstraints {
    public var array: [NSLayoutConstraint] {
        let _array: NSMutableArray = []
        appendConstraint(leading, toArray: _array)
        appendConstraint(top, toArray: _array)
        appendConstraint(trailing, toArray: _array)
        appendConstraint(bottom, toArray: _array)
        appendConstraint(height, toArray: _array)
        appendConstraint(width, toArray: _array)
        appendConstraint(centerX, toArray: _array)
        appendConstraint(centerY, toArray: _array)
        return _array as NSArray as! [NSLayoutConstraint]
    }
    public var leading: NSLayoutConstraint?
    public var top: NSLayoutConstraint?
    public var trailing: NSLayoutConstraint?
    public var bottom: NSLayoutConstraint?
    public var height: NSLayoutConstraint?
    public var width: NSLayoutConstraint?
    public var centerX: NSLayoutConstraint?
    public var centerY: NSLayoutConstraint?
    
    public init(leading: NSLayoutConstraint? = nil,
         top: NSLayoutConstraint? = nil,
         trailing: NSLayoutConstraint? = nil,
         bottom: NSLayoutConstraint? = nil,
         height: NSLayoutConstraint? = nil,
         width: NSLayoutConstraint? = nil,
         centerX: NSLayoutConstraint? = nil,
         centerY: NSLayoutConstraint? = nil) {
        self.leading = leading
        self.top = top
        self.trailing = trailing
        self.bottom = bottom
        self.height = height
        self.width = width
        self.centerX = centerX
        self.centerY = centerY
    }
    
    private func appendConstraint(_ constraint: NSLayoutConstraint?, toArray: NSMutableArray) {
        if let constraint = constraint {
            toArray.add(constraint)
        }
    }
}
