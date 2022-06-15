//
//  AdvancedSizeClassSwizzling.m
//  ThinkingAndTesting
//
//  Created by East.Zhang on 2021/5/7.
//  Copyright © 2021 dadong. All rights reserved.
//


#import "AdvancedSizeClassSwizzling.h"
#import <objc/runtime.h>
#if __has_include("AdvancedSizeClass-Swift.h")
#import "AdvancedSizeClass-Swift.h"
#elif __has_include("AdvancedSizeClass/AdvancedSizeClass-Swift.h")
#import "AdvancedSizeClass/AdvancedSizeClass-Swift.h"
#else
@import AdvancedSizeClass;
#endif
/// 是否hook UIView类， 反之hook UIWindow类
#define SwizzlingUIView 0

/// 当前设置的屏幕 （读取的记忆值)
static _Screen *_setting;

@implementation AdvancedSizeClassSwizzling

#if Enable_AdvancedSizeClassSwizzling

+ (void)load {
    
    _setting = [AdvancedSizeClassVC lastTimeChoosenScreen];

    if (!_setting) return;
    
    [self swizzlingClass:UIScreen.class originSel:@selector(bounds) withTargetSel:@selector(sc_bounds)];

    if (@available(iOS 11.0, *)) {
#if SwizzlingUIView
        Class clazz = UIView.class;
#else
        Class clazz = UIWindow.class;
#endif
        [self swizzlingClass:clazz originSel:@selector(safeAreaInsets) withTargetSel:@selector(sc_safeAreaInsets)];
    }
    
    [self swizzlingClass:UINavigationBar.class originSel:@selector(setFrame:) withTargetSel:@selector(sc_setFrame:)];
}

+ (void)swizzlingClass:(Class)clazz originSel:(SEL)originSel withTargetSel:(SEL)targetSel {
    Method originMethod = class_getInstanceMethod(clazz, originSel);
    Method targetMethod = class_getInstanceMethod(clazz, targetSel);
    if (class_addMethod(clazz, originSel, method_getImplementation(targetMethod), method_getTypeEncoding(originMethod))) {
        class_replaceMethod(clazz, targetSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, targetMethod);
    }
}

#endif

@end

#if Enable_AdvancedSizeClassSwizzling

@interface UIScreen (AdvancedSizeClassSwizzling)
@end
@implementation UIScreen (AdvancedSizeClassSwizzling)
- (CGRect)sc_bounds {
    if (_setting != nil) {
        return CGRectMake(0, 0, _setting.width, _setting.height);
    }
    return [self sc_bounds];
}
@end

#if SwizzlingUIView
@interface UIView (AdvancedSizeClassSwizzling)
#else
@interface UIWindow (AdvancedSizeClassSwizzling)
#endif
@end
#if SwizzlingUIView
@implementation UIView (AdvancedSizeClassSwizzling)
#else
@implementation UIWindow (AdvancedSizeClassSwizzling)
#endif
- (UIEdgeInsets)sc_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        if (_setting != nil) {
            return _setting.safeArea;
        }
    }
    return [self sc_safeAreaInsets];
}
@end


@interface UINavigationBar (AdvancedSizeClassSwizzling)

@end
@implementation UINavigationBar (AdvancedSizeClassSwizzling)

// 如果是全面屏，设置了隐藏状态栏，那么导航栏会怎么样？
// 结果： 似乎只是隐藏了状态栏显示，navigationBar不会向上顶
- (void)sc_setFrame:(CGRect)frame {
    if (_setting != nil
        && CGRectEqualToRect(CGRectZero, frame) == NO
        && (int)_setting.safeArea.top != (int)frame.origin.y) {
        CGRect newFrame = frame;
        newFrame.origin.y = _setting.safeArea.top;
        /** 屏幕设置成不是全面屏的时候，需要处理状态栏是否显示的情况，会导致导航栏的y偏移+-20 */
        if (_setting.safeArea.top == 0) {
            if (UIApplication.sharedApplication.isStatusBarHidden == NO) {
                newFrame.origin.y += 20;
            }
        }
        [self sc_setFrame:newFrame];
        return;
    }
    [self sc_setFrame:frame];
}
@end

#endif
