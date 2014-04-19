//
//  AppDelegate.m
//  LaunchAtLoginHelper
//
//  Created by Katsuma Tanaka on 2014/04/13.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

#import "AppDelegate.h"

static NSString * const kMainAppName = @"LaunchAtLoginWithHelperApplication";
static NSString * const kMainAppBundleIdentifier = @"jp.questbeat.LaunchAtLoginWithHelperApplication";
static NSString * const kMainAppURLScheme = @"launchatloginwithha";

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Launch at Login"
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@"Hoge"];
    [alert runModal];
    
    // Check whether the main application is running and active
    BOOL running = NO;
    BOOL active = NO;
    
    NSArray *applications = [NSRunningApplication runningApplicationsWithBundleIdentifier:kMainAppBundleIdentifier];
    if (applications.count > 0) {
        NSRunningApplication *application = [applications firstObject];
        
        running = YES;
        active = [application isActive];
    }
    
    if (!running && !active) {
        // Launch main application
        NSURL *applicationURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", kMainAppURLScheme]];
        [[NSWorkspace sharedWorkspace] openURL:applicationURL];
        
        /*
         // If your app is not sandboxed, use this code instead of above code.
         
         // Build path to main application
         NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
         
         NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:[bundlePath pathComponents]];
         [pathComponents removeLastObject];
         [pathComponents removeLastObject];
         [pathComponents removeLastObject];
         [pathComponents addObject:@"MacOS"];
         [pathComponents addObject:kMainAppName];
         NSString *applicationPath = [NSString pathWithComponents:pathComponents];
         
         // Launch main application
         [[NSWorkspace sharedWorkspace] launchApplication:applicationPath];
         */
    }
    
    // Quit
    [NSApp terminate:nil];
}

@end
