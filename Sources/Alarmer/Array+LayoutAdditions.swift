//
//  Array+LayoutAdditions.swift
//
//  Created by melvyn on 2018/7/25.
//  Copyright © 2018 NEET. All rights reserved.
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
            #if swift(>=4.0)
            trailing.priority = .defaultHigh
            #else
            trailing.priority = UILayoutPriority.init(750)
            #endif
            
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
            #if swift(>=4.0)
            trailing.priority = .defaultHigh
            #else
            trailing.priority = UILayoutPriority.init(750)
            #endif
            
            constrains.append(trailing)
        }
        
        NSLayoutConstraint.activate(constrains)
    }
}
