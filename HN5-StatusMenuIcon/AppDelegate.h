//
//  AppDelegate.h
//  HN5-StatusMenuIcon
//
//  Created by Peter Kaminski on 5/2/14.
//  Copyright (c) 2014 Peter Kaminski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AmazonEC2Instance.h"
#import "AmazonEC2ToolKit.h"
@interface AppDelegate : NSObject <NSApplicationDelegate>{
    
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightedImage;
    AmazonEC2ToolKit *toolKit;
}




@property (assign) IBOutlet NSWindow *window;

@property IBOutlet NSWindow* settingsWindow;

@property IBOutlet NSWindow* instanceDetailsWindow;
@property IBOutlet NSTextField* instanceDetails_name;
@property IBOutlet NSTextField* instanceDetails_publicIp;
@property IBOutlet NSTextField* instanceDetails_availabilityZone;
@property IBOutlet NSTextField* instanceDetails_instanceType;
@property IBOutlet NSTextField* instanceDetails_instanceId;
@property IBOutlet NSTextField* instanceDetails_imageId;
@property IBOutlet NSTextField* instanceDetails_state;
@property IBOutlet NSTextField* instanceDetails_keyName;

//Fields that are udpated within settings
@property IBOutlet NSTextField *accessField;
@property IBOutlet NSTextField *secretAccessField;
@property IBOutlet NSTextField *regionField;


//Settings that need to be updated
@property NSString *accessText;
@property NSString *secretText;
@property NSString *regionText;


-(IBAction)hideInstanceDetailsFromSender:(id)sender;

//This action configures the users settings and updates them in NSUserPreferences
-(IBAction)configureSettings:(id)sender;

-(IBAction)openSettings:(id)sender;

-(void)removePreviousMenuItems;

@end
