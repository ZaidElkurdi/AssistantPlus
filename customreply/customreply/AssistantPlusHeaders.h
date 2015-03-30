//
//  AssistantPlusHeaders.h
//  
//
//  Created by Zaid Elkurdi on 3/12/15.
//
//

#ifndef _AssistantPlusHeaders_h
#define _AssistantPlusHeaders_h

@protocol APSiriSession <NSObject>
- (void)sendTextSnippet:(NSString*)text temporary:(BOOL)temporary scrollToTop:(BOOL)toTop dialogPhase:(NSString*)phase;
-(NSMutableDictionary*)createTextSnippet:(NSString*)text;
- (void)sendAddViews:(NSArray*)views;
- (void)sendAddViews:(NSArray*)views dialogPhase:(NSString*)dialogPhase scrollToTop:(BOOL)toTop temporary:(BOOL)temporary;
-(NSMutableDictionary*)createSnippet:(NSString*)snippetClass properties:(NSDictionary*)props;
- (void)sendCustomSnippet:(NSString*)snippetClass withProperties:(NSDictionary*)props;
- (void)sendRequestCompleted;
-(NSMutableDictionary*)createAssistantUtteranceView:(NSString*)text;
- (void)getCurrentLocationWithCompletion:(void (^)(NSDictionary *info))completion;
@end

@protocol APPluginManager <NSObject>
@required
/// Register a command class
-(BOOL)registerCommand:(Class)cls;
/// Register a snippet class
-(BOOL)registerSnippet:(Class)cls;
@end

@interface AceObject : NSObject
@property(copy, nonatomic) NSString *refId;
@property(copy, nonatomic) NSString *aceId;
+ (id)aceObjectWithDictionary:(id)arg1 context:(id)arg2;
@end

@protocol SiriUIViewController <NSObject>
@property (nonatomic,retain) AceObject * aceObject;
@optional
-(double)desiredHeightForWidth:(double)arg1;
-(double)desiredHeight;
-(id)navigationTitle;
-(void)transcriptViewControllerTappedOutsideEditingView;

@required
-(void)siriWillActivateFromSource:(long long)arg1;
-(void)siriDidDeactivate;
-(void)wasAddedToTranscript;
-(AceObject *)aceObject;
-(void)setAceObject:(AceObject*)arg1;
@end

@protocol APPluginSnippet <SiriUIViewController>
@required
-(double)desiredHeightForWidth:(double)height;
@optional
/// Initializes a snippet by properties
-(id)initWithProperties:(NSDictionary*)props;
/// Initializes a snippet by properties and system
-(id)initWithProperties:(NSDictionary*)props system:(id<APPluginManager>)system;
/// Returns a view representing snippet, can be self if the conforming class is already UIView
@end


/** Protocol specifying methods of an extension class handling commands.
 Classes conforming to this protocol are initialized just after loading bundle and will remain in memory.
 Don't forget you really should prefix your class with some shortcut, e.g. K3AAwesomeCommand!
 */
@protocol APPluginCommand <NSObject>
@required
-(BOOL)handleSpeech:(NSString*)text withTokens:(NSSet*)tokens withSession:(id<APSiriSession>)session;
@optional
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
