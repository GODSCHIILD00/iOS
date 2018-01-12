
#import "MEGAProviderDelegate.h"
#import "CallViewController.h"
#import "UIApplication+MNZCategory.h"

@interface MEGAProviderDelegate ()

@property (nonatomic, copy) MEGACallManager *megaCallManager;
@property (nonatomic, strong) CXProvider *provider;

@end

@implementation MEGAProviderDelegate

- (instancetype)initWithMEGACallManager:(MEGACallManager *)megaCallManager {
    self = [super init];
    
    if (self) {
        _megaCallManager = megaCallManager;
        
        CXProviderConfiguration *configuration = [[CXProviderConfiguration alloc] initWithLocalizedName:@"MEGA"];
        configuration.supportsVideo = YES;
        configuration.maximumCallsPerCallGroup = 1;
        configuration.maximumCallGroups = 1;
        configuration.supportedHandleTypes = [NSSet setWithObject:@(CXHandleTypeEmailAddress)];
        configuration.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"MEGA_icon_call"]);
        _provider = [[CXProvider alloc] initWithConfiguration:configuration];
        
        [_provider setDelegate:self queue:nil];
    }
    
    return self;
}

- (void)reportIncomingCall:(MEGAChatCall *)call hasVideo:(BOOL)hasVideo email:(NSString*)email {
    MEGALogDebug(@"[CallKit] Report incoming call %@ with uuid %@, video %@ and email %@", call, call.uuid, hasVideo ? @"YES" : @"NO", email);
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeEmailAddress value:email];
    update.supportsHolding = NO;
    update.supportsGrouping = NO;
    update.supportsUngrouping = NO;
    update.supportsDTMF = NO;
    update.hasVideo = hasVideo;
    [self.provider reportNewIncomingCallWithUUID:call.uuid update:update completion:^(NSError * _Nullable error) {
        if (error) {
            MEGALogError(@"error");
        } else {
            [self.megaCallManager addCall:call];
        }
    }];
}

- (void)reportOutgoingCall:(MEGAChatCall *)call {
    NSUUID *uuid = [self.megaCallManager UUIDForCall:call];
    MEGALogDebug(@"[CallKit] Report outgoing call %@ with uuid %@", call, uuid);
    [self.provider reportOutgoingCallWithUUID:uuid connectedAtDate:nil];
}

#pragma mark - CXProviderDelegate

- (void)providerDidReset:(CXProvider *)provider {
    MEGALogDebug(@"[CallKit] Provider did reset");
    [self.megaCallManager removeAllCalls];
}

- (void)providerDidBegin:(CXProvider *)provider {
    MEGALogDebug(@"[CallKit] Provider did begin");
}

- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
    MEGAChatCall *call = [self.megaCallManager callForUUID:action.callUUID];
    
    MEGALogDebug(@"[CallKit] Provider perform start call: %@, uuid: %@", call, action.callUUID);
    
    if (call) {
        [provider reportOutgoingCallWithUUID:action.callUUID startedConnectingAtDate:nil];
        [action fulfill];
    } else {
        [action fail];
    }
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    MEGAChatCall *call = [self.megaCallManager callForUUID:action.callUUID];
    
    MEGALogDebug(@"[CallKit] Provider perform answer call: %@, uuid: %@", call, action.callUUID);
    
    if (call) {
        CallViewController *callVC = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"CallViewControllerID"];
        callVC.chatRoom  = [[MEGASdkManager sharedMEGAChatSdk] chatRoomForChatId:call.chatId];
        callVC.videoCall = call.hasRemoteVideo;
        callVC.callType = CallTypeIncoming;
        callVC.megaCallManager = self.megaCallManager;
        callVC.call = call;
        
        if ([[UIApplication mnz_visibleViewController] isKindOfClass:CallViewController.class]) {
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:callVC animated:YES completion:nil];
        } else {
            [[UIApplication mnz_visibleViewController] presentViewController:callVC animated:YES completion:nil];
        }
        [action fulfill];
    } else {
        [action fail];
    }
}


- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    MEGAChatCall *call = [self.megaCallManager callForUUID:action.callUUID];
    
    MEGALogDebug(@"[CallKit] Provider perform end call: %@, uuid: %@", call, action.callUUID);
    
    if (call) {
        [action fulfill];
        [self.megaCallManager removeCallByUUID:action.callUUID];
        if ([[UIApplication mnz_visibleViewController] isKindOfClass:CallViewController.class]) {
            [[UIApplication mnz_visibleViewController] dismissViewControllerAnimated:NO completion:nil];
        }
        [[MEGASdkManager sharedMEGAChatSdk] hangChatCall:call.chatId];
    } else {
        [action fail];
    }
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    MEGAChatCall *call = [self.megaCallManager callForUUID:action.callUUID];
    
    MEGALogDebug(@"[CallKit] Provider perform mute call: %@, uuid: %@", call, action.callUUID);
    
    if (call) {
        if (call.hasLocalAudio) {
            [[MEGASdkManager sharedMEGAChatSdk] disableAudioForChat:call.chatId];
        } else {
            [[MEGASdkManager sharedMEGAChatSdk] enableAudioForChat:call.chatId];
        }
        [action fulfill];
    } else {
        [action fail];
    }
}

- (void)provider:(CXProvider *)provider timedOutPerformingAction:(CXAction *)action {
    MEGALogDebug(@"[CallKit] Provider time out performing action");
}

- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
    MEGALogDebug(@"[CallKit] Provider did activate audio session");
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    MEGALogDebug(@"[CallKit] Provider did deactivate audio session");
}

@end
