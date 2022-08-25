//
//  Array+LayoutAdditions.swift
//
//  Copyright (c) 2017 Junfeng Zhang All rights reserved.
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

import UIKit

enum LayoutAxis {
    case x
    case y
    case undefine
}

extension Array where Element: UIView {
    func distributeViewsAlongAxis(_ axis: LayoutAxis, fixedItemLength: CGFloat, edgeInsets: UIEdgeInsets) {
        assert(count >= 1, "views to distribute need at least one item")
        
        let superview = first!.superview!
        var constrains: [NSLayoutConstraint] = []
        var prev: UIView?
        
        if axis == .x {
            forEach { (subview) in
                let leadingAnchor = prev != nil ? prev!.trailingAnchor : superview.leadingAnchor
                
                constrains.append(subview.leadingAnchor.constraint(equalTo: leadingAnchor))
                constrains.append(subview.widthAnchor.constraint(equalToConstant: fixedItemLength))
                constrains.append(subview.topAnchor.constraint(equalTo: subview.topAnchor, constant: edgeInsets.top))
                constrains.append(subview.bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: -edgeInsets.bottom))
                
                prev = subview
            }
            
            let trailing = prev!.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -edgeInsets.right)
            trailing.priority = .defaultHigh
            
            constrains.append(trailing)
        } else if axis == .y {
            forEach { (subview) in
                let topAnchor = prev != nil ? prev!.bottomAnchor : superview.topAnchor
                
                constrains.append(subview.topAnchor.constraint(equalTo: topAnchor))
                constrains.append(subview.heightAnchor.constraint(equalToConstant: fixedItemLength))
                constrains.append(subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: edgeInsets.left))
                constrains.append(subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -edgeInsets.right))
                
                prev = subview
            }
            
            let trailing = prev!.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -edgeInsets.bottom)
            trailing.priority = .defaultHigh
            
            constrains.append(trailing)
        }
        
        NSLayoutConstraint.activate(constrains)
    }
}
