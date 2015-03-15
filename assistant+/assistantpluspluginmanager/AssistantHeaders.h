//
//  AssistantHeaders.h
//  
//
//  Created by Zaid Elkurdi on 3/7/15.
//

#ifndef _AssistantHeaders_h
#define _AssistantHeaders_h

static char kAPPluginAssociatedObjectKey;

@interface BasicAceContext : NSObject
+ (id)sharedBasicAceContext;
- (void)registerGroupAcronym:(id)arg1 forGroupWithIdentifier:(id)arg2;
- (id)aceObjectWithDictionary:(id)arg1;
- (Class)classWithClassName:(id)arg1 group:(id)arg2;
@end

@interface AceObject : NSObject
@property(copy, nonatomic) NSString *refId;
@property(copy, nonatomic) NSString *aceId;
- (id)properties;
- (id)dictionary;
+ (id)aceObjectWithDictionary:(id)arg1 context:(id)arg2;
@end

@interface SiriUISnippetViewController : UIViewController
@property(retain) AceObject * aceObject;
-(void)siriWillActivateFromSource:(long long)arg1;
-(void)siriDidDeactivate;
-(void)wasAddedToTranscript;
-(AceObject *)aceObject;
-(void)setAceObject:(AceObject*)arg1;
@end



@interface SiriUITranscriptItem : NSObject {
//  AceObject *_aceObject;
//  NSUUID *_itemIdentifier;
  UIViewController *_viewController;
}

@property(retain) AceObject * aceObject;
@property(copy) id itemIdentifier;
@property(retain) UIViewController* viewController;

+ (id)transcriptItemWithAceObject:(id)arg1;

- (id)aceObject;
- (id)description;
- (id)initWithAceObject:(AceObject*)arg1;
- (id)itemIdentifier;
- (void)setAceObject:(AceObject*)arg1;
- (void)setItemIdentifier:(id)arg1;
- (void)setViewController:(UIViewController*)arg1;
- (id)viewController;

@end

@protocol SiriUISnippetPlugin <NSObject>
@optional
-(id)viewControllerForSnippet:(id)arg1;
-(id)viewControllerForSnippet:(id)arg1 error:(id*)arg2;
-(id)viewControllerForAceObject:(id)arg1;
-(id)disambiguationItemForListItem:(id)arg1 disambiguationKey:(id)arg2;
-(id)speakableNamespaceProviderForAceObject:(id)arg1;
@end


/// Type representing one Siri class description as NSMutableDictionary
//typedef NSMutableDictionary SOObject;

//#ifdef SC_PRIVATE
//# import "SiriObjects_private.h"
//# define SC_SUPER(cls) cls
//#else
//# define SC_SUPER(cls) NSObject
//#endif

/// Type representing a concrete SiriObject
@protocol SOAceObject <NSObject>
@required
/// Class name beginning with SA, e.g. SATest
- (id)encodedClassName;
/// Group identifier, e.g. com.company.ace
- (id)groupIdentifier;
@end

/// Any object (NSMutableDictionary)
typedef NSMutableDictionary SOObject;
/// Root object (NSMutableDictionary)
typedef SOObject SOAceObject;

@protocol AFSpeechDelegate <NSObject>
@end

@protocol AFAssistantUIService <NSObject>
@end

@interface CDUnknownBlockType : NSObject
@end

@interface AFConnection : NSObject
@property(nonatomic, weak) id <AFSpeechDelegate> speechDelegate;
@property(nonatomic, weak) id <AFAssistantUIService> delegate;
- (void)_doCommand:(id)arg1 reply:(id)arg2;
- (void)sendReplyCommand:(id)arg1;
- (void)_willCompleteRequest;
- (void)_tellDelegateRequestFinished;
@end

@interface SABaseCommand : AceObject
@property(copy, nonatomic) NSString *refId;
@property(copy, nonatomic) NSString *aceId;
@end

@interface SABaseClientBoundCommand : SABaseCommand
@property(copy, nonatomic) NSArray *callbacks;
@property(copy, nonatomic) NSString *appId;
@end

@interface SAUIAddViews : SABaseClientBoundCommand
@property(nonatomic) BOOL scrollToTop;
@property(copy, nonatomic) NSString *displayTarget;
@property(copy, nonatomic) NSString *dialogPhase;
@property(copy, nonatomic) NSArray *views;
@property(nonatomic) BOOL temporary;
+ (id)addViewsWithDictionary:(id)arg1 context:(id)arg2;
+ (id)addViews;
- (BOOL)requiresResponse;
- (id)encodedClassName;
- (id)groupIdentifier;
@end

@interface SAAceView : AceObject
@property(copy, nonatomic) NSString *speakableText;
@end

@interface SAUIAssistantUtteranceView : SAAceView
@property(copy, nonatomic) NSString *text;
@property(copy, nonatomic) NSString *dialogIdentifier;
+ (id)assistantUtteranceViewWithDictionary:(id)arg1 context:(id)arg2;
+ (id)assistantUtteranceView;
- (id)encodedClassName;
- (id)groupIdentifier;
@end

@interface SAUISnippet : SAAceView
+ (id)snippetWithDictionary:(id)arg1 context:(id)arg2;
@end

@interface SASRecognition : AceObject
@property(nonatomic) int sentenceConfidence;
@property(copy, nonatomic) NSArray *phrases;
@end

@interface SASSpeechRecognized : SABaseClientBoundCommand
@property(retain, nonatomic) SASRecognition *recognition;
@end

@interface AFSpeechToken : NSObject
@property(copy, nonatomic) NSString *text;
@end

@interface AFSpeechInterpretation : NSObject
@property(copy, nonatomic) NSArray *tokens;
@end

@interface AFSpeechPhrase : NSObject
@property(copy, nonatomic) NSArray *interpretations;
@end

@interface SASInterpretation : AceObject
@property(copy, nonatomic) NSArray *tokens;
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

#endif
