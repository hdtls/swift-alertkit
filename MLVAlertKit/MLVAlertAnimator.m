//
//  MLVAlertAnimator.m
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

#import "MLVAlertAnimator.h"
#import <objc/runtime.h>

#define DEGREES_TO_RADIANS(degrees)  ((3.14159265359 * degrees)/ 180)

static NSString *const kMLVAppearDismissAnimationKey = @"kMLVAppearDismissAnimationKey";
static NSString *const kMLV3DTransformAnimationKey = @"kMLV3DTransformAnimationKey";
static NSString *const kMLVOpacityAnimationKey = @"kMLVOpacityAnimationKey";
static NSString *const kMLVGroupAnimationKey = @"kMLVGroupAnimationKey";

@interface MLVAlertAnimator ()

@property (nonatomic, assign, readwrite) MLVAlertControllerStyle preferredStyle;
@property (nonatomic, weak) NSLayoutConstraint *centerY;
@property (nonatomic, strong) NSArray *observers;
@end

@implementation MLVAlertAnimator

- (instancetype)initWithMLVAlertControllerPreferredStyle:(MLVAlertControllerStyle)preferredStyle {
    self = [super init];
    if (self) {
        self.preferredStyle = preferredStyle;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].isBeingPresented ? 0.15 : 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *toView = toVc.view;
    UIView *fromView = fromVc.view;
    UIView *container = transitionContext.containerView;
    
    __block UIView *dimmingView;
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.duration = duration;
    opacity.fillMode = kCAFillModeBoth;
    opacity.removedOnCompletion = NO;
    opacity.delegate = self;
    
    if (toVc.isBeingPresented) {
        fromView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        fromView.userInteractionEnabled = NO;
        
        dimmingView = [[UIView alloc] initWithFrame:container.bounds];
        dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dimmingView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.4];
        dimmingView.layer.opacity = 0.0;
        
        opacity.toValue = @1.0;
        
        [container addSubview:dimmingView];
        [container addSubview:toView];
        
        toView.layer.masksToBounds = YES;
        toView.layer.cornerRadius = 10.0;
        
        toView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // toView's constraints
        NSMutableArray *constraints = NSMutableArray.new;
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:toView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        
        if (self.preferredStyle == MLVAlertControllerStyleAlert) {
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=10.0-[toView(>=44.0)]->=10.0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(toView)]];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[toView(==270.0)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(toView)]];
            
            self.centerY = [NSLayoutConstraint constraintWithItem:toView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:container attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
            [constraints addObject:self.centerY];
            
            [self addObservers];
            
            if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
                [NSLayoutConstraint activateConstraints:constraints];
            } else {
                [container addConstraints:constraints];
            }
            
            
            CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            animation.duration = duration;
            NSMutableArray *values = [NSMutableArray array];
            [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1.1)]];
            [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.03, 1.03, 1.0)]];
            [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
            animation.values = values;
            [toView.layer addAnimation:animation forKey:kMLV3DTransformAnimationKey];
            
        } else {
            [UIApplication sharedApplication].keyWindow.backgroundColor = UIColor.blackColor;
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=10.0-[toView(>=44.0)]-10.0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(toView)]];
            
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-<=10.0@750-[toView(>=44.0,<=394.0)]-<=10.0@750-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(toView)]];
            
            if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
                [NSLayoutConstraint activateConstraints:constraints];
            } else {
                [container addConstraints:constraints];
            }
            
            CABasicAnimation *appearDismiss = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
            appearDismiss.duration = duration;
            appearDismiss.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            appearDismiss.speed = 0.6;
            appearDismiss.fillMode = kCAFillModeForwards;
            appearDismiss.removedOnCompletion = NO;
            appearDismiss.fromValue = @(CGRectGetHeight(container.bounds));
            appearDismiss.toValue = @(CGRectGetMinY(toView.bounds));
            [toView.layer addAnimation:appearDismiss forKey:kMLVAppearDismissAnimationKey];
            
            
            CABasicAnimation *transform = [CABasicAnimation animationWithKeyPath:@"transform"];
            transform.duration = duration;
            transform.fillMode = kCAFillModeBoth;
            transform.removedOnCompletion = NO;
            transform.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
            transform.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)];
            [fromView.layer addAnimation:transform forKey:kMLV3DTransformAnimationKey];
        }
    }
    
    if (fromVc.isBeingDismissed) {
        toView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
        toView.userInteractionEnabled = YES;
        
        [container.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.layer animationForKey:kMLVOpacityAnimationKey] != nil) {
                dimmingView = obj;
                *stop = YES;
            }
        }];
        dimmingView.layer.opacity = 1.0;
        opacity.toValue = @0.0;
        
        if (self.preferredStyle == MLVAlertControllerStyleAlert) {
            
            CABasicAnimation *dropDown = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
            dropDown.speed = 0.4;
            dropDown.toValue = @(CGRectGetHeight(container.bounds) + CGRectGetWidth(toView.bounds));
            
            CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            rotation.toValue =  @(DEGREES_TO_RADIANS(-90));
            
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = @[dropDown, rotation];
            group.duration = duration;
            
            group.fillMode = kCAFillModeBoth;
            group.removedOnCompletion = NO;
            group.autoreverses = NO;
            [fromView.layer addAnimation:group forKey:kMLVGroupAnimationKey];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
        } else {
            CABasicAnimation *appearDismiss = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
            appearDismiss.duration = duration;
            appearDismiss.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            appearDismiss.speed = 0.8;
            appearDismiss.fillMode = kCAFillModeForwards;
            appearDismiss.removedOnCompletion = NO;
            appearDismiss.toValue = @(CGRectGetHeight(container.bounds));
            [fromView.layer addAnimation:appearDismiss forKey:kMLVAppearDismissAnimationKey];
            
            CABasicAnimation *transform = [CABasicAnimation animationWithKeyPath:@"transform"];
            transform.duration = duration;
            transform.fillMode = kCAFillModeBoth;
            transform.removedOnCompletion = NO;
            transform.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)];
            transform.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
            [toView.layer addAnimation:transform forKey:kMLV3DTransformAnimationKey];
        }
    }
    
    [dimmingView.layer addAnimation:opacity forKey:kMLVOpacityAnimationKey];
    
    objc_setAssociatedObject(self, @selector(animateTransition:), transitionContext, OBJC_ASSOCIATION_ASSIGN);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    id<UIViewControllerContextTransitioning> context = objc_getAssociatedObject(self, @selector(animateTransition:));
    
    BOOL complete = ![context transitionWasCancelled];
    
    [context completeTransition:complete];
}

#pragma mark - observers
- (void)addObservers {
    __weak typeof(self) weakSelf = self;
    NSObject *oberser1 = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(self) self = weakSelf;
        
        NSDictionary *userInfo = note.userInfo;
        
        NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [aValue CGRectValue];
        
        self.centerY.constant = -CGRectGetHeight(keyboardRect) / 2;
    }];
    
    NSObject *oberser2 = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(self) self = weakSelf;
        
        self.centerY.constant = 0;
    }];
    
    self.observers = @[oberser1, oberser2];
}

- (void)removeObservers {
    [self.observers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] removeObserver:obj];
    }];
}

@end
