//
//  APCustomReply.h
//  AssistantPlusApp
//
//  Created by Zaid Elkurdi on 3/25/15.
//  Copyright (c) 2015 Zaid Elkurdi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCustomReply : NSObject

@property (nonatomic, strong) NSString *trigger;
@property (nonatomic, strong) NSString *response;
@property (nonatomic, strong) NSString *uuid;

-(id)initWithDictionary:(NSDictionary*)dict;
- (NSDictionary*)dictionaryRepresentation;

@end
