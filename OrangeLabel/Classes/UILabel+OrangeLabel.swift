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
    
    private var attributesMap: [String: [NSAttributedStringKey: Any]] {
        get {
            if let attributesMap = objc_getAssociatedObject(self, &AssociatedKeys.AttributesMapName) as? [String: [NSAttributedStringKey: Any]] {
                return attributesMap
            }
            let attributesMap = [String: [NSAttributedStringKey: Any]]()
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
        mutable.setAttributes([NSAttributedStringKey.font: font], range: NSMakeRange(0, mutable.length))
        mutable.boundingRect(with: bounds.size, options: .usesLineFragmentOrigin, context: context)
        return font.pointSize * context.actualScaleFactor;
    }
    var lineRanges: [String] {
        guard let attributedText = attributedText else {return []}
        
        let mutable = NSMutableAttributedString(attributedString: attributedText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = adjustsFontSizeToFitWidth ? paragraphStyle.lineBreakMode : lineBreakMode
        
        mutable.setAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle, NSAttributedStringKey.font: font.withSize(adjustedFontSize)], range: NSMakeRange(0, mutable.length))
        
        let frameSetter = CTFramesetterCreateWithAttributedString(mutable)
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        let lines = CTFrameGetLines(frame) as! [CTLine]
    
        return lines.map {
            let lineRange = CTLineGetStringRange($0)
            var range = NSMakeRange(lineRange.location, lineRange.length)
            if (lineBreakMode == .byTruncatingHead ||
                lineBreakMode == .byTruncatingMiddle ||
                lineBreakMode == .byTruncatingTail) &&
                $0 === lines.last {
                range.length = mutable.length - range.location
            }
            return NSStringFromRange(range)
        }
    }
    
    // MARK: - Public methods
    
    public func boundingRect(forRange range: NSRange) -> CGRect {
        guard let layoutManager = createLayoutManager(),
            let textContainer = layoutManager.textContainers.first else {return .zero}
        var glyphRange = NSRange()
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    }
    public func characterIndex(forLocation location: CGPoint) -> Int {
        guard let layoutManager = createLayoutManager(),
            let textContainer = layoutManager.textContainers.first else {return -1}
        return layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
    }
    public func contains(_ touch: UITouch, pattern: String?) -> Bool {
        var contains: Bool = false
        for (_, value) in matches(forPattern: pattern) {
            if boundingRect(forRange: value.range).contains(touch.location(in: self)) {
                contains = true
                break
            }
        }
        return contains
    }
    public func contains(_ touch: UITouch, type: UILabelLinkType) -> Bool {
        return contains(touch, pattern: type.pattern)
    }
    @discardableResult
    public func setAttributes(_ attributes: [NSAttributedStringKey: Any], type: UILabelLinkType) -> Self {
        attributesMap[type.pattern] = attributes
        updateAttributes(forType: type)
        return self
    }
    public func touched(_ touch: UITouch?, type: UILabelLinkType) -> [TouchedLink] {
        guard let touch = touch, let text = text else {return []}
        var results = [TouchedLink]()
        for (_, value) in matches(forPattern: type.pattern) {
            let index = characterIndex(forLocation: touch.location(in: self))
            if index >= value.range.location, index <= value.range.location + value.range.length {
                let rect = boundingRect(forRange: value.range)
                let string = text.substring(with: text.range(from: value.range)!)
                results.append(TouchedLink(type: type, range: value.range, rect: rect, string: string))
            }
        }
        return results
    }
    
    // MARK - Internal methods
    
    final func matches(forPattern pattern: String?) -> EnumeratedSequence<Array<NSTextCheckingResult>> {
        guard let text = text, let pattern = pattern else {return [].enumerated()}
        do {
            return try text.matches(pattern: pattern).enumerated()
        } catch {
            return [].enumerated()
        }
    }
    final func setAttributedString(_ attributedString: NSMutableAttributedString, for type: UILabelLinkType) {
        guard let attributes = attributesMap[type.pattern] else {return}
        for (_, value) in matches(forPattern: type.pattern) {
            attributedString.setAttributes(attributes, range: value.range)
        }
    }
    final func updateAttributes(forType type: UILabelLinkType) {
        guard let attributes = attributesMap[type.pattern] else {return}
        for (_, value) in matches(forPattern: type.pattern) {
            mutableAttributedText?.setAttributes(attributes, range: value.range)
        }
    }
    
    // MARK - Private methods
    
    private func advancedPoint(forTextStorage textStorage: NSTextStorage) -> CGPoint {
        let textRect = textStorage.boundingRect(with: bounds.size, options: .usesLineFragmentOrigin, context: nil)
        return CGPoint(x: max(0, (bounds.size.width - textRect.size.width)/2), y: max(0, (bounds.size.height - textRect.size.height)/2))
    }
    private func createLayoutManager() -> NSLayoutManager? {
        guard let attributedText = attributedText else {return nil}
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.layoutManager = layoutManager
        
        layoutManager.addTextContainer(textContainer)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addLayoutManager(layoutManager)
        textStorage.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, textStorage.length))
        textStorage.addAttribute(NSAttributedStringKey.font, value: font.withSize(adjustedFontSize), range: NSMakeRange(0, textStorage.length))
        return layoutManager
    }
}
