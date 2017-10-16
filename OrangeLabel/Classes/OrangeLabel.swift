//
//  OrangeLabel.swift
//  OrangeLabel
//
//  Created by Steve Kim on 09/04/2017.
//  Copyright © 2016 Steve Kim. All rights reserved.
//

import UIKit

public typealias LinkTappedClosure = (TouchedLink) -> Void

public class OrangeLabel: UILabel {
    
    // MARK: - Properties
    
    private var initializedSubviews: Bool = false
    private var isShowPlaceholder: Bool {
        return placeholder != nil && (_text == nil || _text!.characters.count < 1)
    }
    private var scaledLineBackgroundInset: UIEdgeInsets {
        let scale = adjustedFontSize / font!.pointSize
        return UIEdgeInsetsMake(lineBackgroundInset.top * scale, lineBackgroundInset.left * scale, lineBackgroundInset.bottom * scale, lineBackgroundInset.right * scale)
    }
    private var linkTappedClosure: LinkTappedClosure?
    private var _text: String?
    private var _textColor: UIColor?
    private var _font: UIFont?
    private var highlightedLinkColorMap = [String: UIColor]()
    private var highlightedLinkLayer: CAShapeLayer = {
        return CAShapeLayer()
    }()
    
    public var isHighlightedLinkColorEnabled: Bool = false
    public var lineBackgroundInset: UIEdgeInsets = .zero {
        didSet { setNeedsDisplay() }
    }
    public var placeholder: String? {
        didSet { setText() }
    }
    public var enabledLinkTypes: [UILabelLinkType] = []
    public var lineBackgroundColor: UIColor = .clear {
        didSet { setNeedsDisplay() }
    }
    public var placeholderTextColor: UIColor? {
        didSet { setTextColor() }
    }
    public var placeholderFont: UIFont? {
        didSet { setFont() }
    }
    
    // MARK: - Constructor
    
    convenience init() {
        self.init(frame: .zero)
        
        initProperties()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initProperties()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initProperties()
    }
    
    // MARK: - Overridden: UILabel
    
    override public var text: String? {
        didSet {
            _text = text
            setText()
            updateAttributesAll()
        }
    }
    override public var attributedText: NSAttributedString? {
        didSet { updateAttributesAll() }
    }
    override public var textColor: UIColor? {
        didSet {
            _textColor = textColor
            setTextColor()
        }
    }
    override public var font: UIFont? {
        didSet {
            _font = font
            setFont()
            updateAttributesAll()
        }
    }
    
    override public func draw(_ rect: CGRect) {
        if let text = text, lineBackgroundColor != .clear {
            var maxHeight: CGFloat = 0
            let paths = UIBezierPath()
            lineRanges.forEach {
                var range = NSRangeFromString($0)
                let last = NSMakeRange(range.location + range.length - 1, 1)
                if let lastRange = text.range(from: last), let count = try? text.substring(with: lastRange).matches(pattern: "\\s").count, count > 0 {
                    range.length -= 1
                }
                
                let boundingRect = self.insetIncludedBoundingRect(forRange: range, maxHeight: maxHeight)
                maxHeight = boundingRect.size.height
                paths.append(UIBezierPath(rect: boundingRect))
            }
            paths.close()
            lineBackgroundColor.set()
            paths.fill()
        }
        
        super.draw(rect)
    }
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if !initializedSubviews {
            initializedSubviews = true
            setUpSubviews()
        }
        invalidateProperties()
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        highlightedLinkLayer.frame = bounds
    }
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if self.isHighlightedLinkColorEnabled,
            let link = self.touchedLink(with: touches),
            let color = self.highlightedLinkColorMap[link.type.pattern] {
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            CATransaction.setDisableActions(true)
            let path = UIBezierPath(rect: self.insetIncludedBoundingRect(forRange: link.range))
            self.highlightedLinkLayer.fillColor = color.cgColor
            self.highlightedLinkLayer.path = path.cgPath
            CATransaction.commit()
        }
    }
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        highlightedLinkLayer.path = nil
    }
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        highlightedLinkLayer.path = nil
        
        if let link = self.touchedLink(with: touches) {
            self.linkTappedClosure?(link)
        }
    }
    
    // MARK: - REView protocol
    
    func commitProperties() {
    }
    func initProperties() {
        _font = font
        _textColor = textColor
        layer.addSublayer(highlightedLinkLayer)
    }
    func setUpSubviews() {
    }
    final func invalidateProperties() {
        if superview != nil {
            commitProperties()
        }
    }
    final func validateProperties() {
        commitProperties()
    }
    
    // MARK: - Public methods
    
    public func insetIncludedBoundingRect(forRange range: NSRange, maxHeight: CGFloat = 0) -> CGRect {
        var boundingRect = self.boundingRect(forRange: range)
        let inset = scaledLineBackgroundInset
        let height: CGFloat = boundingRect.size.height + inset.top + inset.bottom
        boundingRect.origin.x -= inset.left
        boundingRect.origin.y -= inset.top
        boundingRect.size.width += inset.left + inset.right
        boundingRect.size.height = maxHeight > 0 ? min(maxHeight, height) : height
        return boundingRect
    }
    public func linkTapped(_ closure: @escaping LinkTappedClosure) {
        linkTappedClosure = closure
    }
    @discardableResult
    public func setHighlightedLinkColor(_ color: UIColor, type: UILabelLinkType) -> Self {
        highlightedLinkColorMap[type.pattern] = color
        return self
    }
    
    // MARK: - Private methods
    
    private func setFont() {
        super.font = isShowPlaceholder && placeholderFont != nil ? placeholderFont : _font
    }
    private func setText() {
        super.text = isShowPlaceholder ? placeholder : _text
        setFont()
        setTextColor()
    }
    private func setTextColor() {
        super.textColor = isShowPlaceholder && placeholderTextColor != nil ? placeholderTextColor : _textColor
    }
    private func touchedLink(with touches: Set<UITouch>) -> TouchedLink? {
        var link: TouchedLink?
        for (_, value) in enabledLinkTypes.enumerated() {
            let touched = self.touched(touches.first, type: value)
            if touched.count > 0 {
                link = touched.first
                break
            }
        }
        return link
    }
    private func updateAttributesAll() {
        enabledLinkTypes.forEach { updateAttributes(forType: $0) }
    }
}
