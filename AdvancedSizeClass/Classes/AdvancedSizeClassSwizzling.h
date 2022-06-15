//
//  AdvancedSizeClassSwizzling.h
//  ThinkingAndTesting
//
//  Created by East.Zhang on 2021/5/7.
//  Copyright © 2021 dadong. All rights reserved.
//
//  外部需定义
//      #define Enable_AdvancedSizeClassSwizzling 1
//  或者直接把下面写好的`Enable_AdvancedSizeClassSwizzling`宏，直接包裹你的项目预定义宏（比如Debug/Release),
//  否则文件不会被编译，功能无法生效！
//

#define Enable_AdvancedSizeClassSwizzling 1

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvancedSizeClassSwizzling : NSObject

@end

NS_ASSUME_NONNULL_END

