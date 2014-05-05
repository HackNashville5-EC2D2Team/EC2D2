//
//  AmazonEC2Instance.h
//  TestProject
//
//  Created by Zach McCormick on 5/3/14.
//  Copyright (c) 2014 Zach McCormick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AmazonEC2Instance : NSObject

@property NSString* name; // this is the Name tag.  Could be null/unnamed
@property NSString* publicIp; // 111.222.112.221, for instance
@property NSString* availabilityZone; // us-east-1b, for instance
@property NSString* instanceType; // t1.micro, m1.small, etc
@property NSString* instanceId; // the unique instance ID
@property NSString* imageId; // the AMI image ID
@property NSString* state; // running, stopped, terminated, etc
@property NSString* keyName; // name of EC2 keypair used

@end
