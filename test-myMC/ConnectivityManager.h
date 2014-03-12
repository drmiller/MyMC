//
//  ConnectivityManager.h
//  test-myMC
//
//  Created by Don Miller on 3/8/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol ConnectivityManagerDelegate <NSObject>

- (void)connectionStateDidConnect:(BOOL)didConnect withPeerID:(MCPeerID *)peerID;

- (void)didReceiveMessageWithKey:(NSString *)key value:(id)value;

- (void)peerDidDisconnect:(MCPeerID *)peer;

- (void)browserViewController:(MCBrowserViewController *)browser didConnect:(BOOL)didConnect;

@end


@interface ConnectivityManager : NSObject<MCSessionDelegate,MCNearbyServiceAdvertiserDelegate,MCBrowserViewControllerDelegate>

@property(nonatomic,weak) id<ConnectivityManagerDelegate> delegate;

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browserVC;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *nearbyAdvertiser;

@property(nonatomic,strong)NSMutableArray *connectedPeerNames;
@property(nonatomic,strong,readonly)NSArray *connectedPeerIDs;

@property(nonatomic,assign)BOOL hasConnections;

@property(nonatomic,assign)BOOL isAdvertising;

@property (nonatomic,assign)BOOL isConnecting;

- (void)disconnectAllPeers;

- (void)disconnectFromSession;

- (void)advertiseSelf:(BOOL)shouldAdvertise;

//- (void)cancelConnectAttempt;

//- (void)sendMessage:(NSDictionary *)message;

- (void)sendMessageKey:(NSString *)theKey value:(id)value;

@end
