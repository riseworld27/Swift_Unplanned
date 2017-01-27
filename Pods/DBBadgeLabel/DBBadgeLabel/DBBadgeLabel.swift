//
//  DBBadgeLabel.swift
//
//  Copyright (c) 2015 Daniel Byon
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

private let _defaultHorizontalPadding = CGFloat(6.0)
private let _defaultVerticalPadding = CGFloat(2.0)

@IBDesignable
public class DBBadgeLabel: UILabel {
    
    /// Set this to set the rounded corner radius. It is not recommended to set this value higher than half the label's height.
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    /// Controls the amount of horizontal padding before/after the text. Default is 6.0 points, setting this value to zero results in the default UILabel behavior
    @IBInspectable
    public var horizontalPadding: CGFloat = _defaultHorizontalPadding {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    /// Controls the amount of vertical padding above/below the text. Default is 2.0 points, setting this value to zero results in the default UILabel behavior
    @IBInspectable
    public var verticalPadding: CGFloat = _defaultVerticalPadding {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    public convenience init(cornerRadius: CGFloat, textColor: UIColor = .blackColor(), backgroundColor: UIColor? = nil) {
        self.init(frame: CGRectZero)
        self.cornerRadius = cornerRadius
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
    
    public override func intrinsicContentSize() -> CGSize {
        let size = super.intrinsicContentSize()
        return CGSizeMake(size.width + 2 * horizontalPadding, size.height + 2 * verticalPadding)
    }
    
}
