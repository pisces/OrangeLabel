//
//  UILabel+OrangeLabel.swift
//  OrangeLabel
//
//  Created by Steve Kim on 09/04/2017.
//  Copyright © 2016 Steve Kim. All rights reserved.
//

import UIKit

public enum UILabelLinkType {
    case mention
    case hashtag
    case url
    case custom(pattern: String)
    
    public var pattern: String {
        switch self {
        case .mention: return "@[a-z0-9_-]+"
        case .hashtag: return "#[a-z0-9_-]+"
        case .url: return "(((https|http)://)|)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        case .custom(let regex): return regex
        }
    }
}

public struct TouchedLink {
    public var type: UILabelLinkType
    public var range: NSRange
    public var rect: CGRect
    public var string: String
}

extension UILabel {
    
    // MARK: - Constants
    
    private struct AssociatedKeys {
        static var AttributesMapName = "AttributesMapName"
    }
    
    // MARK: - Properties
    
    private var attributesMap: [String: [String: Any]] {
        get {
            if let attributesMap = objc_getAssociatedObject(self, &AssociatedKeys.AttributesMapName) as? [String: [String: Any]] {
                return attributesMap
            }
            let attributesMap = [String: [String: Any]]()
            objc_setAssociatedObject(self, &AssociatedKeys.AttributesMapName, attributesMap, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return attributesMap
        }
        set(value) {
            objc_setAssociatedObject(self, &AssociatedKeys.AttributesMapName, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private var mutableAttributedText: NSMutableAttributedString? {
        return attributedText as? NSMutableAttributedString
    }
    
    var adjustedFontSize: CGFloat {
        guard let attributedText = attributedText else {return font.pointSize}
        let context = NSStringDrawingContext()
        context.minimumScaleFactor = minimumScaleFactor;
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        mutable.setAttributes([NSFontAttributeName: font], range: NSMakeRange(0, mutable.length))
        mutable.boundingRect(with: bounds.size, options: .usesLineFragmentOrigin, context: context)
        return font.pointSize * context.actualScaleFactor;
    }
    var lineRanges: [String] {
        guard let attributedText = attributedText else {return []}
        
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        mutable.setAttributes([NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: font.withSize(adjustedFontSize)], range: NSMakeRange(0, mutable.length))
        
        let frameSetter = CTFramesetterCreateWithAttributedString(mutable)
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        let lines = CTFrameGetLines(frame) as! [CTLine]
    
        return lines.map {
            let lineRange = CTLineGetStringRange($0)
            var range = NSMakeRange(lineRange.location, lineRange.length)
            if (self.lineBreakMode == .byTruncatingHead ||
                self.lineBreakMode == .byTruncatingMiddle ||
                self.lineBreakMode == .byTruncatingTail) &&
                $0 === lines.last {
                range.length = mutable.length - range.location
            }
            return NSStringFromRange(range)
        }
    }
    
    // MARK: - Public methods
    
    public func boundingRect(forRange range: NSRange) -> CGRect {
        guard let attributedText = attributedText else {return .zero}
        
        let layoutManager = NSLayoutManager()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addLayoutManager(layoutManager)
        textStorage.addAttribute(NSFontAttributeName, value: font.withSize(self.adjustedFontSize), range: NSMakeRange(0, textStorage.length))
        textStorage.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, textStorage.length))
        
        let textContainer = NSTextContainer(size: CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        layoutManager.addTextContainer(textContainer)
        
        var glyphRange = NSRange()
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        let textRect = textStorage.boundingRect(with: bounds.size, options: .usesLineFragmentOrigin, context: nil)
        var rect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        rect.origin.y += max(0, (bounds.size.height - textRect.size.height)/2)
        return rect
    }
    public func contains(_ touch: UITouch, pattern: String?) -> Bool {
        var contains: Bool = false
        forEach(forPattern: pattern) {
            if boundingRect(forRange: $0.range).contains(touch.location(in: self)) {
                contains = true
                return
            }
        }
        return contains
    }
    public func contains(_ touch: UITouch, type: UILabelLinkType) -> Bool {
        return contains(touch, pattern: type.pattern)
    }
    @discardableResult
    public func setAttributes(_ attributes: [String: Any], type: UILabelLinkType) -> Self {
        attributesMap[type.pattern] = attributes
        updateAttributes(forType: type)
        return self
    }
    public func touched(_ touch: UITouch?, type: UILabelLinkType) -> [TouchedLink] {
        guard let touch = touch, let text = text else {return []}
        var results = [TouchedLink]()
        forEach(forPattern: type.pattern) {
            let rect = boundingRect(forRange: $0.range)
            if rect.contains(touch.location(in: self)) {
                let string = text.substring(with: text.range(from: $0.range)!)
                results.append(TouchedLink(type: type, range: $0.range, rect: rect, string: string))
            }
        }
        return results
    }
    
    // MARK - Internal methods
    
    final func forEach(forPattern pattern: String?, execution: (NSTextCheckingResult) -> Void) {
        guard let text = text, let pattern = pattern else {return}
        try? text.matches(pattern: pattern).forEach { execution($0) }
    }
    final func updateAttributes(forType type: UILabelLinkType) {
        guard let attributes = attributesMap[type.pattern] else {return}
        forEach(forPattern: type.pattern) {
            self.mutableAttributedText?.setAttributes(attributes, range: $0.range)
        }
    }
}
