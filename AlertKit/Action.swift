//
//  Action.swift
//  Alarmer
//
//  Created by melvyn on 06/11/2017.
//  Copyright © 2017 NEET. All rights reserved.
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
