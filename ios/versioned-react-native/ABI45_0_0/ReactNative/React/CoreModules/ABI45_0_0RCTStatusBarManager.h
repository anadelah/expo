/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <ABI45_0_0React/ABI45_0_0RCTConvert.h>
#import <ABI45_0_0React/ABI45_0_0RCTEventEmitter.h>

@interface ABI45_0_0RCTConvert (UIStatusBar)

+ (UIStatusBarStyle)UIStatusBarStyle:(id)json;
+ (UIStatusBarAnimation)UIStatusBarAnimation:(id)json;

@end

@interface ABI45_0_0RCTStatusBarManager : ABI45_0_0RCTEventEmitter

@end
