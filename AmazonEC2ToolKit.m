//
//  AmazonEC2ToolKit.m
//  TestProject
//
//  Created by Zach McCormick on 5/3/14.
//  Copyright (c) 2014 Zach McCormick. All rights reserved.
//

#import "AmazonEC2ToolKit.h"

@implementation AmazonEC2ToolKit

- (id) init
{
    self = [super init];
    return self;
}

- (id) initWithRegion:(NSString*)awsRegion
       andAccessKeyId:(NSString*)awsAccessKeyId
   andSecretAccessKey:(NSString*)awsSecretAccessKey
{
    self = [super init];
    if (self)
    {
        [self setAwsRegion:awsRegion];
        [self setAwsAccessKeyId:awsAccessKeyId];
        [self setAwsSecretAccessKey:awsSecretAccessKey];
    }
    return self;
}

- (NSArray*) describeInstances
{
    NSMutableArray* ec2instances = [[NSMutableArray alloc] init];
    NSString* jsonString = [self executeEC2Command:@"describe-instances"];
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
    NSArray* reservations = [response valueForKey:@"Reservations"];
    for (NSDictionary *reservation in reservations)
    {
        NSArray* instances = [reservation valueForKey:@"Instances"];
        for (NSDictionary* instance in instances)
        {
            AmazonEC2Instance* ec2instance = [[AmazonEC2Instance alloc] init];
            ec2instance.name = @""; // in case they didn't add a Name tag, we'll use empty string
            ec2instance.publicIp = [instance valueForKey:@"PublicIpAddress"];
            ec2instance.availabilityZone = [[instance valueForKey:@"Placement"] valueForKey:@"AvailabilityZone"];
            ec2instance.instanceId = [instance valueForKey:@"InstanceId"];
            ec2instance.imageId = [instance valueForKey:@"ImageId"];
            ec2instance.instanceType = [instance valueForKey:@"InstanceType"];
            ec2instance.state = [[instance valueForKey:@"State"] valueForKey:@"Name"];
            ec2instance.keyName = [instance valueForKey:@"KeyName"];
            NSArray* tags = [instance valueForKey:@"Tags"];
            for (NSDictionary* tag in tags)
            {
                if ([[tag valueForKey:@"Key"] isEqualToString:@"Name"])
                {
                    ec2instance.name = [tag valueForKey:@"Value"];
                }
            }
            [ec2instances addObject:ec2instance];
        }
    }
    
    return [[NSArray alloc] initWithArray:ec2instances];
}

- (NSString*) executeEC2Command:(NSString*)command
{
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/local/bin/aws"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"ec2", command, nil];
    setenv("AWS_DEFAULT_REGION", [_awsRegion UTF8String], 1);
    setenv("AWS_ACCESS_KEY_ID", [_awsAccessKeyId UTF8String], 1);
    setenv("AWS_SECRET_ACCESS_KEY", [_awsSecretAccessKey UTF8String], 1);
    
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    // launch the aws command
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"aws returned:\n%@", string);
    return string;
}

@end
