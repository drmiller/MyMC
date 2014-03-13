//
//  PodiumMessage.h
//  test-myMC
//
//  Created by Don Miller on 3/12/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PodiumMessage : NSObject

// used by receiver to read keys in switch {} 

- (NSUInteger)indexForKey:(NSString *)key;

// data packets with content

- (NSData *)messagePacket:(NSString *)message;
- (NSString *)messageFromPacket:(NSData *)data;

- (NSData *)elapsedSecondsPacket:(NSInteger)seconds;
- (NSInteger)elapsedSecondsFromPacket:(NSData *)data;

- (NSData *)startResumePacketWithElapsedSeconds:(NSInteger)seconds;
- (NSInteger)elapsedSecondsFromStartResumePacket:(NSData *)data;

- (NSData *)scrollPagePacketWithPage:(NSInteger)page;
- (NSInteger)scrollPageFromPacket:(NSData *)data;

- (NSData *)cycleViewsPacket:(BOOL)doCycle;
- (BOOL)doCycleFromCycleViewsPacket:(NSData *)data;

- (NSData *)updateSettingsPacket:(NSArray *)settings;
- (NSArray *)settingsFromUpdateSettingsPacket:(NSData *)data;

// action packet with no content

- (NSData *)doNothingPacket;
- (NSData *)resignActivePacket;
- (NSData *)disconnectStopBrowsingPacket;
- (NSData *)disconnectOnlyPacket;
- (NSData *)startResumePacket;
- (NSData *)pauseStopPacket;

@end
