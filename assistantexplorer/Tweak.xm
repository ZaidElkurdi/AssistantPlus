#import "AssistantMusicController.h"
#import "AssistantQueryParser.h"
#import "AssistantQueryHandler.h"
#import "AssistantAceCommandBuilder.h"
#import <Foundation/Foundation.h>
#import "HelloSnippetViewController.h"

@protocol SAAceSerializable <NSObject>
@end

@interface SBUIPluginController : NSObject
@end

@interface SAUIAppPunchOut : NSObject
@end

@interface SAUIConfirmationOptions : NSObject
@end

@interface SiriUIPluginManager : NSObject
+ (id)sharedInstance;
- (id)_bundleSearchPaths;
- (void)_loadBundleMapsIfNecessary;
@end

static AssistantQueryHandler *queryHandler = [[AssistantQueryHandler alloc] init];
static AssistantMusicController *musicController = [[AssistantMusicController alloc] init];

static BOOL defaultHandling = YES;
static AFConnection *currConnection;

%hook AFUISiriSession
- (AFConnection * )_connection { %log; AFConnection *  r = %orig; NSLog(@" = %@", r); return r; }
- (NSString * )debugDescription { %log; NSString *  r = %orig; NSLog(@" = %@", r); return r; }
- (NSString * )description { %log; NSString *  r = %orig; NSLog(@" = %@", r); return r; }
- (void)setEyesFree:(bool )eyesFree { %log; %orig; }
- (bool )isEyesFree { %log; bool  r = %orig; NSLog(@" = %d", r); return r; }
- (unsigned long long )hash { %log; unsigned long long  r = %orig; NSLog(@" = %llu", r); return r; }
+ (unsigned long long)availabilityState { %log; unsigned long long r = %orig; NSLog(@" = %llu", r); return r; }
+ (void)beginMonitoringSiriAvailability { %log; %orig; }
+ (id)effectiveCoreLocationBundle { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)_didChangeDialogPhase:(id)arg1 { %log; %orig; }
- (void)_handleRequestUpdateViewsCommand:(id)arg1 { %log; %orig; }
- (void)_handleUnlockDeviceCommand:(id)arg1 { %log; %orig; }
- (bool)_hasActiveRequest { %log; bool r = %orig; NSLog(@" = %d", r); return r; }
- (void)_outputVoiceDidChange:(id)arg1 { %log; %orig; }
- (void)_performAceCommand:(id)arg1 forRequestUpdateViewsCommand:(id)arg2 afterDelay:(double)arg3 { %log; %orig; }
- (void)_performBlockWithDelegate:(id)arg1 { %log; %orig; }
- (void)_performTransitionForEvent:(long long)arg1 { %log; %orig; }
- (id)_preparedSpeechRequestWithRequestOptions:(id)arg1 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)_requestContextWithCompletion:(id)arg1 { %log; %orig; }
- (void)_requestDidFinishWithError:(id)arg1 { %log; %orig; }
- (void)_requestWillStart { %log; %orig; }
- (void)_siriNetworkAvailabilityDidChange:(id)arg1 { %log; %orig; }
- (void)_startContinuityRequestWithInfo:(id)arg1 { %log; %orig; }
- (void)_startDirectActionRequestWithString:(id)arg1 appID:(id)arg2 withMessagesContext:(id)arg3 { %log; %orig; }
- (void)_startRequestWithBlock:(id)arg1 { %log; %orig; }
- (void)_startRequestWithFinalOptions:(id)arg1 { %log; %orig; }
- (void)_startRequestWithText:(id)arg1 { %log; %orig; }
- (void)_startSpeechPronunciationRequestWithContext:(id)arg1 options:(id)arg2 { %log; %orig; }
- (void)_startSpeechRequestWithOptions:(id)arg1 { %log; %orig; }
- (void)_startSpeechRequestWithSpeechFileAtURL:(id)arg1 { %log; %orig; }
- (long long)_state { %log; long long r = %orig; NSLog(@" = %lld", r); return r; }
- (id)_stateMachine { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)_voiceOverStatusDidChange:(id)arg1 { %log; %orig; }
- (void)assistantConnection:(id)arg1 didChangeAudioSessionID:(unsigned int)arg2 { %log; %orig; }
- (void)assistantConnection:(id)arg1 didFinishAcousticIDRequestWithSuccess:(bool)arg2 { %log; %orig; }
- (void)assistantConnection:(id)arg1 openURL:(id)arg2 completion:(id)arg3 { %log; %orig; }
- (void)assistantConnection:(id)arg1 receivedCommand:(id)arg2 { %log; %orig; }
- (void)assistantConnection:(id)arg1 requestFailedWithError:(id)arg2 requestClass:(id)arg3 { %log; %orig; }
- (void)assistantConnection:(id)arg1 shouldSpeak:(bool)arg2 { %log; %orig; }
- (void)assistantConnection:(id)arg1 speechRecognized:(id)arg2 { %log; %orig; }
- (void)assistantConnection:(id)arg1 speechRecognizedPartialResult:(id)arg2 { %log; %orig; }
- (void)assistantConnection:(id)arg1 speechRecordingDidBeginOnAVRecordRoute:(id)arg2 { %log; %orig; }
- (void)assistantConnection:(id)arg1 speechRecordingDidChangeAVRecordRoute:(id)arg2 { %log; %orig; }
- (void)assistantConnection:(id)arg1 speechRecordingDidFail:(id)arg2 { %log; %orig; }
- (void)assistantConnectionDidChangeAudioRecordingPower:(id)arg1 { %log; %orig; }
- (void)assistantConnectionDidDetectMusic:(id)arg1 { %log; %orig; }
- (void)assistantConnectionDismissAssistant:(id)arg1 { %log; %orig; }
- (void)assistantConnectionRequestFinished:(id)arg1 { %log; %orig; }
- (void)assistantConnectionRequestWillStart:(id)arg1 { %log; %orig; }
- (void)assistantConnectionSpeechRecordingDidCancel:(id)arg1 { %log; %orig; }
- (void)assistantConnectionSpeechRecordingDidEnd:(id)arg1 { %log; %orig; }
- (void)assistantConnectionSpeechRecordingWillBegin:(id)arg1 { %log; %orig; }
- (void)cancelSpeechRequest { %log; %orig; }
- (void)clearContext { %log; %orig; }
- (void)dealloc { %log; %orig; }
- (id)delegate { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)end { %log; %orig; }
- (void)forceAudioSessionActive { %log; %orig; }
- (id)initWithConnection:(id)arg1 delegateQueue:(id)arg2 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (bool)isListening { %log; bool r = %orig; NSLog(@" = %d", r); return r; }
- (bool)isPreventingActivationGesture { %log; bool r = %orig; NSLog(@" = %d", r); return r; }
- (id)localDataSource { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)localDelegate { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)performAceCommand:(id)arg1 conflictHandler:(id)arg2 { %log; %orig; }
- (void)performAceCommand:(id)arg1 { %log; %orig; }
- (void)preheat { %log; %orig; }
- (void)recordMetrics:(id)arg1 { %log; %orig; }
- (float)recordingPowerLevel { %log; float r = %orig; NSLog(@" = %f", r); return r; }
- (void)requestDidPresent { %log; %orig; }
- (void)resetContext { %log; %orig; }
- (void)resultDidChangeForAceCommand:(id)arg1 { %log; %orig; }
- (void)rollbackClearContext { %log; %orig; }
- (void)sendReplyCommand:(id)arg1 { %log; %orig; }
- (void)setAlertContext { %log; %orig; }
- (void)setApplicationContext { %log; %orig; }
- (void)setDelegate:(id)arg1 { %log; %orig; }
- (void)setIsStark:(bool)arg1 { %log; %orig; }
- (void)setLocalDataSource:(id)arg1 { %log; %orig; }
- (void)setLocalDelegate:(id)arg1 { %log; %orig; }
- (void)setLockState:(unsigned long long)arg1 { %log; %orig; }
- (void)setOverriddenApplicationContext:(id)arg1 withSMSContext:(id)arg2 { %log; %orig; }
- (id)speechSynthesis { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)speechSynthesisWillStartSpeaking:(id)arg1 { %log; %orig; }
- (void)startCorrectedRequestWithText:(id)arg1 correctionIdentifier:(id)arg2 { %log; %orig; }
- (void)startRequestWithOptions:(id)arg1 { %log; %orig; }
- (id)stateMachine:(id)arg1 descriptionForEvent:(long long)arg2 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)stateMachine:(id)arg1 didTransitionFromState:(long long)arg2 forEvent:(long long)arg3 { %log; %orig; }
- (void)stopRecordingSpeech { %log; %orig; }
- (void)stopRequestWithOptions:(id)arg1 { %log; %orig; }
- (void)telephonyRequestCompleted { %log; %orig; }
- (id)underlyingConnection { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)updateRequestOptions:(id)arg1 { %log; %orig; }
%end


%hook SAAceView
+ (id)aceViewWithDictionary:(id)arg1 context:(id)arg2 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
+ (id)aceView { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)setViewId:(NSString *)viewId { %log; %orig; }
- (NSString *)viewId { %log; NSString * r = %orig; NSLog(@" = %@", r); return r; }
- (void)setSpeakableText:(NSString *)speakableText { %log; %orig; }
- (NSString *)speakableText { %log; NSString * r = %orig; NSLog(@" = %@", r); return r; }
- (void)setListenAfterSpeaking:(NSNumber *)listenAfterSpeaking { %log; %orig; }
- (NSNumber *)listenAfterSpeaking { %log; NSNumber * r = %orig; NSLog(@" = %@", r); return r; }
- (void)setDeferredRendering:(BOOL )deferredRendering { %log; %orig; }
- (BOOL )deferredRendering { %log; BOOL  r = %orig; NSLog(@" = %d", r); return r; }
- (void)setContext:(id)context { %log; %orig; }
- (id)context { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)encodedClassName { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)groupIdentifier { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (NSString *)debugDescription { %log; NSString * r = %orig; NSLog(@" = %@", r); return r; }
- (NSString *)description { %log; NSString * r = %orig; NSLog(@" = %@", r); return r; }
%end

%hook SiriUIPluginManager
+ (id)sharedInstance {
  
  id bundleMap;
  object_getInstanceVariable(self, "_identifierMap", (void **)&bundleMap);
  NSLog(@"BundleMap: %@", bundleMap);
  
  %log;
  id r = %orig;
  NSLog(@" = %@", r);
  return r;
}
- (id)_bundleSearchPaths { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)_createDebugViewControllerForAceObject:(id)arg1 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)_loadBundleMapsIfNecessary {
  NSLog(@"Search paths: %@", [self _bundleSearchPaths]);
  %log;
  %orig;
}
- (id)disambiguationItemForListItem:(id)arg1 disambiguationKey:(id)arg2 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)speakableProviderForObject:(id)arg1 { %log; id r = %orig; NSLog(@" = %@", r); return r; }

- (id)transcriptItemForObject:(AceObject*)arg1 {
  NSLog(@"ARG1 is: %@", arg1);
  %log;
//  return %orig;

  SiriUISnippetViewController *vc = [[%c(SiriUISnippetViewController) alloc] init];
  object_setClass(vc, [%c(HelloSnippetViewController) class]);
  SiriUITranscriptItem *item = [%c(SiriUITranscriptItem) transcriptItemWithAceObject:arg1];
  item.viewController = vc;
  NSLog(@"Returning: %@", item);
  return item;
//  id r = %orig;
//  NSLog(@" = %@", r);
//  return r;
}

%end


%hook SiriUITranscriptItem
+ (id)transcriptItemWithAceObject:(id)arg1 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)aceObject { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)description { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)initWithAceObject:(id)arg1 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)itemIdentifier { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)setAceObject:(id)arg1 { %log; %orig; }
- (void)setItemIdentifier:(id)arg1 { %log; %orig; }
- (void)setViewController:(id)arg1 { %log; %orig; }
- (id)viewController {
  id r = %orig;
  NSLog(@" Going to return = %@", r);
  return r; }
%end



%hook SiriUISnippetViewController
- (void)setAceObject:(AceObject * )aceObject { %log; %orig; }
- (AceObject * )aceObject { %log; AceObject *  r = %orig; NSLog(@" = %@", r); return r; }
- (void)setAttributedSubtitle:(NSAttributedString * )attributedSubtitle { %log; %orig; }
- (NSAttributedString * )attributedSubtitle { %log; NSAttributedString *  r = %orig; NSLog(@" = %@", r); return r; }
- (void)setCancelled:(bool )cancelled { %log; %orig; }
- (void)setConfirmed:(bool )confirmed { %log; %orig; }
- (bool )isConfirmed { %log; bool  r = %orig; NSLog(@" = %d", r); return r; }
- (NSString * )debugDescription { %log; NSString *  r = %orig; NSLog(@" = %@", r); return r; }
- (NSString * )description { %log; NSString *  r = %orig; NSLog(@" = %@", r); return r; }
- (unsigned long long )hash { %log; unsigned long long  r = %orig; NSLog(@" = %llu", r); return r; }
- (void)setHeaderPunchOut:(SAUIAppPunchOut * )headerPunchOut { %log; %orig; }
- (SAUIAppPunchOut * )headerPunchOut { %log; SAUIAppPunchOut *  r = %orig; NSLog(@" = %@", r); return r; }
- (SAUIConfirmationOptions * )_previousConfirmationOptions { %log; SAUIConfirmationOptions *  r = %orig; NSLog(@" = %@", r); return r; }
- (bool )_isProvisional { %log; bool  r = %orig; NSLog(@" = %d", r); return r; }
- (void)setRequestContext:(NSArray * )requestContext { %log; %orig; }
- (NSArray * )requestContext { %log; NSArray *  r = %orig; NSLog(@" = %@", r); return r; }
- (void)setSnippet:(SAUISnippet * )snippet { %log; %orig; }
- (SAUISnippet * )snippet { %log; SAUISnippet *  r = %orig; NSLog(@" = %@", r); return r; }
- (void)setSnippetPunchOut:(SAUIAppPunchOut * )snippetPunchOut { %log; %orig; }
- (SAUIAppPunchOut * )snippetPunchOut { %log; SAUIAppPunchOut *  r = %orig; NSLog(@" = %@", r); return r; }
- (void)setSubtitle:(NSString * )subtitle { %log; %orig; }
- (NSString * )subtitle { %log; NSString *  r = %orig; NSLog(@" = %@", r); return r; }
- (void)setTitle:(NSString * )title { %log; %orig; }
- (NSString * )title { %log; NSString *  r = %orig; NSLog(@" = %@", r); return r; }
- (bool )isVirgin { %log; bool  r = %orig; NSLog(@" = %d", r); return r; }
- (id)_headerView { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (long long)_insertionAnimation { %log; long long r = %orig; NSLog(@" = %lld", r); return r; }
- (long long)_pinAnimationType { %log; long long r = %orig; NSLog(@" = %lld", r); return r; }
- (id)_privateDelegate { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (long long)_replacementAnimation { %log; long long r = %orig; NSLog(@" = %lld", r); return r; }
- (void)_setProvisional:(bool)arg1 { %log; %orig; }
- (void)_setVirgin:(bool)arg1 { %log; %orig; }
- (void)_snippetPunchOutButtonTapped { %log; %orig; }
- (void)_snippetViewControllerWillBeRemoved { %log; %orig; }
- (void)cancelButtonTapped:(id)arg1 { %log; %orig; }
- (void)confirmButtonTapped:(id)arg1 { %log; %orig; }
- (id)delegate { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (double)desiredHeight { %log; double r = %orig; NSLog(@" = %f", r); return r; }
- (double)desiredHeightForFooterView { %log; double r = %orig; NSLog(@" = %f", r); return r; }
- (double)desiredHeightForHeaderView { %log; double r = %orig; NSLog(@" = %f", r); return r; }
- (double)desiredHeightForTransparentFooterView { %log; double r = %orig; NSLog(@" = %f", r); return r; }
- (double)desiredHeightForTransparentHeaderView { %log; double r = %orig; NSLog(@" = %f", r); return r; }
- (void)headerTapped:(id)arg1 { %log; %orig; }
- (id)initWithNibName:(id)arg1 bundle:(id)arg2 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (bool)removedAfterDialogProgresses { %log; bool r = %orig; NSLog(@" = %d", r); return r; }
  %end

  %hook SVSSnippetPluginBundle
  - (void)setBundle:(NSBundle * )bundle { %log; %orig; }
  - (NSBundle * )bundle { %log; NSBundle *  r = %orig; NSLog(@" = %@", r); return r; }
  - (void)setSnippetPlugin:(id)snippetPlugin { %log; %orig; }
  - (id)snippetPlugin { %log; id r = %orig; NSLog(@" = %@", r); return r; }
  + (id)snippetPluginWithBundle:(id)arg1 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
  %end

%hook SAUISnippet
+ (id)snippetWithDictionary:(id)arg1 context:(id)arg2 {
  %log;
  id r = %orig;
  NSLog(@" = %@", r);
  return r;
}

+ (id)snippet {
  %log;
  id r = %orig;
  NSLog(@" = %@", r);
  return r;
}
%end

%hook AFConnection
- (void)_doCommand:(SAUIAddViews*)arg1 reply:(id)arg2 {
  
  id service;
  object_getInstanceVariable(self, "_delegate", (void **)&service);
  NSLog(@"Service: %@", service);
  
  NSLog(@"Doing: %@", arg1);
  NSLog(@"Views: %@", arg1.views);
  %log;
  %orig;
}
+ (void)preheat { %log; %orig; }
+ (void)preheatWithStyle:(int)arg1 { %log; %orig; }
+ (void)defrost { %log; %orig; }
+ (id)outputVoice { %log; id r = %orig; NSLog(@" = %@", r); return r; }
+ (BOOL)isReadyForLanguageCode:(id)arg1 { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
+ (id)currentLanguageCode { %log; id r = %orig; NSLog(@" = %@", r); return r; }
+ (BOOL)userDataSyncNeeded { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
+ (void)stopMonitoringAvailability { %log; %orig; }
+ (BOOL)isAvailable { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
+ (void)beginMonitoringAvailability { %log; %orig; }
+ (BOOL)assistantIsSupported { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
+ (BOOL)assistantIsSupportedForLanguageCode:(id)arg1 error:(id *)arg2 { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
+ (void)initialize { %log; %orig; }
- (void)usefulUserResultWillPresent { %log; %orig; }
- (void)telephonyRequestCompleted { %log; %orig; }
- (void)prepareForPhoneCall { %log; %orig; }
- (void)setAlertContextWithBulletins:(id)arg1 { %log; %orig; }
- (void)setOverriddenApplicationContext:(id)arg1 withSMSContext:(id)arg2 { %log; %orig; }
- (void)setApplicationContextForApplicationInfos:(id)arg1 { %log; %orig; }
- (void)clearContext { %log; %orig; }
- (void)sendReplyCommand:(id)arg1 { %log; %orig; }
- (void)sendGenericAceCommand:(id)arg1 conflictHandler:(CDUnknownBlockType*)arg2 { %log; %orig; }
- (void)sendGenericAceCommand:(id)arg1 { %log; %orig; }
- (unsigned int)audioSessionID { %log; unsigned int r = %orig; NSLog(@" = %u", r); return r; }
- (BOOL)shouldSpeak { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
- (BOOL )isRecording { %log; BOOL  r = %orig; NSLog(@" = %d", r); return r; }
- (void)startRequestWithCorrectedText:(id)arg1 forSpeechIdentifier:(id)arg2 { %log; %orig; }
- (void)rollbackRequest { %log; %orig; }
- (void)rollbackClearContext { %log; %orig; }
- (void)recordMetrics:(id)arg1 { %log; %orig; }
- (void)updateSpeechOptions:(id)arg1 { %log; %orig; }
- (void)stopSpeechWithOptions:(id)arg1 { %log; %orig; }
- (void)stopSpeech { %log; %orig; }
- (void)cancelSpeech { %log; %orig; }
- (void)startAcousticIDRequestWithOptions:(id)arg1 { %log; %orig; }
- (void)startSpeechPronunciationRequestWithOptions:(id)arg1 pronunciationContext:(id)arg2 { %log; %orig; }
- (void)startSpeechRequestWithOptions:(id)arg1 { %log; %orig; }
- (void)startContinuationRequestWithUserInfo:(id)arg1 { %log; %orig; }
- (void)startDirectActionRequestWithString:(id)arg1 { %log; %orig; }
- (void)startRequestWithText:(id)arg1 { %log; %orig; }
- (void)setVoiceOverIsActive:(BOOL)arg1 { %log; %orig; }
- (void)setIsStark:(BOOL)arg1 { %log; %orig; }
- (void)setLockState:(BOOL)arg1 screenLocked:(BOOL)arg2 { %log; %orig; }
- (void)forceAudioSessionActive { %log; %orig; }
- (void)preheatWithStyle:(int)arg1 { %log; %orig; }
- (void)preheat { %log; %orig; }
- (void)endSession { %log; %orig; }
- (void)_willCompleteRequest { %log; %orig; }
- (void)_willFailRequestWithError:(id)arg1 { %log; %orig; }
- (void)_willCancelRequest { %log; %orig; }
- (void)_willStartRequestForSpeech:(BOOL)arg1 { %log; %orig; }
- (void)_updateClientState { %log; %orig; }
- (void)_updateState { %log; %orig; }
- (void)_extendExistingRequestTimeout { %log; %orig; }
- (void)_extendRequestTimeout { %log; %orig; }
- (void)_cancelRequestTimeout { %log; %orig; }
- (void)_invokeRequestTimeout { %log; %orig; }
- (void)_scheduleRequestTimeout { %log; %orig; }
- (id)_connection { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)_clearConnection { %log; %orig; }
- (void)_connectionInterrupted { %log; %orig; }
- (void)_tellSpeechDelegateRecognitionDidFail:(id)arg1 { %log; %orig; }
- (void)_tellSpeechDelegateSpeechRecognizedPartialResult:(id)arg1 { %log; %orig; }

- (void)_tellSpeechDelegateSpeechRecognized:(id)arg1 {
  %log;
  %orig;
}

- (void)_tellSpeechDelegateRecordingDidFail:(id)arg1 { %log; %orig; }
- (void)_tellSpeechDelegateRecordingDidCancel { %log; %orig; }
- (void)_tellSpeechDelegateRecordingDidEnd { %log; %orig; }
- (void)_tellSpeechDelegateRecordingDidChangeAVRecordRoute:(id)arg1 { %log; %orig; }
- (void)_tellSpeechDelegateRecordingDidBeginOnAVRecordRoute:(id)arg1 { %log; %orig; }
- (void)_tellSpeechDelegateRecordingWillBegin { %log; %orig; }
- (void)_tellDelegateDidFinishAcousticIDRequestWithSuccess:(BOOL)arg1 { %log; %orig; }
- (void)_tellDelegateDidDetectMusic { %log; %orig; }
- (void)_tellDelegateWillStartAcousticIDRequest { %log; %orig; }
- (void)_tellDelegateAudioSessionIDChanged:(unsigned int)arg1 { %log; %orig; }
- (void)_tellDelegateShouldSpeakChanged:(BOOL)arg1 { %log; %orig; }
- (void)_tellDelegateRequestFailed:(id)arg1 requestClass:(id)arg2 { %log; %orig; }
- (void)_tellDelegateRequestFinished { %log; %orig; }
- (void)_tellDelegateRequestWillStart { %log; %orig; }
- (void)_setAudioSessionID:(unsigned int)arg1 { %log; %orig; }
- (void)_setShouldSpeak:(BOOL)arg1 { %log; %orig; }
- (void)_requestDidEnd { %log; %orig; }
- (void)_checkAndSetIsCapturingSpeech:(BOOL)arg1 { %log; %orig; }
- (void)cancelRequest { %log; %orig; }
%end

%hook AFConnectionClientServiceDelegate
- (void)speechRecognitionDidFail:(id)arg1 {%orig;}

- (void)speechRecognized:(SASSpeechRecognized*)arg1 {
  NSMutableString *phraseBuilder = [NSMutableString string];
  for (AFSpeechPhrase *currPhrase in arg1.recognition.phrases) {
    if (currPhrase.interpretations.count > 0) {
      SASInterpretation *currInterpretation = currPhrase.interpretations[0];
      if (currInterpretation.tokens.count > 0) {
        AFSpeechToken *currToken = currInterpretation.tokens[0];
        [phraseBuilder appendString:[NSString stringWithFormat:@"%@ ", currToken.text]];
      }
    }
  }
  
  AFConnection *connection;
  object_getInstanceVariable(self, "_connection", (void **)&connection);
  currConnection = connection;
  
  defaultHandling = NO;
  
  AssistantAction action = [queryHandler handleQuery:phraseBuilder];
  switch (action) {
    case AssistantMusicPauseAction: {
      NSLog(@"Going to pause!");
      [musicController pauseSong];
      AssistantAceCommandBuilder *builder = [[AssistantAceCommandBuilder alloc] initWithConnection:connection];
      [builder sendTextSnippet:@"Pausing song!"];
      break;
    } case AssistantMusicPlayAction: {
        NSLog(@"Going to play!");
        [musicController playSong];
        break;
    } case AssistantChatAction: {
        AssistantAceCommandBuilder *builder = [[AssistantAceCommandBuilder alloc] initWithConnection:connection];
        [builder sendTextSnippet:@"yo dude!"];
        break;
    } case AssistantDefaultAction: {
        NSLog(@"Going to default!");
        defaultHandling = YES;
        break;
    } default: {
        defaultHandling = YES;
        break;
    }
  }
  
  if (!defaultHandling) {
    AssistantAceCommandBuilder *builder = [[AssistantAceCommandBuilder alloc] initWithConnection:connection];
    [builder sendRequestCompleted];
  }
}

- (void)requestDidFinish{ %log; %orig; }

- (void)requestDidReceiveCommand:(id)arg1 reply:(CDUnknownBlockType*)arg2 {
  %log;
  if (defaultHandling) {
    %orig;
  }
}

%end
