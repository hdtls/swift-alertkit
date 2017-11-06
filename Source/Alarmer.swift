//
//  Alarmer.swift
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

/// Enum that specifies the style of the alert controller
@objc(MLVAlarmerStyle) public enum AlarmerStyle: Int {
    case actionSheet
    case alert
}

@objc(MLVAlarmerController) open class Alarmer: UIViewController {
    
    /// The style for Alarmer instance
    @objc open let preferredStyle: AlarmerStyle
    
    /// The textFields added to the Alarmer instance
    @objc open var textFields: [UITextField] { return _textFields }

    /// The actions added to the Alarmer instance
    @objc open var actions: [Action] { return _actions }
    
    /// The message for Alarmer instance
    @objc open var message: String?
    
    /// The backgoundColor of title view
    @objc open var tintColor: UIColor? = #colorLiteral(red: 0.268933624, green: 0.5639741421, blue: 0.8968726397, alpha: 1) {
        didSet {
            _tableView.reloadData()
        }
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return preferredStyle == .actionSheet ? .lightContent : .default
    }
    
    private var _tableView: UITableView!
    private var _extras: [Action] = []
    private var _actions: [Action] = []
    private var _textFields: [UITextField] = []
    private var _cornerRadius: CGFloat = 10
    private var _proxy: DelegateProxy = DelegateProxy()
    private var _viewLayoutHeight: NSLayoutConstraint?
    private var _observations: [NSObjectProtocol] = []
    private lazy var _accessoryView: UIButton = {
        let accessoryView = UIButton()
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        accessoryView.backgroundColor = #colorLiteral(red: 0.7140869498, green: 0.09332919866, blue: 0.04985838383, alpha: 1)
        accessoryView.setTitleColor(.white, for: .normal)
        accessoryView.layer.cornerRadius = _cornerRadius
        accessoryView.layer.masksToBounds = true
        accessoryView.isHidden = true
        return accessoryView
    }()
    
    deinit {
        _observations.forEach {
            if !($0 is NSKeyValueObservation) {
                NotificationCenter.default.removeObserver($0)
            }
        }
        _observations.removeAll()
    }
    
    @objc public convenience init() {
        self.init(attributedTitle: nil, message: nil, preferredStyle: .actionSheet)
    }
    
    /// Initialize Alarmer by given it's title, message and preferred style
    ///
    /// - Parameters:
    ///   - title: The title that Alarmer will display
    ///   - message: The message that Alarmer will display
    ///   - preferredStyle: See enum 'AlarmerStyle' for more info
    @objc public convenience init(title: String?, message: String?, preferredStyle: AlarmerStyle) {
        
        let _title = title == nil
            ? nil : NSAttributedString(string: title!, attributes: Alarmer.textAttributes(withTextStyle: .headline, foregroundColor: .white))
        let _message = message == nil
            ? nil : NSAttributedString(string: message!, attributes: Alarmer.textAttributes(withTextStyle: .body, foregroundColor: .black))
        
        self.init(attributedTitle: _title,
                  message: _message,
                  preferredStyle: preferredStyle)
    }
    
    
    /// Initialize Alarmer by given it's attributed title, message and preferred style
    ///
    /// - Parameters:
    ///   - attributedTitle: The attributed title that Alarmer will display
    ///   - message: The attributed message that Alarmer will display
    ///   - preferredStyle: See enum 'AlarmerStyle' for more info
    @objc public init(attributedTitle: NSAttributedString?, message: NSAttributedString?, preferredStyle: AlarmerStyle) {
        self.preferredStyle = preferredStyle
        
        super.init(nibName: nil, bundle: nil)
        
        _proxy.preferredStyle = preferredStyle
        
        _tableView = UITableView.init(frame: .zero, style: .plain)
        _tableView.translatesAutoresizingMaskIntoConstraints = false
        _tableView.isScrollEnabled = false
        _tableView.layer.masksToBounds = true
        _tableView.layer.cornerRadius = _cornerRadius
        _tableView.bounces = false
        _tableView.showsVerticalScrollIndicator = false
        _tableView.separatorInset = .zero
        _tableView.rowHeight = UITableViewAutomaticDimension
        _tableView.estimatedRowHeight = 44
        _tableView.tableFooterView = UIView()
        _tableView.register(cellType: TableViewCell.self)
        _tableView.dataSource = _proxy
        _tableView.delegate = _proxy
        
        self.title = attributedTitle?.string
        self.message = message?.string
        
        if attributedTitle != nil {
            let additionalAction = Action(attributedTitle: attributedTitle!, style: .default, handler: nil)
            additionalAction.isEnabled = false
            
            _extras.append(additionalAction)
        }
        
        if message != nil {
            let additionalAction = Action(title: message!.string, style: .default, handler: nil)
            additionalAction.isEnabled = false
            
            _extras.append(additionalAction)
        }
        
        transitioningDelegate = _proxy
        modalPresentationStyle = .custom
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        
        view.addSubview(_tableView)
        if preferredStyle == .actionSheet {
            view.addSubview(_accessoryView)
        }
        
        super.viewDidLoad()
        
        registerForLocalNotifications()
        
        updateViewLayout()
        
        _proxy.preferredStyle = preferredStyle
        _proxy.cellFactory = { [weak self](tableView, indexPath, action) in
            guard let strongSelf = self else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusable(withCellType: TableViewCell.self, for: indexPath)
            
            tableView.separatorStyle = indexPath.row < strongSelf._extras.count ? .none : .singleLine
            
            cell.selectionStyle = indexPath.row < strongSelf._extras.count ? .none : .default
            cell.contentView.backgroundColor = self?.title != nil && indexPath.row == 0 ? strongSelf.tintColor : .clear
            
            // Prepare for reuse
            cell.contentView.subviews.filter { $0 is UITextField }.forEach { $0.removeFromSuperview() }
            
            if let action = action as? Action {
                
                cell.selectedBackgroundView = action.style != .cancel ? nil : {
                    let backgroundView = UIView()
                    backgroundView.backgroundColor = #colorLiteral(red: 0.9992782474, green: 0.8981826901, blue: 0.9021043777, alpha: 1)
                    return backgroundView
                    }()
                cell.textLabel?.attributedText = action.attributedTitle
                cell.textLabel?.numberOfLines = indexPath.row == 1 ? 0 : 1
                cell.textLabel?.highlightedTextColor = action.style == .cancel ? #colorLiteral(red: 0.7140869498, green: 0.09332919866, blue: 0.04985838383, alpha: 1) : nil
            } else {
                // MARK: TextField
                var temporatory: UITextField?
                strongSelf.textFields.forEach({ (textField) in
                    cell.contentView.addSubview(textField)
                    
                    if let temporatory = temporatory {
                        NSLayoutConstraint.activate(
                            NSLayoutConstraint.constraints(
                                withVisualFormat: "V:[temporatory][textField(==temporatory)]",
                                options: .alignAllLeft,
                                metrics: nil,
                                views: ["temporatory" : temporatory, "textField" : textField]
                            )
                        )
                    } else {
                        NSLayoutConstraint.activate(
                            NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|-mergin-[textField(==h)]",
                                options: .alignAllLeft,
                                metrics: ["mergin" : cell.layoutMargins.top, "h" : 26],
                                views: ["textField" : textField]
                            )
                        )
                    }
                    
                    NSLayoutConstraint.activate(
                        NSLayoutConstraint.constraints(
                            withVisualFormat: "H:|-mergin-[textField]-mergin-|",
                            options: .alignAllLeft,
                            metrics: ["mergin" : cell.layoutMargins.left * 2],
                            views: ["textField" : textField]
                        )
                    )
                    
                    temporatory = textField
                })
                if let temporatory = temporatory {
                    let constraint = NSLayoutConstraint(
                        item: temporatory,
                        attribute: .bottom,
                        relatedBy: .equal,
                        toItem: cell.contentView,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: -cell.layoutMargins.bottom * 2
                    )
                    constraint.priority = .defaultHigh
                    constraint.isActive = true
                    
                    NSLayoutConstraint(
                        item: temporatory,
                        attribute: .bottom,
                        relatedBy: .greaterThanOrEqual,
                        toItem: cell.contentView,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: -cell.layoutMargins.bottom
                        ).isActive = true
                    
                }
            }
            return cell
        }
        _proxy.itemSelected = { [weak self] in
            guard let action = $0 as? Action else { return }
            if action.isEnabled {
                action.handler?(action)
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        _proxy.textFieldReturn = { [weak self]textField in
            guard let index = self?.textFields.index(of: textField) else { return true }
            
            if index + 1 == self?.textFields.count {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.textFields[index + 1].becomeFirstResponder()
            }
            
            return true
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if preferredStyle == .actionSheet {
            applyAppearanceAnimation()
        }
        
        if !textFields.isEmpty && textFields.first?.isFirstResponder != true {
            textFields.first?.becomeFirstResponder()
        }
    }
    
    private func updateViewLayout() {
        _viewLayoutHeight = NSLayoutConstraint(
            item: _tableView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 44
        )
        _viewLayoutHeight?.priority = .defaultHigh
        _viewLayoutHeight?.isActive = true
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_tableView]|",
                options: .init(rawValue: 0),
                metrics: nil,
                views: ["_tableView" : _tableView]
            )
        )
        
        if preferredStyle == .alert {
            NSLayoutConstraint.activate(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|[_tableView]|",
                    options: .init(rawValue: 0),
                    metrics: nil,
                    views: ["_tableView" : _tableView]
                )
            )
        } else {
            if preferredStyle == .actionSheet && actions.last?.style == .cancel {
                NSLayoutConstraint.activate(
                    NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|[_tableView]-padding-[_accessoryView(==44)]|",
                        options: [.alignAllLeading, .alignAllTrailing],
                        metrics: ["padding" : 8],
                        views: ["_tableView" : _tableView, "_accessoryView" : _accessoryView]
                    )
                )
            } else {
                NSLayoutConstraint.activate(
                    NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|[_tableView]-padding-||",
                        options: .init(rawValue: 0),
                        metrics: ["padding" : 8],
                        views: ["_tableView" : _tableView]
                    )
                )
            }
        }
    }
    
    private func registerForLocalNotifications() {
        _observations = [
            _tableView.observe(\UITableView.contentSize) { [weak self](tableView, change) in
                self?._viewLayoutHeight?.constant = tableView.contentSize.height
            },
            NotificationCenter.default.addObserver(forName: .UIKeyboardDidShow, object: nil, queue: nil, using: { [weak self](note) in
                guard let strongSelf = self else { return }
                strongSelf._tableView.isScrollEnabled = strongSelf._tableView.contentSize.height - strongSelf.view.bounds.height > 0
            }),
            NotificationCenter.default.addObserver(forName: .UIKeyboardDidHide, object: nil, queue: nil, using: { [weak self](note) in
                guard let strongSelf = self else { return }
                strongSelf._tableView.isScrollEnabled = UIScreen.main.bounds.height - strongSelf.view.bounds.height < 0
            })
        ]
    }
    
    /// AccessoryView animation
    private func applyAppearanceAnimation() {
        let animation = CAKeyframeAnimation.init(keyPath: "transform.translation.y")
        animation.duration = 0.6
    
        animation.values = [
            view.bounds.maxY,
            _accessoryView.bounds.minY + 2,
            _accessoryView.bounds.minY - 2,
            _accessoryView.bounds.minY + 1,
            _accessoryView.bounds.minY - 1,
            _accessoryView.bounds.minY
        ]
        _accessoryView.isHidden = false
        animation.keyTimes = [0, 0.3, 0.5, 0.7, 0.8, 0.9]
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        _accessoryView.layer.add(animation, forKey: nil)
    }
    
    /// Adds a new action to the Alarmer instance
    ///
    /// - Parameter action: The Action that will add to Alarmer instance
    @objc open func addAction(_ action: Action) {
        _actions.append(action)

        guard _actions.filter({ $0.style == .cancel }).count < 2 else {
            _actions.removeLast()
            
            let exception = NSException(name: NSExceptionName.internalInconsistencyException,
                              reason: "Alarmer can only have one action with a style of cancel",
                              userInfo: nil)
            exception.raise()
            return
        }

        guard let index = _actions.index(where: { $0.style == .cancel }) else {
            sorted()
            return
        }
        
        _actions.append(_actions.remove(at: index))
        sorted()
    }
    
    /// Adds a new TextField to the Alarmer instance, AlarmerStyleAlert only
    ///
    /// - Parameter handler: The configuration handler block for textFiled
    @objc open func addTextField(withConfiguration handler: (UITextField) -> Void) {
        assert(preferredStyle == .alert, "Text fields can only be added to an alarmer of style alert")
        
        let textField = UITextField()
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0.5

        // Modify textField text rect without override UITextFiled `textRect(forBounds:)`
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        textField.rightViewMode = .always
        
        // Default delegate
        textField.delegate = _proxy
        
        handler(textField)
        
        _textFields.append(textField)
        
        sorted()
    }
    
    private func sorted() {
        _proxy.models.removeAll()
        _extras.forEach {
            _proxy.models.append($0)
        }
        
        if !textFields.isEmpty {
            _proxy.models.append(textFields)
        }
        actions.forEach {
            _proxy.models.append($0)
        }
        _tableView.reloadData()
    }
    
    static func textAttributes(withTextStyle style: UIFontTextStyle = .headline, foregroundColor: UIColor = .white)
        -> [NSAttributedStringKey : Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        return [
            .font : UIFont.preferredFont(forTextStyle: style),
            .foregroundColor : foregroundColor,
            .paragraphStyle : paragraphStyle
        ]
    }
}

// MARK: Silence warning of 'redundant conformance constraint 'T': 'Reusable''
class TableViewCell: UITableViewCell, Reusable {}
