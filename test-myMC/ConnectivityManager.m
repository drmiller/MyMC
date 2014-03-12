//
//  ConnectivityManager.m
//  test-myMC
//
//  Created by Don Miller on 3/8/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import "ConnectivityManager.h"

#define kServiceType @"enatal-podium"


@interface ConnectivityManager() {
    
}

@property(nonatomic,strong) NSDictionary *discoveryInfo;

@end



@implementation ConnectivityManager

#pragma mark Setters/Getters

- (NSArray *)connectedPeers {
    return self.session.connectedPeers;
}


- (BOOL)hasConnections {
    return ([self.session.connectedPeers count] > 0);
}

- (MCBrowserViewController *)browserVC {
    if (_browserVC == nil) {
        _browserVC = [[MCBrowserViewController alloc] initWithServiceType:kServiceType session:self.session];
    }
    return _browserVC;
}

- (MCPeerID *)peerID {
    if (_peerID == nil) {
        _peerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    }
    return _peerID;
}

- (MCSession *)session {
    if (_session == nil) {
        _session = [[MCSession alloc] initWithPeer:self.peerID];
        _session.delegate = self;
    }
    return _session;
}


#pragma mark Init

- (id)init {
    self = [super init];
    if (self) {
        self.discoveryInfo = @{ @"isMaster" : @"YES" };
        self.connectedPeerNames = [@[] mutableCopy];
    }
    return self;
}


-(void)advertiseSelf:(BOOL)shouldAdvertise{
//    if (shouldAdvertise) {
//        self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:kServiceType
//                                                           discoveryInfo:self.discoveryInfo
//                                                                 session:self.session];
//        [self.advertiser start];
//    }
//    else{
//        [self.advertiser stop];
//        self.advertiser = nil;
//    }
    
    //self.isAdvertising = shouldAdvertise;
    
    if (shouldAdvertise) {
        self.nearbyAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:self.discoveryInfo serviceType:kServiceType];
        [self.nearbyAdvertiser setDelegate:self];
                                 
        [self.nearbyAdvertiser startAdvertisingPeer];
        
    } else {
        [self.nearbyAdvertiser stopAdvertisingPeer];
        self.nearbyAdvertiser = nil;
    }
}


- (void)disconnectFromSession {
    [self.session disconnect];
}


- (void)disconnectAllPeers {
    [self.connectedPeerNames removeAllObjects];
    [self.session disconnect];
    
//    for (MCPeerID *peer in self.session.connectedPeers) {
//        [self.delegate peerDidDisconnect:peer];
//    }
}


- (void)sendMessageKey:(NSString *)theKey value:(id)value {
    NSError *error;
    NSData *theMessage = [NSKeyedArchiver archivedDataWithRootObject:@{ theKey :  value}];
    [self.session sendData:theMessage toPeers:self.connectedPeers withMode:MCSessionSendDataUnreliable error:&error];
}




#pragma mark - nearbyAdvertiser Delegate method implementation

// this ONLY comes to devices that are advertising their services (in this case, in slave mode)
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler {
    
    // the master browses for advertisers and
    // there could be more than one master browsing for advertisers
    // so, don't want to let the advertiser connect with more than one
    
    // this all happens automatically
    
    if ([self.connectedPeerNames count] == 0) {
        // accept the invitation
        invitationHandler(YES, self.session);
        
        // and stop advertising
        [self advertiseSelf:NO];
        
    } else {
        // decline the invitation
        // and I think the master gets notified
        invitationHandler(NO, self.session);
    }
}


#pragma mark - MCSession Delegate method implementation

/******
Important: Delegate calls occur on a private operation queue. If your app needs to perform an action on a particular run loop or operation queue, its delegate method should explicitly dispatch or schedule that work.
******/

// delegate calls are ALL called on a PRIVATE queue
// and if the delegate updates the UI, it has to do it on the main queue

// both browsers and advertisers come here
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    BOOL didConnect = NO;
    
    NSString *peerDisplayName = peerID.displayName;

    if (state == MCSessionStateConnected) {
        
        // multiple browsers trying to connect to an advertiser
        // are already eliminated by the invitation
        [self.connectedPeerNames addObject:peerDisplayName];
        
        didConnect = YES;
        
//        if (self.isAdvertising) {
//            [self advertiseSelf:NO];
//        }
        
    } else if (state == MCSessionStateNotConnected) {
        
        // this means the connection did not occur
        // was lost, or the device turned off or something
        
        if ([self.connectedPeerNames count]) {
            
            // should be the same object that was added originally????
            [self.connectedPeerNames removeObject:peerDisplayName];
            
            
//            NSUInteger indexOfPeer = [self.connectedPeerNames indexOfObject:peerDisplayName];
//            [self.connectedPeerNames removeObjectAtIndex:indexOfPeer];
        }
    }
    
    // could also use Notifications instead
    //[self.delegate connectedPeerNamesDidChange:self.connectedPeerNames hasConnections:self.hasConnections];
    
    
    // delegate calls are ALL called on a PRIVATE queue
    // and the delegate updates the UI, so it has to do it on the main queue
    //dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate connectionStateDidConnect:didConnect withPeerID:peerID];
    //});
    
    
    
    
    // in case I decide to do notifications instead
//    NSDictionary *dict = @{
//                            @"ConnectedPeerNamesKey" : self.connectedPeerNames,
//                            @"HasConnectionsKey" : [NSNumber numberWithBool: self.hasConnections],
//                               @"PeerIDKey" : peerID
//                               };
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidChangeStateNotification"
//                                                        object:nil
//                                                      userInfo:dict];
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
    NSDictionary *messageDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (messageDict && [messageDict count] == 1) {
        NSString *theKey = [[messageDict allKeys] lastObject];
        id theValue = [messageDict valueForKey:theKey];
        
        [self.delegate didReceiveMessageWithKey:theKey value:theValue];
        
        // in case I decide to do notifications instead
//        NSDictionary *dict = @{
//                               @"Key" : theKey,
//                               @"Value" : theValue,
//                               @"PeerIDKey" : peerID
//                               };
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"MCDidReceiveDataNotification"
//                                                            object:nil
//                                                          userInfo:dict];

    }
}


// required delegate methods that are not used here

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
}

@end
