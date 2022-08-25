//
//  Proxy.swift
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

class DelegateProxy: NSObject {
    
    var preferredStyle: UIAlarmer.Style = .alert
    var models: [Any] = []
    var cellFactory: ((UITableView, IndexPath, Any) -> UITableViewCell)?
    var textFieldReturn: ((UITextField) -> Bool)?
    var itemSelected: ((Any) -> Void)?
    
    init(preferredStyle: UIAlarmer.Style = .alert, models: [Any] = [], cellFactory: ((UITableView, IndexPath, Any) -> UITableViewCell)? = nil, textFieldReturn: ((UITextField) -> Bool)? = nil, itemSelected: ((Any) -> Void)? = nil) {
        self.preferredStyle = preferredStyle
        self.models = models
        self.cellFactory = cellFactory
        self.textFieldReturn = textFieldReturn
        self.itemSelected = itemSelected
    }
}

extension DelegateProxy: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let contains = models.contains {
            guard let model = $0 as? UIAlarmer.Action, model.style == .cancel else { return false }
            return true
        }
        if preferredStyle == .actionSheet && contains {
            return models.count - 1
        }
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        precondition(cellFactory != nil)
        return cellFactory!(tableView, indexPath, models[indexPath.row])
    }
}

extension DelegateProxy: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = models[indexPath.row]
        itemSelected?(action)
    }
}

extension DelegateProxy: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldReturn?(textField) ?? true
    }
}

extension DelegateProxy: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator.init(preferredStyle: preferredStyle)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator.init(preferredStyle: preferredStyle)
    }
}
