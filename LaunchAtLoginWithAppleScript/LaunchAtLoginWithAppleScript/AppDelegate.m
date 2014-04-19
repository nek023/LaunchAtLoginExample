//
//  AppDelegate.m
//  LaunchAtLoginWithAppleScript
//
//  Created by Katsuma Tanaka on 2014/04/13.
//  Copyright (c) 2014年 Katsuma Tanaka. All rights reserved.
//

#import "AppDelegate.h"

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
    // Load script
    NSString *fileName = enabled ? @"AddLoginItem" : @"DeleteLoginItem";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"scpt"];
    NSString *template = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSString *source;
    NSString *localizedName = [[NSRunningApplication currentApplication] localizedName];
    if (enabled) {
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        source = [NSString stringWithFormat:template, bundlePath, localizedName];
    } else {
        source = [NSString stringWithFormat:template, localizedName, localizedName];
    }
    
    // Run script
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
    
    NSDictionary *error = nil;
    [script executeAndReturnError:&error];
    
    if (error) {
        NSLog(@"Error: %@", error[NSAppleScriptErrorBriefMessage]);
    }
}

@end
