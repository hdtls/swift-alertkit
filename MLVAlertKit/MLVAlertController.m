//
//  MLVAlertController.m
//
//  Copyright (c) 2016 NEET. All rights reserved.
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

#import "MLVAlertController.h"
#import "MLVAlertAnimator.h"

#define MLVColorFromRGBHex(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


static NSDictionary * attributesWith(NSString *preferredFontForTextStyle, UIColor *foregroundColor) {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    return @{NSFontAttributeName : [UIFont preferredFontForTextStyle:preferredFontForTextStyle],
             NSForegroundColorAttributeName : foregroundColor,
             NSParagraphStyleAttributeName : paragraphStyle};
}


@interface MLVAlertAction ()

@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, copy) NSAttributedString *attributedTitle;

@property (nonatomic, readwrite) MLVAlertActionStyle style;

@property (nullable, nonatomic, readwrite) void (^handler)(MLVAlertAction *);

@end

@implementation MLVAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(MLVAlertActionStyle)style handler:(void (^)(MLVAlertAction * _Nonnull))handler {
    
    NSAssert(title, @"Actions added to MLVAlertController must have a title");
    
    MLVAlertAction *action = [[MLVAlertAction alloc] init];
    if (action) {
        action.title = title;
        action.style = style;
        action.handler = [handler copy];
        action.enabled = YES;
        
        NSDictionary *attributes;
        if (action.style == MLVAlertActionStyleDestructive) {
            attributes = attributesWith(UIFontTextStyleBody, MLVColorFromRGBHex(0xA5000D));
        } else {
            attributes = attributesWith(UIFontTextStyleBody, UIColor.blackColor);
        }
        action.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    }
    return action;
}

+ (instancetype)actionWithAttributedTitle:(NSAttributedString *)title style:(MLVAlertActionStyle)style handler:(void (^ __nullable)(MLVAlertAction *action))handler {
    NSAssert(title, @"Actions added to MLVAlertController must have a title");
    
    MLVAlertAction *action = [[MLVAlertAction alloc] init];
    if (action) {
        action.title = title.string;
        action.style = style;
        action.handler = [handler copy];
        action.enabled = YES;
        action.attributedTitle = title;
    }
    return action;
}
@end


@interface MLVAlertController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *cancelButton; // when MLVAlertControllerStyleActionSheet cancel button will be initialized, otherwise nil.

@property (nonatomic, weak) NSLayoutConstraint *height;

@property (nonatomic, readwrite) NSArray<MLVAlertAction *> *actions;

@property (nonatomic, strong) NSMutableArray<MLVAlertAction *> *otherwiseActions;  // include the placeholder of title and message

@property (nullable, nonatomic, copy, readwrite) NSString *message;

@property (nonatomic, strong) UIColor *windowColor;

@property (nonatomic, readwrite) MLVAlertControllerStyle preferredStyle;

@property (nonatomic, strong) UITapGestureRecognizer *assistantTapGesture; // when MLVAlertControllerStyleActionSheet tap gesture recognizer will be initialized, otherwise nil.

@end

@implementation MLVAlertController
- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)initialize {
    self.preferredStyle = MLVAlertControllerStyleActionSheet;
    self.otherwiseActions = [[NSMutableArray alloc] init];
    self.windowColor = [UIApplication sharedApplication].keyWindow.backgroundColor;
    
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
        
        self.assistantTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(dismiss)];
        self.assistantTapGesture.delegate = self;
        [[UIApplication sharedApplication].keyWindow addGestureRecognizer:self.assistantTapGesture];
    }
    return self;
}

- (instancetype)initWithAttributedTitle:(NSAttributedString *)title
                                message:(NSAttributedString *)message
                         preferredStyle:(MLVAlertControllerStyle)preferredStyle {
    
    self = [super init];
    
    if (self) {
        [self initialize];
        
        self.title = title.string;
        self.message = message.string;
        self.preferredStyle = preferredStyle;
        
        if (self.preferredStyle == MLVAlertControllerStyleActionSheet) {
            self.assistantTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(dismiss)];
            self.assistantTapGesture.delegate = self;
            [[UIApplication sharedApplication].keyWindow addGestureRecognizer:self.assistantTapGesture];
        }
        
        if (title) {
            MLVAlertAction *action = [MLVAlertAction actionWithAttributedTitle:title style:MLVAlertActionStyleDefault handler:nil];
            action.enabled = NO;
            [self.otherwiseActions addObject:action];
        }
        
        if (message) {
            MLVAlertAction *action = [MLVAlertAction actionWithAttributedTitle:message style:MLVAlertActionStyleDefault handler:nil];
            action.enabled = NO;
            [self.otherwiseActions addObject:action];
        }
    }
    return self;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                          preferredStyle:(MLVAlertControllerStyle)preferredStyle {
    
    NSAttributedString *attributedTitle;
    NSAttributedString *attributedMessage;
    
    if (title) {
        NSDictionary *attributes = attributesWith(UIFontTextStyleHeadline, UIColor.whiteColor);
        attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    }
    
    if (message) {
        NSDictionary *attributes = attributesWith(UIFontTextStyleSubheadline, UIColor.blackColor);
        attributedMessage = [[NSAttributedString alloc] initWithString:message attributes:attributes];
    }
    
    return [[MLVAlertController alloc] initWithAttributedTitle:attributedTitle message:attributedMessage preferredStyle:preferredStyle];
}

+ (instancetype)alertControllerWithAttributedTitle:(NSAttributedString *)title
                                           message:(NSAttributedString *)message
                                    preferredStyle:(MLVAlertControllerStyle)preferredStyle {
    
    return [[MLVAlertController alloc] initWithAttributedTitle:title
                                                       message:message
                                                preferredStyle:preferredStyle];
}

- (UITableView *)tableView {
    if (_tableView) return _tableView;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.scrollEnabled = NO;
    _tableView.layer.masksToBounds = YES;
    _tableView.layer.cornerRadius = 10.0;
    _tableView.bounces = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorInset = UIEdgeInsetsZero;
#if __IPHONE_8_0
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        _tableView.layoutMargins = UIEdgeInsetsZero;
    }
#endif
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    return _tableView;
}

- (UIButton *)cancelButton {
    if (_cancelButton) return _cancelButton;
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    _cancelButton.layer.masksToBounds = YES;
    _cancelButton.layer.cornerRadius = 10.0;
    _cancelButton.backgroundColor = UIColor.whiteColor;
    [_cancelButton setTitle:self.otherwiseActions.lastObject.title forState:UIControlStateNormal];
    [_cancelButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [_cancelButton setTitleColor:MLVColorFromRGBHex(0xA5000D) forState:UIControlStateHighlighted];
    [_cancelButton addTarget:self action:@selector(cancelActionHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, MLVColorFromRGBHex(0xFEDEE0).CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [_cancelButton setBackgroundImage:image forState:UIControlStateHighlighted];
    
    return _cancelButton;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.preferredStyle == MLVAlertControllerStyleActionSheet) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    
    [self updateViewLayout];
    
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)updateViewLayout {
    self.height = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:nil
                                               attribute:NSLayoutAttributeNotAnAttribute
                                              multiplier:1.0
                                                constant:44.0];
    self.height.priority = UILayoutPriorityDefaultHigh;
    self.height.active = YES;
    
    
    
    if (self.preferredStyle == MLVAlertControllerStyleActionSheet
        && self.otherwiseActions.lastObject.style == MLVAlertActionStyleCancel) {
        
        [self.view addSubview:self.cancelButton];
    }
    
    NSArray *constraints = [self constraintsOfPreferredStyle:self.preferredStyle];
    [NSLayoutConstraint activateConstraints:constraints];
}

- (NSArray *)constraintsOfPreferredStyle:(MLVAlertControllerStyle)preferredStyle {
    NSMutableArray *constraints = NSMutableArray.new;
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|"
                                                                             options:0 metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_tableView)]];
    
    if (preferredStyle == MLVAlertControllerStyleAlert) {
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    } else {
        
        NSString *visualFormat = @"V:|[_tableView]-padding-|";
        NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
        
        if (self.otherwiseActions.lastObject.style == MLVAlertActionStyleCancel) {
            
            visualFormat = @"V:|[_tableView]-padding-[_cancelButton(==44.0)]|";
            views = NSDictionaryOfVariableBindings(_tableView, _cancelButton);
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cancelButton]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_cancelButton)]];
        }
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:@{@"padding" : @(self.view.layoutMargins.bottom)} views:views]];
    }
    
    return [NSArray arrayWithArray:constraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSAssert(self.otherwiseActions.count != 0, @"MLVAlertController must have a title, a message or an action to display");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.preferredStyle == MLVAlertControllerStyleActionSheet) {
        [self animationAppear];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [UIApplication sharedApplication].keyWindow.backgroundColor = self.windowColor;
    
    if (self.preferredStyle == MLVAlertControllerStyleActionSheet) {
        [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.assistantTapGesture];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addAction:(MLVAlertAction *)action {
    
    NSMutableArray *actions = self.actions ? self.actions.mutableCopy : NSMutableArray.new;
    [actions addObject:action];
    
    self.actions = [NSArray arrayWithArray:actions];
    [self.otherwiseActions addObject:action];
    
    // move MLVAlertAction whitch style is MLVAlertActionStyleCancel to the last
    [self.otherwiseActions enumerateObjectsUsingBlock:^(MLVAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.style == MLVAlertActionStyleCancel) {
            [self.otherwiseActions removeObject:obj];
            [self.otherwiseActions addObject:obj];
            *stop = YES;
        }
    }];
}

#pragma mark - Additions for MLVAlertControllerStyleActionSheet
- (void)animationAppear {
    
    CGFloat destination = CGRectGetMinY(self.cancelButton.bounds);
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.duration = 0.6;
    animation.values = @[@(CGRectGetMaxY(self.view.bounds)), @(destination + 3), @(destination - 3), @(destination + 2), @(destination - 1), @(destination)];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self.cancelButton.layer addAnimation:animation forKey:@"kMLVKeyAnimationKey"];
}

// tap response
- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelActionHandler:(UIButton *)sender {
    if (self.otherwiseActions.lastObject.style == MLVAlertActionStyleCancel) {
        NSUInteger row = self.otherwiseActions.count - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self excuteSelectedActionHandlerAtIndexPath:indexPath];
    }
}

- (void)excuteSelectedActionHandlerAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.otherwiseActions.count) {
        
        MLVAlertAction *action = self.otherwiseActions[indexPath.row];
        
        if (![action.title isEqualToString:self.title] && ![action.title isEqualToString:self.message]) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                [UIApplication sharedApplication].keyWindow.backgroundColor = self.windowColor;
                if (action.enabled) {
                    void (^handler)(MLVAlertAction *) = action.handler;
                    if (handler) {
                        handler(action);
                    }
                }
            }];
        }
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    self.height.constant = self.tableView.contentSize.height;
    if ([self.view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height > [UIScreen mainScreen].bounds.size.height) {
        self.tableView.scrollEnabled = YES;
    } else {
        self.tableView.scrollEnabled = NO;
    }
}

#pragma mark - UIGesture recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.tableView] && [gestureRecognizer isEqual:self.assistantTapGesture]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITable view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // replace last cancel action to cancel button
    if (self.otherwiseActions.lastObject.style == MLVAlertActionStyleCancel
        && self.preferredStyle == MLVAlertControllerStyleActionSheet) {
        return self.otherwiseActions.count - 1;
    }
    
    return self.otherwiseActions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    [self configuration:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configuration:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.textLabel.backgroundColor = UIColor.clearColor;
    cell.textLabel.numberOfLines = 0;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = UIColor.whiteColor;
    
#if __IPHONE_8_0
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
#endif
    
    if (self.title && indexPath.row == 0) {
        cell.contentView.backgroundColor = MLVColorFromRGBHex(0x377ADE);
    }
    
    MLVAlertAction *action = self.otherwiseActions[indexPath.row];
    
    if (![action.title isEqualToString:self.title] && ![action.title isEqualToString:self.message]) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    if (action.style == MLVAlertActionStyleCancel) {
        UIView *selectedBackgroundView = UIView.new;
        selectedBackgroundView.backgroundColor = MLVColorFromRGBHex(0xFEDEE0);
        cell.selectedBackgroundView = selectedBackgroundView;
        cell.textLabel.highlightedTextColor = MLVColorFromRGBHex(0xA5000D);
    } else if (action.style == MLVAlertActionStyleDestructive) {
        cell.textLabel.textColor = UIColor.redColor;
    }
    
    cell.textLabel.attributedText = action.attributedTitle;
}

#pragma mark - UITable view delegate
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    [self configuration:cell atIndexPath:indexPath];
    
    return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self excuteSelectedActionHandlerAtIndexPath:indexPath];
}


#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return [[MLVAlertAnimator alloc] initWithMLVAlertControllerPreferredStyle:self.preferredStyle];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    
    return [[MLVAlertAnimator alloc] initWithMLVAlertControllerPreferredStyle:self.preferredStyle];
}
@end
