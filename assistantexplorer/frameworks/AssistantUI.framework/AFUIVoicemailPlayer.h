/* Generated by RuntimeBrowser
   Image: /System/Library/PrivateFrameworks/AssistantUI.framework/AssistantUI
 */

@class <AFUIVoicemailPlayerDelegate>, AVAudioPlayer, NSString, SAPhonePlayVoiceMail, VMVoicemail;

@interface AFUIVoicemailPlayer : NSObject <AVAudioPlayerDelegate> {
    <AFUIVoicemailPlayerDelegate> *_delegate;
    AVAudioPlayer *_player;
    SAPhonePlayVoiceMail *_voicemail;
    VMVoicemail *_voicemailObject;
}

@property(copy,readonly) NSString * debugDescription;
@property <AFUIVoicemailPlayerDelegate> * delegate;
@property(copy,readonly) NSString * description;
@property(readonly) unsigned long long hash;
@property(getter=_player,setter=_setPlayer:,retain) AVAudioPlayer * player;
@property(readonly) Class superclass;
@property(retain) SAPhonePlayVoiceMail * voicemail;
@property(getter=_voicemailObject,setter=_setVoicemailObject:,retain) VMVoicemail * voicemailObject;

- (void).cxx_destruct;
- (id)_player;
- (void)_setPlayer:(id)arg1;
- (void)_setVoicemailObject:(id)arg1;
- (void)_updateVoicemailPlayedState:(id)arg1 finished:(bool)arg2;
- (long long)_voicemailID;
- (id)_voicemailObject;
- (id)_voicemailURL;
- (void)audioPlayerDidFinishPlaying:(id)arg1 successfully:(bool)arg2;
- (id)delegate;
- (void)setDelegate:(id)arg1;
- (void)setVoicemail:(id)arg1;
- (void)startPlaying;
- (void)stopPlaying;
- (id)voicemail;

@end
