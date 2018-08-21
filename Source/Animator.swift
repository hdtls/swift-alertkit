//
//  Animator.swift
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

import UIKit

open class Animator: NSObject {
    public let preferredStyle: AlarmerStyle
    
    fileprivate var toViewYArchor: NSLayoutConstraint?
    fileprivate var observations: [NSObjectProtocol]?
    
    deinit {
        observations?.forEach {
            NotificationCenter.default.removeObserver($0)
        }
        observations = nil
    }
    
    public init(preferredStyle: AlarmerStyle) {
        self.preferredStyle = preferredStyle
    }
}

extension Animator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        guard let toVc = transitionContext?.viewController(forKey: .to) else {
            return 0
        }
        return toVc.isBeingPresented ? 0.15 : 0.3
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        
        var dimmingView: UIView?
        let duration: TimeInterval = transitionDuration(using: transitionContext)
        
        // Present
        if let toVc = transitionContext.viewController(forKey: .to), toVc.isBeingPresented {
            
            let fromView = transitionContext.view(forKey: .from) ?? transitionContext.viewController(forKey: .from)?.view
            fromView?.tintAdjustmentMode = .dimmed
            fromView?.isUserInteractionEnabled = false
            
            dimmingView = UIView.init(frame: container.bounds)
            dimmingView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            dimmingView?.layer.opacity = 0
            
            container.addSubview(dimmingView!)
            
            guard let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(true)
                return
            }
            
            toView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(toView)
            
            var constraints: [NSLayoutConstraint] = []
            constraints.append(
                NSLayoutConstraint(item: toView, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0)
            )
            
            if preferredStyle == .alert {
                constraints.append(contentsOf:
                    NSLayoutConstraint.constraints(withVisualFormat: "V:|->=10.0-[toView(>=44.0)]->=10.0-|", options: [], metrics: nil, views: ["toView" : toView])
                )
                constraints.append(contentsOf:
                    NSLayoutConstraint.constraints(withVisualFormat: "H:[toView(==270.0)]", options: [], metrics: nil, views: ["toView" : toView])
                )
                toViewYArchor = NSLayoutConstraint.init(item: toView, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0)
                constraints.append(toViewYArchor!)
                
                NSLayoutConstraint.activate(constraints)
                
                // Keyboard appearance
                observations = [
                    NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil, using: { [weak self](note) in
                        let duration = note.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
                        let aValue = note.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect ?? .zero
                        self?.toViewYArchor?.constant = -(aValue.height / 2)
                        UIView.animate(withDuration: duration, animations: {
                            container.layoutIfNeeded()
                        })
                    }),
                    NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil, using: { [weak self] note in
                        let duration = note.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
                        self?.toViewYArchor?.constant = 0
                        UIView.animate(withDuration: duration, animations: {
                            container.layoutIfNeeded()
                        })
                    })
                ]
                
                toView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.1)
                UIView.animateKeyframes(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                        toView.layer.transform = CATransform3DMakeScale(1.03, 1.03, 1.0)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                        toView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
                    })
                    dimmingView?.layer.opacity = 1
                }, completion: { (flag) in
                    transitionContext.completeTransition(flag)
                })
            } else {
                constraints.append(contentsOf:
                    NSLayoutConstraint.constraints(withVisualFormat: "V:|->=10.0-[toView(>=44.0)]-10.0-|", options: [], metrics: nil, views: ["toView" : toView])
                )
                constraints.append(contentsOf:
                    NSLayoutConstraint.constraints(withVisualFormat: "H:|-<=10.0@750-[toView(>=44.0,<=394.0)]-<=10.0@750-|", options: [], metrics: nil, views: ["toView" : toView])
                )
                NSLayoutConstraint.activate(constraints)
                
                toView.frame.origin.y = container.bounds.maxY
                UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
                    toView.frame.origin.y = container.bounds.midY
                    dimmingView?.layer.opacity = 1
                }, completion: { (flag) in
                    transitionContext.completeTransition(flag)
                })
                
                let transform = CABasicAnimation.init(keyPath: "transform")
                transform.duration = duration
                transform.fillMode = kCAFillModeForwards
                transform.isRemovedOnCompletion = false
                transform.fromValue = CATransform3DIdentity
                transform.toValue = CATransform3DMakeScale(0.9, 0.9, 0.9)
                fromView?.layer.add(transform, forKey: nil)
            }
        }
        
        // Dismiss
        if let fromVc = transitionContext.viewController(forKey: .from), fromVc.isBeingDismissed {
            
            guard let fromView = transitionContext.view(forKey: .from) else {
                transitionContext.completeTransition(true)
                return
            }
            
            let toView = transitionContext.viewController(forKey: .to)!.view!
            toView.tintAdjustmentMode = .normal
            toView.isUserInteractionEnabled = true
            dimmingView = container.subviews.first
            
            if preferredStyle == .alert {
                UIView.animate(withDuration: duration, animations: {
                    fromView.frame.origin.y = container.bounds.height
                    fromView.transform = CGAffineTransform(rotationAngle: -(.pi / 2))
                    dimmingView?.layer.opacity = 0
                }, completion: { (flag) in
                    transitionContext.completeTransition(flag)
                })
            } else {
                UIView.animate(withDuration: duration, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
                    fromView.frame.origin.y = container.bounds.maxY
                }, completion: { (flag) in
                    transitionContext.completeTransition(flag)
                })
                
                let transform = CABasicAnimation.init(keyPath: "transform")
                transform.duration = duration
                transform.fillMode = kCAFillModeForwards
                transform.isRemovedOnCompletion = false
                transform.toValue = CATransform3DIdentity
                //                transform.fromValue = CATransform3DMakeScale(0.9, 0.9, 0.9)
                toView.layer.add(transform, forKey: nil)
            }
        }
    }
}

