//
//  AppDelegate.m
//  LaunchAtLoginWithHelperApplication
//
//  Created by Katsuma Tanaka on 2014/04/13.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

#import "AppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>

static NSString * const kHelperAppName = @"LaunchAtLoginHelper";
static NSString * const kHelperAppBundleIdentifier = @"jp.questbeat.LaunchAtLoginHelper";

@interface AppDelegate ()

@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSButton *launchAtLoginButton;

@property (nonatomic, strong) NSStatusItem *statusItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Register defaults
    NSString *launchAtLoginKey = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".launchAtLogin"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ launchAtLoginKey: @(NO) }];
    
    // Create status item
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.image = [NSImage imageNamed:@"status_icon"];
    statusItem.alternateImage = [NSImage imageNamed:@"status_icon_highlighted"];
    statusItem.highlightMode = YES;
    statusItem.target = self;
    statusItem.action = @selector(showStatusMenu:);
    
    self.statusItem = statusItem;
    
    // Configure views
    BOOL launchAtLogin = [[NSUserDefaults standardUserDefaults] boolForKey:launchAtLoginKey];
    self.launchAtLoginButton.state = launchAtLogin ? NSOnState : NSOffState;
}


#pragma mark - Status Menu

- (void)showStatusMenu:(id)sender
{
    [self.statusItem popUpStatusItemMenu:self.statusMenu];
}

- (IBAction)showWindow:(id)sender
{
    if (![self.window isVisible]) {
        [self.window makeKeyAndOrderFront:nil];
    }
}


#pragma mark - Actions

- (IBAction)toggleLaunchAtLogin:(id)sender
{
    // Toggle launch at login
    BOOL enabled = (self.launchAtLoginButton.state == NSOnState);
    [self setLaunchAtLoginEnabled:enabled];
    
    // Save user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *launchAtLoginKey = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".launchAtLogin"];
    [userDefaults setBool:enabled forKey:launchAtLoginKey];
    [userDefaults synchronize];
}


#pragma mark - Launch at Login

- (void)setLaunchAtLoginEnabled:(BOOL)enabled
{
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)kHelperAppBundleIdentifier, (Boolean)enabled)) {
        NSLog(@"Error: Failed to enable login item.");
    }
}

@end
