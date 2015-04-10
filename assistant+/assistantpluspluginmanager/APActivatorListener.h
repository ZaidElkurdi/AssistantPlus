//
//  APActivatorListener.h
//  
//
//  Created by Zaid Elkurdi on 4/2/15.
//
//

#import <Foundation/Foundation.h>

@interface APActivatorListener : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *triggerString;
@property (strong, nonatomic) NSRegularExpression *trigger;
@property (strong, nonatomic) NSString *identifier;
@property (nonatomic) BOOL willPassthrough;
- (id)initWithDictionary:(NSDictionary*)dict;
@end
