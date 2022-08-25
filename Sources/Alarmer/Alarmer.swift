//
//  UIAlarmer.swift
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

open class UIAlarmer: UIViewController {
    
    /// Enum that specifies the style of the alert controller
    public enum Style: Int {
        case actionSheet
        case alert
    }
    
    /// The style for UIAlarmer instance
    public let preferredStyle: UIAlarmer.Style
    
    /// The textFields added to the UIAlarmer instance
    open var textFields: [UITextField] { return _textFields }
    
    /// The actions added to the UIAlarmer instance
    open var actions: [Action] { return _actions }
    
    /// The message for UIAlarmer instance
    open var message: String?
    
    /// The backgoundColor of title view
    open var tintColor: UIColor? = #colorLiteral(red: 0.268933624, green: 0.5639741421, blue: 0.8968726397, alpha: 1) {
        didSet {
            _tableView.reloadData()
        }
    }
    
    open private(set) var accessoryView: UIView?
    open var accessoryViewBackgroundColor: UIColor? = #colorLiteral(red: 0.6470588235, green: 0, blue: 0.05098039216, alpha: 1) {
        didSet {
            accessoryView?.backgroundColor = accessoryViewBackgroundColor
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
    private var _observations: [NSObjectProtocol] = []
    private var _tableViewHeightLayoutConstraint: NSLayoutConstraint?
    
    deinit {
        _observations.forEach {
            if !($0 is NSKeyValueObservation) {
                NotificationCenter.default.removeObserver($0)
            }
        }
        _observations.removeAll()
    }
    
    public convenience init() {
        self.init(attributedTitle: nil, message: nil, preferredStyle: .actionSheet)
    }
    
    /// Initialize UIAlarmer by given it's title, message and preferred style
    ///
    /// - Parameters:
    ///   - title: The title that UIAlarmer will display
    ///   - message: The message that UIAlarmer will display
    ///   - preferredStyle: See enum 'AlarmerStyle' for more info
    public convenience init(title: String?, message: String?, preferredStyle: UIAlarmer.Style) {
        typealias TextAttributes = [NSAttributedString.Key : Any]
       
        func textAttributes(withStyle style: UIFont.TextStyle = .headline, textColor: UIColor = .white) -> TextAttributes {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            return [
                .font : UIFont.preferredFont(forTextStyle: style),
                .foregroundColor : textColor,
                .paragraphStyle : paragraphStyle
            ]
        }
        
        let _title = title == nil
            ? nil : NSAttributedString(string: title!, attributes: textAttributes(withStyle: .headline, textColor: .white))
        let _message = message == nil
            ? nil : NSAttributedString(string: message!, attributes: textAttributes(withStyle: .body, textColor: .black))
        
        self.init(attributedTitle: _title,
                  message: _message,
                  preferredStyle: preferredStyle)
    }
    
    
    /// Initialize UIAlarmer by given it's attributed title, message and preferred style
    ///
    /// - Parameters:
    ///   - attributedTitle: The attributed title that UIAlarmer will display
    ///   - message: The attributed message that UIAlarmer will display
    ///   - preferredStyle: See enum 'AlarmerStyle' for more info
    public init(attributedTitle: NSAttributedString?, message: NSAttributedString?, preferredStyle: UIAlarmer.Style) {
        self.preferredStyle = preferredStyle
        
        super.init(nibName: nil, bundle: nil)
        
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
        
        _proxy.preferredStyle = preferredStyle
        
        _tableView = UITableView.init(frame: .zero, style: .plain)
        _tableView.translatesAutoresizingMaskIntoConstraints = false
        _tableView.isScrollEnabled = false
        _tableView.layer.masksToBounds = true
        _tableView.layer.cornerRadius = _cornerRadius
        _tableView.bounces = false
        _tableView.showsVerticalScrollIndicator = false
        _tableView.separatorInset = .zero
        _tableView.rowHeight = UITableView.automaticDimension
        _tableView.estimatedRowHeight = 44
        _tableView.tableFooterView = UIView()
        _tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
        _tableView.dataSource = _proxy
        _tableView.delegate = _proxy
        
        transitioningDelegate = _proxy
        modalPresentationStyle = .custom
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        
        view.addSubview(_tableView)
        
        if preferredStyle == .actionSheet && actions.last?.style == .cancel {
            let accessoryView = UIButton()
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            accessoryView.backgroundColor = accessoryViewBackgroundColor
            accessoryView.setTitleColor(.white, for: .normal)
            accessoryView.layer.cornerRadius = _cornerRadius
            accessoryView.layer.masksToBounds = true
            accessoryView.isHidden = true
            accessoryView.addTarget(self, action: #selector(accessoryViewDidTapped), for: .touchUpInside)
            self.accessoryView = accessoryView
            
            view.addSubview(accessoryView)
        }
        
        super.viewDidLoad()
        
        registerForLocalNotifications()
        
        setupProxy()
        
        updateViewLayout()
        
        reloadData()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if preferredStyle == .actionSheet {
            applyAppearanceAnimation()
        }
        
        if !textFields.isEmpty {
            textFields.first?.becomeFirstResponder()
        }
    }
    
    @objc private func accessoryViewDidTapped() {
        
        if let action = actions.last, let handler = action.handler, action.isEnabled {
            handler(action)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func updateViewLayout() {
        var constraints: [NSLayoutConstraint] = []
        
        var padding: CGFloat = 0
        
        //V:|[_tableView]-8-[_accessoryView(==44)]|
        if let accessoryView = accessoryView {
            constraints.append(accessoryView.leadingAnchor.constraint(equalTo: _tableView.leadingAnchor))
            constraints.append(accessoryView.trailingAnchor.constraint(equalTo: _tableView.trailingAnchor))
            constraints.append(accessoryView.topAnchor.constraint(equalTo: _tableView.bottomAnchor, constant: 8))
            if #available(iOS 11.0, *) {
                constraints.append(accessoryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
            } else {
                // Fallback on earlier versions
                constraints.append(accessoryView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
            }
            padding = -52
        } else {
            padding = preferredStyle == .alert ? 0 : -8
        }
        
        _tableViewHeightLayoutConstraint = _tableView.heightAnchor.constraint(equalToConstant: 44)
        _tableViewHeightLayoutConstraint?.priority = .defaultHigh
        
        constraints.append(_tableViewHeightLayoutConstraint!)
        
        constraints.append(_tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(_tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        if #available(iOS 11.0, *) {
            constraints.append(_tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
            constraints.append(_tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: padding))
        } else {
            // Fallback on earlier versions
            constraints.append(_tableView.topAnchor.constraint(equalTo: view.topAnchor))
            constraints.append(_tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: padding))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupProxy() {
        _proxy.preferredStyle = preferredStyle
        _proxy.cellFactory = { [weak self] (tableView, indexPath, action) in
            guard let self else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.description(), for: indexPath)
            tableView.separatorStyle = indexPath.row < self._extras.count ? .none : .singleLine
            
            cell.selectionStyle = indexPath.row < self._extras.count ? .none : .default
            cell.contentView.backgroundColor = self.title != nil && indexPath.row == 0 ? self.tintColor : .clear
            
            //remove all cached textField
            cell.contentView.subviews.filter({ $0 is UITextField }).forEach({ $0.removeFromSuperview() })
            
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
                //textField layout
                self.textFields.forEach({
                    cell.contentView.addSubview($0)
                })
                
                var edgeInsets = cell.layoutMargins
                edgeInsets.bottom *= 2
                self.textFields.distributeViewsAlongAxis(.y, fixedItemLength: 26, edgeInsets: edgeInsets)
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
        
        _proxy.textFieldReturn = { [weak self] textField in
            guard let self else {
                return true
            }

            guard let index = self.textFields.firstIndex(of: textField) else { return true }
            
            if index + 1 == self.textFields.count {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.textFields[index + 1].becomeFirstResponder()
            }
            
            return true
        }
    }
    
    private func registerForLocalNotifications() {
        _observations = [
            _tableView.observe(\UITableView.contentSize) { [weak self](tableView, change) in
                self?._tableViewHeightLayoutConstraint?.constant = tableView.contentSize.height
            },
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: nil, using: { [weak self] _ in
                guard let self else { return }
                self._tableView.isScrollEnabled = self._tableView.contentSize.height - self.view.bounds.height > 0
            }),
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: nil, using: { [weak self] _ in
                guard let self = self else { return }
                self._tableView.isScrollEnabled = UIScreen.main.bounds.height - self.view.bounds.height < 0
            })
        ]
    }
    
    /// AccessoryView animation
    private func applyAppearanceAnimation() {
        let animation = CAKeyframeAnimation.init(keyPath: "transform.translation.y")
        animation.duration = 0.6
        
        let maxY = view.bounds.maxY
        let minY = accessoryView?.bounds.minY ?? 0
        
        animation.values = [maxY, minY + 2, minY - 2, minY + 1, minY - 1, minY]
        accessoryView?.isHidden = false
        animation.keyTimes = [0, 0.3, 0.5, 0.7, 0.8, 0.9]
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        accessoryView?.layer.add(animation, forKey: nil)
    }
    
    /// Adds a new action to the UIAlarmer instance
    ///
    /// - Parameter action: The Action that will add to UIAlarmer instance
    open func addAction(_ action: Action) {
        assert(!isViewLoaded, "Additional action can only be added before -viewDidLoaded")
        
        if actions.contains(where: { $0.style == .cancel }) {
            assert(action.style != .cancel, "UIAlarmer can only have one action with a style of cancel")
            
            let loc = _actions.count - 1 >= 0 ? _actions.count - 1 : 0
            _actions.insert(action, at: loc)
        } else {
            _actions.append(action)
        }
        
        reloadData()
    }
    
    /// Adds a new TextField to the UIAlarmer instance, AlarmerStyleAlert only
    ///
    /// - Parameter handler: The configuration handler block for textFiled
    open func addTextField(withConfiguration handler: ((UITextField) -> Void)?) {
        assert(!isViewLoaded, "Additional action can only be added before -viewDidLoaded")
        assert(preferredStyle == .alert, "Text fields can only be added to an UIAlarmer of style alert")
        
        let textField = TextField()
        
        // Default delegate
        textField.delegate = _proxy
        
        handler?(textField)
        
        _textFields.append(textField)
        
        reloadData()
    }
    
    private func reloadData() {
        _proxy.models.removeAll()
        
        _proxy.models.append(contentsOf: _extras)
        
        if !textFields.isEmpty {
            _proxy.models.append(textFields)
        }
        
        _proxy.models.append(contentsOf: actions)
        
        _tableView.reloadData()
        
        guard let accessoryView = accessoryView as? UIButton, let action = actions.last else {
            return
        }
        
        accessoryView.setAttributedTitle(action.attributedTitle, for: .normal)
    }
}
