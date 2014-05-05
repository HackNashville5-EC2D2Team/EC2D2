//
//  AppDelegate.m
//  HN5-StatusMenuIcon
//
//  Created by Peter Kaminski on 5/2/14.
//  Copyright (c) 2014 Peter Kaminski. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //Initialize the three keys based on user defaults
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"accessKey"] != nil)
        self.accessText = [[NSUserDefaults standardUserDefaults] stringForKey:@"accessKey"];
    else
        self.accessText = @"";
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"secretKey"] != nil)
        self.secretText = [[NSUserDefaults standardUserDefaults] stringForKey:@"secretKey"];
    else
        self.secretText = @"";
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"regionKey"] != nil)
        self.regionText = [[NSUserDefaults standardUserDefaults] stringForKey:@"regionKey"];
    else
        self.regionText = @"";
    
    //Let's set the textfield values so the user knows what they are working with
    [self.accessField setStringValue:self.accessText];
    [self.secretAccessField setStringValue:self.secretText];
    [self.regionField setStringValue:self.regionText];
    
    //Synchronize these for safe measure
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //If any of these are null we should alert the user to change their settings.
    if(self.accessText == nil || self.secretText == nil || self.regionText == nil)
    {
        NSAlert *setSettingsAlert = [[NSAlert alloc] init];
        [setSettingsAlert setMessageText:@"Your settings aren't configured, configure them now"];
        [setSettingsAlert runModal];
        
        NSLog(@"Access Key: %@, Secret Access Key: %@, Region ID: %@", self.accessText, self.secretText, self.regionText);
    }
    else
    {
        NSLog(@"Access Key: %@, Secret Access Key: %@, Region ID: %@", self.accessText, self.secretText, self.regionText);
        [self updateUI:nil];
    }
    
}



///This sets the users settings based upon the value of the text fields in the settings window
-(IBAction)configureSettings:(id)sender{
    self.accessText = [self.accessField stringValue];
    self.secretText = [self.secretAccessField stringValue];
    self.regionText = [self.regionField stringValue];
    
    NSLog(@"Access Key: %@, Secret Access Key: %@, Region ID: %@", self.accessText, self.secretText, self.regionText);
    
    //Now update the user defaults
    [[NSUserDefaults standardUserDefaults] setObject:[self.accessField stringValue] forKey:@"accessKey"];
    [[NSUserDefaults standardUserDefaults] setObject:[self.secretAccessField stringValue] forKey:@"secretKey"];
    [[NSUserDefaults standardUserDefaults] setObject:[self.regionField stringValue] forKey:@"regionKey"];
    
    //Make sure we synchronize
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSWindow *theWindow = [sender window];
    [theWindow close];
}


- (IBAction)doSSH:(id)sender {
    NSLog(@"Doing SSH");

    NSString *publicIp = [_instanceDetails_publicIp stringValue];
    NSString *keyname = [_instanceDetails_keyName stringValue];
    
    NSString *s = [NSString stringWithFormat:
                   @"tell application \"Terminal\" to do script \"echo To SSH, use IP %@ and key %@.\"", publicIp, keyname];
    
    NSAppleScript *as = [[NSAppleScript alloc] initWithSource: s];
    [as executeAndReturnError:nil];
    [self hideInstanceDetailsFromSender:sender];
}

//Pulls up the window that displays instance details to the user
-(IBAction) displayInstanceDetailsFor:(id)sender
{
    AmazonEC2Instance* instance = nil;
    if([[sender representedObject] isKindOfClass:[AmazonEC2Instance class]])
        instance = [sender representedObject];
    else
    {
        NSLog(@"The call failed, your represented object is: %@", [sender representedObject]);
        return;
    }
    if (instance.name != nil)
    {
        [_instanceDetails_name setStringValue:instance.name];
    }
    else
    {
        [_instanceDetails_name setStringValue:@"Unnamed instance here"];
    }
    if (instance.publicIp != nil)
    {
        [_instanceDetails_publicIp setStringValue:instance.publicIp];
    }
    else
    {
        [_instanceDetails_publicIp setStringValue:@"none"];
    }
    if (instance.availabilityZone != nil)
    {
        [_instanceDetails_availabilityZone setStringValue:instance.availabilityZone];
    }
    else
    {
        [_instanceDetails_availabilityZone setStringValue:@"none"];
    }
    if (instance.instanceType != nil)
    {
        [_instanceDetails_instanceType setStringValue:instance.instanceType];
    }
    else
    {
        [_instanceDetails_instanceType setStringValue:@"none"];
    }
    if (instance.instanceId != nil)
    {
        [_instanceDetails_instanceId setStringValue:instance.instanceId];
    }
    else
    {
        [_instanceDetails_instanceId setStringValue:@"none"];
    }
    if (instance.imageId != nil)
    {
        [_instanceDetails_imageId setStringValue:instance.imageId];
    }
    else
    {
        [_instanceDetails_imageId setStringValue:@"none"];
    }
    if (instance.state != nil)
    {
        [_instanceDetails_state setStringValue:instance.state];
    }
    else
    {
        [_instanceDetails_state setStringValue:@"unknown"];
    }
    if (instance.keyName != nil)
    {
        [_instanceDetails_keyName setStringValue:instance.keyName];
    }
    else
    {
        [_instanceDetails_keyName setStringValue:@"none"];
    }
    [NSApp activateIgnoringOtherApps:YES];
    [_instanceDetailsWindow setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
    [_instanceDetailsWindow makeKeyAndOrderFront:sender];
}



-(IBAction)hideInstanceDetailsFromSender:(id)sender
{
    if ([_instanceDetailsWindow isVisible])
        [_instanceDetailsWindow orderOut:sender];
}

-(void)awakeFromNib{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    //[statusItem setTitle:@"EC2"];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"EC2 Widget"];
    [statusItem setHighlightMode:YES];
    
    NSBundle *bundle = [NSBundle mainBundle];
    statusImage = [[NSImage alloc]initWithContentsOfFile:[bundle pathForResource:@"ec2d2-16" ofType:@"png"]];
    [statusItem setImage:statusImage];
    
    
}

- (IBAction)updateUI:(NSMenuItem *)sender {
    
    dispatch_queue_t updateQueue = dispatch_queue_create("Update Queue", NULL);
    dispatch_async(updateQueue, ^{
        //Update the menu item to remove all the previous NSMenuItems
        [self removePreviousMenuItems];
        //Create a new tool kit instance based on the updates values, if any
        NSString* region = [[NSUserDefaults standardUserDefaults] stringForKey:@"regionKey"];
        NSString* accessKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"accessKey"];
        NSString* secretKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"secretKey"];
        
        if (region != nil && accessKey != nil && secretKey != nil)
        {
            AmazonEC2ToolKit *toolkit = [[AmazonEC2ToolKit alloc]
                                         initWithRegion:region
                                         andAccessKeyId:accessKey
                                         andSecretAccessKey:secretKey];
            NSArray *array = [toolkit describeInstances];
            NSMutableString* mutableString = [[NSMutableString alloc] init];
            int count = 0;
            for (AmazonEC2Instance* instance in array)
            {
                [mutableString appendString:instance.name];
                [mutableString appendString:@"("];
                if (instance.publicIp != nil)
                    [mutableString appendString:instance.publicIp];
                [mutableString appendString:@")"];
                [mutableString appendString:@"\n"];
                
                //Add all of our instances to the status menu, based on the size of the display
                [statusMenu insertItemWithTitle:instance.name action:@selector(displayInstanceDetailsFor:) keyEquivalent:@"" atIndex:count];
                //Set the type of object that the menu item can be, in this case it is a type of AmazonEC2Instance
                [[statusMenu itemAtIndex:count] setRepresentedObject:instance];
                
                //Just for test purposes lets log the instances as they are retrieved by the array.
                NSLog(@"%@[%d]", mutableString, count++);
            } // end for
        } // end if
    }); // end dispatch_async
   
}

-(IBAction)openSettings:(id)sender
{
    // this trick makes it pop up in front of other apps
    [NSApp activateIgnoringOtherApps:YES];
    [_settingsWindow setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
    [_settingsWindow makeKeyAndOrderFront:sender];
}

-(void)removePreviousMenuItems{
   
    NSArray *menuItems = [statusMenu itemArray];
    for(NSMenuItem *item in menuItems){
        if([[item representedObject] isKindOfClass:[AmazonEC2Instance class]]){
            [statusMenu removeItem:item];
        }
    }

}

@end
