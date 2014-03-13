//
//  PodiumMessage.h
//  test-myMC
//
//  Created by Don Miller on 3/12/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
THIS USED TO BE AN ACTION ARRAY???
Commands - The key @“DO_COMMAND_KEY” says it’s a command and the value is an integer specifying the command.

DO_NOTHING_VALUE ?
RESIGN_ACTIVE_VALUE
DISCONNECT_STOP_BROWSING_VALUE
DISCONNECT_ONLY_VALUE

START_RESUME_VALUE
PAUSE_STOP_VALUE


Messages with content (not just an integer)

DISPLAY_MESSAGE_KEY (the message string)
UPDATE_ELAPSED_SECONDS_KEY (elapsed seconds)
UPDATE_SETTINGS_KEY (the settings array)

START_RESUME (with elapsed seconds + 1)

SCROLL_PAGE_KEY (current page + 1)

CYCLE_VIEWS_KEY ( BOOL for doCycleViews)
*/


@interface PodiumMessage : NSObject

@property(nonatomic,strong)NSArray *indexArray;

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
@end
