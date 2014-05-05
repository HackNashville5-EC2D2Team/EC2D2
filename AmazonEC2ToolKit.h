//
//  AmazonEC2ToolKit.h
//  TestProject
//
//  Created by Zach McCormick on 5/3/14.
//  Copyright (c) 2014 Zach McCormick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AmazonEC2Instance.h"

@interface AmazonEC2ToolKit : NSObject

@property NSString* awsRegion;
@property NSString* awsAccessKeyId;
@property NSString* awsSecretAccessKey;

// constructors
- (id) init;
- (id) initWithRegion:(NSString*)awsRegion
        andAccessKeyId:(NSString*)awsAccessKeyId
        andSecretAccessKey:(NSString*)awsSecretAccessKey;

// calls to CLI
- (NSArray*) describeInstances;
@end
