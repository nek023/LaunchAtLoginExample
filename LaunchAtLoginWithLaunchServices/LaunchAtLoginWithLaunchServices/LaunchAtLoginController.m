//
//  LaunchAtLoginController.m
//  LaunchAtLoginWithLaunchServices
//
//  Created by Katsuma Tanaka on 2014/04/13.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

#import "LaunchAtLoginController.h"

static NSString * const kStartAtLoginKey = @"launchAtLogin";

@interface LaunchAtLoginController ()
{
    LSSharedFileListRef _loginItems;
}

@end

@implementation LaunchAtLoginController

void sharedFileListDidChange(LSSharedFileListRef fileList, void *context)
{
    id obj = (__bridge id)context;
    [obj willChangeValueForKey:kStartAtLoginKey];
    [obj didChangeValueForKey:kStartAtLoginKey];
}

+ (instancetype)sharedController
{
    static id _sharedController = nil;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedController = [[self alloc] init];
    });
    
    return _sharedController;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
        
        // Start observing
        LSSharedFileListAddObserver(_loginItems,
                                    CFRunLoopGetMain(),
                                    (CFStringRef)NSDefaultRunLoopMode,
                                    sharedFileListDidChange,
                                    (__bridge void *)(self));
    }
    
    return self;
}

- (void)dealloc
{
    // Stop observing
    LSSharedFileListRemoveObserver(_loginItems,
                                   CFRunLoopGetMain(),
                                   (CFStringRef)NSDefaultRunLoopMode,
                                   sharedFileListDidChange,
                                   (__bridge void *)(self));
}


#pragma mark - Managing Login Item

- (void)setLaunchAtLoginEnabled:(BOOL)enabled forURL:(NSURL *)itemURL
{
    if (enabled) {
        [self addLoginItemForURL:itemURL];
    } else {
        [self removeLoginItemForURL:itemURL];
    }
}

- (void)addLoginItemForURL:(NSURL *)itemURL
{
    // Add URL as a login item
    LSSharedFileListItemRef loginItem = LSSharedFileListInsertItemURL(_loginItems, kLSSharedFileListItemLast, NULL, NULL, (__bridge CFURLRef)itemURL, NULL, NULL);
    CFRelease(loginItem); // Returned value has to be released
}

- (BOOL)removeLoginItemForURL:(NSURL *)itemURL
{
    // Get a snapshot of the list
    NSArray *snapshot = (__bridge_transfer NSArray *)LSSharedFileListCopySnapshot(_loginItems, NULL);
    
    for (id loginItemObject in snapshot) {
        // Resolve item
        LSSharedFileListItemRef loginItem = (__bridge LSSharedFileListItemRef)loginItemObject;
        UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
        CFURLRef currentItemURL = NULL;
        
        if (LSSharedFileListItemResolve(loginItem, resolutionFlags, &currentItemURL, NULL) == noErr) {
            if (currentItemURL && CFEqual(currentItemURL, (__bridge CFTypeRef)itemURL)) {
                // Remove login item
                LSSharedFileListItemRemove(_loginItems, loginItem);
                CFRelease(currentItemURL);
                return YES;
            }
            
            if (currentItemURL) {
                CFRelease(currentItemURL);
            }
        }
    }
    
    return NO;
}

- (BOOL)isLaunchAtLoginEnabled:(NSURL *)itemURL
{
    // Get a snapshot of the list
    NSArray *snapshot = (__bridge_transfer NSArray *)LSSharedFileListCopySnapshot(_loginItems, NULL);
    
    for (id loginItemObject in snapshot) {
        // Resolve item
        LSSharedFileListItemRef loginItem = (__bridge LSSharedFileListItemRef)loginItemObject;
        UInt32 resolutionFlags = kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes;
        CFURLRef currentItemURL = NULL;
        
        if (LSSharedFileListItemResolve(loginItem, resolutionFlags, &currentItemURL, NULL) == noErr) {
            if (currentItemURL && CFEqual(currentItemURL, (__bridge CFTypeRef)itemURL)) {
                CFRelease(currentItemURL);
                return YES;
            }
            
            if (currentItemURL) {
                CFRelease(currentItemURL);
            }
        }
    }
    
    return NO;
}


#pragma mark - Basic Interface

- (NSURL *)mainApplicationURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (void)setLaunchAtLoginEnabled:(BOOL)enabled
{
    [self willChangeValueForKey:kStartAtLoginKey];
    [self setLaunchAtLoginEnabled:enabled forURL:[self mainApplicationURL]];
    [self didChangeValueForKey:kStartAtLoginKey];
}

- (BOOL)isLaunchAtLoginEnabled
{
    return [self isLaunchAtLoginEnabled:[self mainApplicationURL]];
}

@end
