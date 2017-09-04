//
//  UIView+SimpleLayout.swift
//  SimpleLayout
//
//  Created by pisces on 9/7/16.
//  Copyright © 2016 Steve Kim. All rights reserved.
//

import UIKit

public extension UIView {
    
    // MARK: - Struct
    
    private struct AssociatedKeys {
        static var LayoutName = "LayoutName"
    }
    
    // MARK: - Properties
    
    private(set) public var layout: SimpleLayoutObject {
        get {
            if let layout = objc_getAssociatedObject(self, &AssociatedKeys.LayoutName) as? SimpleLayoutObject {
                return layout
            }
            translatesAutoresizingMaskIntoConstraints = false
            
            let layout = SimpleLayoutObject(view: self)
            objc_setAssociatedObject(self, &AssociatedKeys.LayoutName, layout, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return layout
        }
        set(value) {
            objc_setAssociatedObject(self, &AssociatedKeys.LayoutName, layout, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var right: CGFloat {
        return frame.maxX
    }
    public var bottom: CGFloat {
        return frame.maxY
    }
    public var x: CGFloat {
        get {
            return frame.minX
        }
        set(value) {
            frame = CGRect(x: value, y: frameOrigin.y, width: frameSize.width, height: frameSize.height)
        }
    }
    public var y: CGFloat {
        get {
            return frame.minY
        }
        set(value) {
            frame = CGRect(x: frameOrigin.x, y: value, width: frameSize.width, height: frameSize.height)
        }
    }
    public var height: CGFloat {
        get {
            return frame.height
        }
        set(value) {
            frame = CGRect(x: frameOrigin.x, y: frameOrigin.y, width: frameSize.width, height: value)
        }
    }
    public var width: CGFloat {
        get {
            return frame.width
        }
        set(value) {
            frame = CGRect(x: frameOrigin.x, y: frameOrigin.y, width: value, height: frameSize.height)
        }
    }
    public var frameOrigin: CGPoint {
        get {
            return frame.origin
        }
        set(value) {
            frame = CGRect(x: value.x, y: value.y, width: frame.size.width, height: frame.size.height)
        }
    }
    public var frameSize: CGSize {
        get {
            return frame.size
        }
        set(value) {
            frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: value.width, height: value.height)
        }
    }
}
