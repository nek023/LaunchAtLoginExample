//
//  LaunchAtLoginController.h
//  LaunchAtLoginWithLaunchServices
//
//  Created by Katsuma Tanaka on 2014/04/13.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaunchAtLoginController : NSObject

+ (instancetype)sharedController;

- (void)setLaunchAtLoginEnabled:(BOOL)enabled forURL:(NSURL *)itemURL;
- (BOOL)isLaunchAtLoginEnabled:(NSURL *)itemURL;

- (void)setLaunchAtLoginEnabled:(BOOL)enabled;
- (BOOL)isLaunchAtLoginEnabled;

@end
