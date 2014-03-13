//
//  ConnectivityManager.m
//  test-myMC
//
//  Created by Don Miller on 3/8/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import "ConnectivityManager.h"

#define kServiceType @"enatal-podium"

enum {
    MCNotConnected = 0,
    MCConnecting,
    MCConnected
} MCConnectionState;

enum {
    MCAdvertiser = 0,
    MCBrowser
} MCMode;


@interface ConnectivityManager() {
    
}

@property(nonatomic,strong) NSDictionary *discoveryInfo;

@property(nonatomic,strong)MCPeerID *nearbyPeer;

@end



@implementation ConnectivityManager

#pragma mark Setters/Getters

- (NSArray *)connectedPeerIDs {
    return self.session.connectedPeers;
}


- (BOOL)hasConnections {
    return ([self.session.connectedPeers count] > 0);
}

- (MCBrowserViewController *)browserVC {
    if (_browserVC == nil) {
        _browserVC = [[MCBrowserViewController alloc] initWithServiceType:kServiceType session:self.session];
        [_browserVC setDelegate:self];
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


#pragma mark Send Methods

- (BOOL)sendDataPacket:(NSData *)data {
    NSError *error;
    BOOL success = [self.session sendData:data toPeers:self.connectedPeerIDs withMode:MCSessionSendDataUnreliable error:&error];
    if (!success) {
        NSLog(@"Connectivity Manager - sendDataPacket Error: %@", error.description);
    }
    return success;
}


- (BOOL)sendMessageKey:(NSString *)theKey value:(id)value {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@{ theKey :  value}];
    return [self sendDataPacket:data];
}



#pragma mark MCBrowserViewControllerDelegate methods

// these are only for the master which is the only one that does the browsing

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [self.delegate browserViewController:browserViewController didConnect:YES];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self.delegate browserViewController:browserViewController didConnect:NO];
}

- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    
    // grab this to cancel while connecting
    self.nearbyPeer = peerID;
    
    return YES;
}





#pragma mark - nearbyAdvertiser Delegate method implementation

// this ONLY comes to devices that are advertising their services (in this case, in slave mode)
- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler {
    
    self.nearbyPeer = peerID;
    
    // the master browses for advertisers and
    // there could be more than one master browsing for advertisers
    // so, don't want to let the advertiser connect with more than one
    
    // this all happens automatically
    
    if ([self.connectedPeerNames count] == 0) {
        // accept the invitation
        invitationHandler(YES, self.session);
        
        self.isConnecting = YES;
        
        NSLog(@"Accepted Invitation");
        
        // and stop advertising
        [self advertiseSelf:NO];
        
    } else {
        // decline the invitation
        // and I think the master gets notified
        invitationHandler(NO, self.session);
        
        self.isConnecting = NO;
        
        NSLog(@"Declined Invitation");
    }
    
    [self.delegate advertiser:advertiser didAcceptInvitation:self.isConnecting];
}


//- (void)cancelConnectAttempt {
//    if (self.isConnecting) {
//        [self.session cancelConnectPeer:self.nearbyPeer];
//    }
//}


#pragma mark - MCSession Delegate method implementation

/******
Important: MCSession Delegate calls occur on a private operation queue. If your app needs to perform an action on a particular run loop or operation queue, its delegate method should explicitly dispatch or schedule that work.
******/

// delegate calls are ALL called on a PRIVATE queue
// and if the delegate updates the UI, it has to do it on the main queue

// both browsers and advertisers come here
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    BOOL didConnect = NO; // default as not connected
    
    NSString *peerDisplayName = peerID.displayName;
    
    switch ((NSInteger)state) {
            
        case MCSessionStateConnected:
        {
            NSLog(@"Session Connected");
            [self.connectedPeerNames addObject:peerDisplayName];
            didConnect = YES;
        }
            break;
            
            // not called or used
//        case MCSessionStateConnecting:
//            NSLog(@"Session Connecting");
//            break;
            
        case MCSessionStateNotConnected:
        {
            NSLog(@"Session Not Connected");
            if ([self.connectedPeerNames count]) {
                // should be the same object that was added originally????
                [self.connectedPeerNames removeObject:peerDisplayName];
            }
        }
            break;
    }

    

    
//    if (state == MCSessionStateConnecting) {
//        // connecting
//        self.isConnecting = YES;
//    } else
//
//    if (state == MCSessionStateConnected) {
//        
//        // multiple browsers trying to connect to an advertiser
//        // are already eliminated by the invitation
//        [self.connectedPeerNames addObject:peerDisplayName];
//        
//        didConnect = YES;
//        
////        if (self.isAdvertising) {
////            [self advertiseSelf:NO];
////        }
//        
//    } else if (state == MCSessionStateNotConnected) {
//        
//        // this means the connection did not occur
//        // was lost, or the device turned off or something
//        
//        if ([self.connectedPeerNames count]) {
//            
//            // should be the same object that was added originally????
//            [self.connectedPeerNames removeObject:peerDisplayName];
//            
//            
////            NSUInteger indexOfPeer = [self.connectedPeerNames indexOfObject:peerDisplayName];
////            [self.connectedPeerNames removeObjectAtIndex:indexOfPeer];
//        }
//    }
//    
//    self.isConnecting = NO;

    // could also use Notifications instead
    //[self.delegate connectedPeerNamesDidChange:self.connectedPeerNames hasConnections:self.hasConnections];
    
    
    // delegate calls are ALL called on a PRIVATE queue
    // and the delegate updates the UI, so it has to do it on the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate connectionStateDidConnect:didConnect withPeerID:peerID];
    });
    
    
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
    
    // **** this is called on a private queue !!!! ******
    
    NSDictionary *messageDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (messageDict && [messageDict count] == 1) {
        NSString *theKey = [[messageDict allKeys] lastObject];
        id theValue = [messageDict valueForKey:theKey];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didReceiveMessageWithKey:theKey value:theValue];
        });
        
        
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

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {}
-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {}
-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {}

@end
