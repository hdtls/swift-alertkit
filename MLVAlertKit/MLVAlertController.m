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
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]


static NSDictionary * MLVTextAttributesFromStyleAndForegroundColor(NSString *style, UIColor *color) {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    return @{NSFontAttributeName : [UIFont preferredFontForTextStyle:style],
             NSForegroundColorAttributeName : color,
             NSParagraphStyleAttributeName : paragraphStyle};
}


@interface MLVAlertAction ()

@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) MLVAlertActionStyle style;
@property (nonatomic, readwrite) void (^handler)(MLVAlertAction *);

/**
 *  Extension property for MLVAlertControllerStyleAlert to add TextField, default nil
 */
@property (nonatomic, copy) void (^TextFieldConfiguration)(UITextField * _Nonnull);

/**
 *  The action attributed title
 */
@property (nonatomic, copy) NSAttributedString *__title;

@end

@implementation MLVAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(MLVAlertActionStyle)style handler:(void (^)(MLVAlertAction * _Nonnull))handler {
    
    NSAssert(title, @"Actions added to MLVAlertController must have a title");
    
    NSAttributedString *__title;
    
    if (title) {
        NSDictionary *attributes;
        if (style == MLVAlertActionStyleDestructive) {
            attributes = MLVTextAttributesFromStyleAndForegroundColor(UIFontTextStyleBody, MLVColorFromRGBHex(0xA5000D));
        } else {
            attributes = MLVTextAttributesFromStyleAndForegroundColor(UIFontTextStyleBody, UIColor.blackColor);
        }
        
        __title = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    }
    
    return [MLVAlertAction actionWithAttributedTitle:__title style:style handler:handler];
}

+ (instancetype)actionWithAttributedTitle:(NSAttributedString *)title style:(MLVAlertActionStyle)style handler:(void (^ __nullable)(MLVAlertAction *action))handler {
    
    NSAssert(title, @"Actions added to MLVAlertController must have a title");
    
    MLVAlertAction *action = [[MLVAlertAction alloc] init];
    if (action) {
        action.title = title.string;
        action.style = style;
        action.handler = [handler copy];
        action.enabled = YES;
        action.__title = title;
    }
    return action;
}

@end


@interface MLVAlertController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, copy, readwrite) NSString *message;
@property (nonatomic, readwrite) MLVAlertControllerStyle preferredStyle;

@property (nonatomic, strong) UITableView *tableView;

/**
 *  The accessory button use to display an action of style MLVAlertActionStyleCancel, When MLVAlertController instance is an alert controller of style MLVAlertControllerStyleActionSheet, and the actions of this instance contains an action of style MLVAlertActionStyleCancel, the accessory button will be create, otherwise nil.
 */
@property (nonatomic, strong) UIButton *accessory;
@property (nonatomic, strong) UIColor *windowColor;

/**
 *  The accessory tap
 *  when MLVAlertController instance is an alert controller of style MLVAlertControllerStyleActionSheet, the accessory tap gesture recognizer will be create, otherwise nil.
 *  The accessory tap use to dismiss MLVAlertController
 */
@property (nonatomic, strong) UITapGestureRecognizer *accessoryTap;

@property (nonatomic, weak) NSLayoutConstraint *height;
@property (nonatomic, readwrite) NSArray<MLVAlertAction *> *actions;
@property (nullable, nonatomic, readwrite) NSArray<UITextField *> *textFields;

/**
 *  The title and message placeholder actions
 */
@property (nonatomic, strong) NSMutableArray<MLVAlertAction *> *accessoryActions;

/**
 *  The tableView cell height caches
 */
@property (nonatomic, strong) NSCache *heights;

/**
 *  The observers for UIKeyboard notications
 */
@property (nonatomic, strong) NSArray *observers;

/**
 *  A integer value that determines if the action of style cancel already been added
 */
@property (nonatomic, assign) NSInteger numberOfCancelActions;
@end


@implementation MLVAlertController
- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
    
    [self removeObservers];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.preferredStyle = MLVAlertControllerStyleActionSheet;
        
        [self initialize];
    }
    return self;
}

- (instancetype)initWithAttributedTitle:(NSAttributedString *)title
                                message:(NSAttributedString *)message
                         preferredStyle:(MLVAlertControllerStyle)preferredStyle {
    
    self = [super init];
    
    if (self) {
        
        self.title = title.string;
        self.message = message.string;
        self.preferredStyle = preferredStyle;
        
        [self initialize];
        
        if (title) {
            MLVAlertAction *action = [MLVAlertAction actionWithAttributedTitle:title style:MLVAlertActionStyleDefault handler:nil];
            action.enabled = NO;
            [self.accessoryActions addObject:action];
        }
        
        if (message) {
            MLVAlertAction *action = [MLVAlertAction actionWithAttributedTitle:message style:MLVAlertActionStyleDefault handler:nil];
            action.enabled = NO;
            [self.accessoryActions addObject:action];
        }
    }
    return self;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                          preferredStyle:(MLVAlertControllerStyle)preferredStyle {
    
    NSAttributedString *__title;
    NSAttributedString *__message;
    
    if (title) {
        NSDictionary *attributes = MLVTextAttributesFromStyleAndForegroundColor(UIFontTextStyleHeadline, UIColor.whiteColor);
        __title = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    }
    
    if (message) {
        NSDictionary *attributes = MLVTextAttributesFromStyleAndForegroundColor(UIFontTextStyleSubheadline, UIColor.blackColor);
        __message = [[NSAttributedString alloc] initWithString:message attributes:attributes];
    }
    
    return [[MLVAlertController alloc] initWithAttributedTitle:__title message:__message preferredStyle:preferredStyle];
}

+ (instancetype)alertControllerWithAttributedTitle:(NSAttributedString *)title
                                           message:(NSAttributedString *)message
                                    preferredStyle:(MLVAlertControllerStyle)preferredStyle {
    
    return [[MLVAlertController alloc] initWithAttributedTitle:title
                                                       message:message
                                                preferredStyle:preferredStyle];
}

- (void)initialize {
    self.accessoryActions = [[NSMutableArray alloc] init];
    self.windowColor = [UIApplication sharedApplication].keyWindow.backgroundColor;
    self.heights = [[NSCache alloc] init];
    self.numberOfCancelActions = 0;
    
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    
    [self initializeAccessoryTapGestureRecognizer];
}

- (void)initializeAccessoryTapGestureRecognizer {
    if (self.preferredStyle == MLVAlertControllerStyleActionSheet) {
        self.accessoryTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(dismiss)];
        self.accessoryTap.delegate = self;
        [[UIApplication sharedApplication].keyWindow addGestureRecognizer:self.accessoryTap];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.preferredStyle == MLVAlertControllerStyleActionSheet) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (void)loadView {
    [super loadView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.scrollEnabled = NO;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.cornerRadius = 10.0;
    self.tableView.bounces = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    [self.view addSubview:self.tableView];
    
    
    if ([self needsAccessoryView]) {
        
        self.accessory = [UIButton buttonWithType:UIButtonTypeCustom];
        self.accessory.translatesAutoresizingMaskIntoConstraints = NO;
        self.accessory.layer.masksToBounds = YES;
        self.accessory.layer.cornerRadius = 10.0;
        self.accessory.backgroundColor = UIColor.whiteColor;
        [self.accessory setTitle:self.actions.lastObject.title forState:UIControlStateNormal];
        [self.accessory setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [self.accessory setTitleColor:MLVColorFromRGBHex(0xA5000D) forState:UIControlStateHighlighted];
        [self.accessory addTarget:self action:@selector(accessoryHandler:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect rect = CGRectMake(0, 0, 1, 1);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, MLVColorFromRGBHex(0xFEDEE0).CGColor);
        CGContextFillRect(context, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.accessory setBackgroundImage:image forState:UIControlStateHighlighted];
        [self.accessory setBackgroundImage:image forState:UIControlStateSelected];
        
        [self.view addSubview:self.accessory];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateViewLayout];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSAssert(self.accessoryActions.count != 0 || self.actions.count != 0, @"MLVAlertController must have a title, a message or an action to display");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.preferredStyle == MLVAlertControllerStyleActionSheet) {
        [self animationAppearance];
    }
    
    if (self.textFields.count != 0) {
        [self.textFields.firstObject becomeFirstResponder];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [UIApplication sharedApplication].keyWindow.backgroundColor = self.windowColor;
    
    if (self.preferredStyle == MLVAlertControllerStyleActionSheet) {
        [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.accessoryTap];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViewLayout {
    self.height = [NSLayoutConstraint constraintWithItem:self.tableView
                                               attribute:NSLayoutAttributeHeight
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:nil
                                               attribute:NSLayoutAttributeNotAnAttribute
                                              multiplier:1.0
                                                constant:44.0];
    self.height.priority = UILayoutPriorityDefaultHigh;
    
    NSMutableArray *constraints = NSMutableArray.new;
    
    NSString *visualFormat = @"H:|[_tableView]|";
    NSDictionary *views = NSDictionaryOfVariableBindings(_tableView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    if (self.preferredStyle == MLVAlertControllerStyleAlert) {
        
        visualFormat = @"V:|[_tableView]|";
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
        
    } else {
        
        if ([self needsAccessoryView]) {
            
            visualFormat = @"H:|[_accessory]|";
            views = NSDictionaryOfVariableBindings(_accessory);
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:views]];
            
            visualFormat = @"V:|[_tableView]-padding-[_accessory(==44.0)]|";
            views = NSDictionaryOfVariableBindings(_tableView, _accessory);
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                                     options:0
                                                                                     metrics:@{@"padding" : @(self.view.layoutMargins.bottom)}
                                                                                       views:views]];
            
        } else {
            visualFormat = @"V:|[_tableView]-padding-|";
            views = NSDictionaryOfVariableBindings(_tableView);
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                                     options:0
                                                                                     metrics:@{@"padding" : @(self.view.layoutMargins.bottom)}
                                                                                       views:views]];
        }
    }
    
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        self.height.active = YES;
        [NSLayoutConstraint activateConstraints:constraints];
    } else {
        [self.tableView addConstraint:self.height];
        [self.view addConstraints:constraints];
    }
}

- (void)addAction:(MLVAlertAction *)action {
    
    if (action.style == MLVAlertActionStyleCancel) {
        self.numberOfCancelActions += 1;
    }
    
    NSMutableArray *actions = self.actions ? self.actions.mutableCopy : NSMutableArray.new;
    [actions addObject:action];
    
    [actions enumerateObjectsUsingBlock:^(MLVAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.style == MLVAlertActionStyleCancel) {
            [actions removeObject:obj];
            [actions addObject:obj];
            
            *stop = YES;
        }
    }];
    
    NSAssert(self.numberOfCancelActions <= 1, @"MLVAlertController can only have one action with a style of UIAlertActionStyleCancel");
    
    self.actions = [NSArray arrayWithArray:actions];
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField * _Nonnull))configurationHandler {
    
    NSAssert(self.preferredStyle == MLVAlertControllerStyleAlert, @"Text fields can only be added to an alert controller of style MLVAlertControllerStyleAlert");
    
    void (^TextFieldConfiguration)(UITextField * _Nonnull) = configurationHandler;
    
    UITextField *textField = [[UITextField alloc] init];
    
    textField.delegate = self;
    
    if (TextFieldConfiguration) {
        TextFieldConfiguration(textField);
    }
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *textFields = self.textFields ? self.textFields.mutableCopy : NSMutableArray.new;
    [textFields addObject:textField];
    
    self.textFields = [NSArray arrayWithArray:textFields];
}

- (BOOL)needsAccessoryView {
    
    return self.preferredStyle == MLVAlertControllerStyleActionSheet && self.actions.lastObject.style == MLVAlertActionStyleCancel;
}

#pragma mark - observers
- (void)addObservers {
    __weak typeof(self) weakSelf = self;
    NSObject *oberser1 = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(self) self = weakSelf;
        
        if (CGRectGetHeight(self.view.bounds) < self.tableView.contentSize.height) {
            self.tableView.scrollEnabled = YES;
        } else {
            self.tableView.scrollEnabled = NO;
        }
        
    }];
    
    NSObject *oberser2 = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(self) self = weakSelf;
        
        if (CGRectGetHeight(self.view.bounds) > [UIScreen mainScreen].bounds.size.height) {
            self.tableView.scrollEnabled = YES;
        } else {
            self.tableView.scrollEnabled = NO;
        }
    }];
    
    self.observers = @[oberser1, oberser2];
}

- (void)removeObservers {
    [self.observers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] removeObserver:obj];
    }];
}

- (void)animationAppearance {
    
    CGFloat destination = CGRectGetMinY(self.accessory.bounds);
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.duration = 0.6;
    animation.values = @[@(CGRectGetMaxY(self.view.bounds)),
                         @(destination + 3),
                         @(destination - 3),
                         @(destination + 2),
                         @(destination - 1),
                         @(destination)];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    [self.accessory.layer addAnimation:animation forKey:@"kMLVKeyAnimationKey"];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)accessoryHandler:(UIButton *)sender {
    
    sender.selected = YES;
    
    NSUInteger row = self.accessoryActions.count + self.textFields.count + self.actions.count - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    [self excuteSelectedActionHandlerAtIndexPath:indexPath];
}

#pragma mark - Action handler
- (void)excuteSelectedActionHandlerAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.row - self.accessoryActions.count;
    
    if (self.accessoryActions <= indexPath.row && index < self.textFields.count) {
        [self.view becomeFirstResponder];
    }
    
    index = indexPath.row - self.accessoryActions.count - self.textFields.count;
    
    if (self.accessoryActions.count + self.textFields.count <= indexPath.row && index  < self.actions.count) {
        
        MLVAlertAction *action = self.actions[index];
        
        [self dismissViewControllerAnimated:YES completion:^{
            [UIApplication sharedApplication].keyWindow.backgroundColor = self.windowColor;
            if (action.enabled) {
                void (^handler)(MLVAlertAction *) = action.handler;
                if (handler) {
                    handler(action);
                    handler = nil;
                }
            }
        }];
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
    if ([touch.view isDescendantOfView:self.tableView] && [gestureRecognizer isEqual:self.accessoryTap]) {
        return NO;
    }
    return YES;
}

#pragma mark - UITable view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger number = self.accessoryActions.count + self.textFields.count + self.actions.count;
    if ([self needsAccessoryView]) {
        return number - 1;
    }
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)
                                                            forIndexPath:indexPath];
    
    [self configuration:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configuration:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.textLabel.backgroundColor = UIColor.clearColor;
    cell.textLabel.numberOfLines = 0;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.contentView.backgroundColor = UIColor.whiteColor;
    
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    if (self.title && indexPath.row == 0) {
        
        cell.contentView.backgroundColor = MLVColorFromRGBHex(0x377ADE);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSInteger index = indexPath.row;
    
    if (index < self.accessoryActions.count) {
        
        MLVAlertAction *action = self.accessoryActions[index];
        
        cell.textLabel.attributedText = action.__title;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    index = indexPath.row - self.accessoryActions.count;
    
    if (self.accessoryActions.count <= indexPath.row && index < self.textFields.count) {
        
        __block BOOL containsTextField = NO;
        
        [cell.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:UITextField.class]) {
                containsTextField = YES;
                *stop = YES;
            }
        }];
        
        if (!containsTextField) {
            UITextField *textField = self.textFields[index];
            
            [cell.contentView addSubview:textField];
            
            NSMutableArray *constraints = NSMutableArray.new;
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-padding-[textField]-padding-|" options:0 metrics:@{@"padding" : @(self.view.layoutMargins.left / 2)} views:NSDictionaryOfVariableBindings(textField)]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[textField]-padding-|" options:0 metrics:@{@"padding" : @(self.view.layoutMargins.left)} views:NSDictionaryOfVariableBindings(textField)]];
            
            if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
                [NSLayoutConstraint activateConstraints:constraints];
            } else {
                [cell.contentView addConstraints:constraints];
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    index = indexPath.row - self.accessoryActions.count - self.textFields.count;
    
    if (self.accessoryActions.count + self.textFields.count <= indexPath.row && index < self.actions.count) {
        
        MLVAlertAction *action = self.actions[index];
        
        if (action.style == MLVAlertActionStyleCancel) {
            
            UIView *selectedBackgroundView = UIView.new;
            selectedBackgroundView.backgroundColor = MLVColorFromRGBHex(0xFEDEE0);
            
            cell.selectedBackgroundView = selectedBackgroundView;
            cell.textLabel.highlightedTextColor = MLVColorFromRGBHex(0xA5000D);
            
        } else if (action.style == MLVAlertActionStyleDestructive) {
            
            cell.textLabel.textColor = UIColor.redColor;
        }
        
        cell.textLabel.attributedText = action.__title;
    }
}

#pragma mark - UITable view delegate
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self.heights objectForKey:indexPath]) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
        
        [self configuration:cell atIndexPath:indexPath];
        
        CGFloat height = MAX(44.0, [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
        
        [self.heights setObject:@(height) forKey:indexPath];
    }
    
    return [[self.heights objectForKey:indexPath] floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self excuteSelectedActionHandlerAtIndexPath:indexPath];
}

#pragma mark - UITextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
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
