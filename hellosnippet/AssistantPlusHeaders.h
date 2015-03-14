//
//  AssistantPlusHeaders.h
//  
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#ifndef _AssistantPlusHeaders_h
#define _AssistantPlusHeaders_h

@interface AceObject : NSObject
@property(copy, nonatomic) NSString *refId;
@property(copy, nonatomic) NSString *aceId;
+ (id)aceObjectWithDictionary:(id)arg1 context:(id)arg2;
@end

@interface APSession : NSObject
- (void)sendSnippetWithText:(NSString*)text;
@end

@protocol APPluginManager <NSObject>
@required
/// Register a command class
-(BOOL)registerCommand:(Class)cls;
/// Register a snippet class
-(BOOL)registerSnippet:(Class)cls;


-(NSString*)localizedString:(NSString*)text;

-(NSString*)systemVersion;
@end

@protocol SiriUIViewController <NSObject>
@property (nonatomic,retain) AceObject * aceObject;
@optional
-(id)navigationTitle;
-(void)transcriptViewControllerTappedOutsideEditingView;

@required
-(double)desiredHeightForWidth:(double)arg1;
-(void)siriWillActivateFromSource:(long long)arg1;
-(void)siriDidDeactivate;
-(void)wasAddedToTranscript;
-(AceObject *)aceObject;
-(void)setAceObject:(AceObject*)arg1;
@end

@protocol APPluginSnippet <SiriUIViewController>
@optional
/// Initializes a snippet by properties
-(id)initWithProperties:(NSDictionary*)props;
/// Initializes a snippet by properties and system
-(id)initWithProperties:(NSDictionary*)props system:(id<APPluginManager>)system;
/// Returns a view representing snippet, can be self if the conforming class is already UIView

@end

@interface APPluginSnippetViewController : UIViewController <APPluginSnippet>

@end


/** Protocol specifying methods of an extension class handling commands.
 Classes conforming to this protocol are initialized just after loading bundle and will remain in memory.
 Don't forget you really should prefix your class with some shortcut, e.g. K3AAwesomeCommand!
 */
@protocol APPluginCommand <NSObject>
@optional

-(BOOL)handleSpeech:(NSString*)text session:(APSession*)session;
-(id)initWithSystem:(id<APPluginManager>)manager;

-(void)assistantDismissed;

@end


/// Protocol specifying methods of the extension's principal class
@protocol APPlugin <NSObject>

@required
/// The first method which is called on your class, system is where you register commands and snippets
-(id)initWithSystem:(id<APPluginManager>)system;

@optional

-(void)assistantDismissed; //clean up

@end

#endif
