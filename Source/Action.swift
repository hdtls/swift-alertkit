//
//  Action.swift
//
//  Copyright (c) 2017 NEET. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import UIKit.UIFont
import UIKit.NSParagraphStyle
import UIKit.UIColor

/// Enum that specifies the style of the actions
public enum ActionStyle: Int {
    case `default`
    case cancel
    case destructive
}

public class Action: NSObject {
    public let title: String
    public let attributedTitle: NSAttributedString

    var handler: ((Action) -> Void)? = nil
    
    public var isEnabled: Bool = true
    public let style: ActionStyle
    
    
    /// Initialize a action by given it's title, style and handler
    ///
    /// - Parameters:
    ///   - title: The title that action will display
    ///   - style: The style of the action
    ///   - handler: The action handler for action, a block that will be fired when action selected
    public convenience init(title: String, style: ActionStyle, handler: ((Action) -> Void)?) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedStringKey : Any] = [
            .font : UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor : style == .destructive ? #colorLiteral(red: 0.6470588235, green: 0, blue: 0.05098039216, alpha: 1) : .black,
            .paragraphStyle : paragraphStyle
        ]
        
        self.init(attributedTitle: NSAttributedString.init(string: title, attributes: attributes), style: style, handler: handler)
    }
    
    /// Initialize a action by given it's attributed title, style and handler
    ///
    /// - Parameters:
    ///   - attributedTitle: The attributed title that action will display
    ///   - style: The style of the action
    ///   - handler: The action handler for action, a block that will be fired when action selected
    public init(attributedTitle: NSAttributedString, style: ActionStyle, handler: ((Action) -> Void)?) {
        self.style = style
        self.attributedTitle = attributedTitle
        self.title = attributedTitle.string
        
        self.handler = handler
    }
}
