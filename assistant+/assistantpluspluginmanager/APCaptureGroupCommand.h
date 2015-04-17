//
//  APCaptureGroupCommand.h
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 4/14/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCaptureGroupCommand : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *variables;
@property (nonatomic, strong) NSArray *conditionals;
@property (nonatomic, strong) NSRegularExpression *trigger;
@property (nonatomic, strong) NSString *command;
@property (nonatomic, strong) NSString *uuid;

-(id)initWithDictionary:(NSDictionary*)dict;
-(NSString*)buildCommandWithValues:(NSArray*)values;
@end
