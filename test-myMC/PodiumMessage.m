//
//  PodiumMessage.m
//  test-myMC
//
//  Created by Don Miller on 3/12/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//

#import "PodiumMessage.h"

// keys for dictionaries with one item

#define DISPLAY_MESSAGE_KEY @"DISPLAY_MESSAGE_KEY"
#define ELAPSED_SECONDS_KEY @"ELAPSED_SECONDS_KEY"
#define START_RESUME_KEY @"START_RESUME_KEY"
#define SCROLL_PAGE_KEY @"SCROLL_PAGE_KEY"
#define CYCLE_VIEWS_KEY @"CYCLE_VIEWS_KEY"
#define UPDATE_SETTINGS_KEY @"UPDATE_SETTINGS_KEY"

// strings for commands

#define DO_NOTHING_COMMAND @"DO_NOTHING_COMMAND"
#define RESIGN_ACTIVE_COMMAND @"RESIGN_ACTIVE_COMMAND"
#define DISCONNECT_STOP_BROWSING_COMMAND @"DISCONNECT_STOP_BROWSING_COMMAND"
#define DISCONNECT_ONLY_COMMAND @"DISCONNECT_ONLY_COMMAND"
#define START_RESUME_COMMAND @"START_RESUME_COMMAND"
#define PAUSE_STOP_COMMAND @"PAUSE_STOP_COMMAND"


@interface PodiumMessage()

@property(nonatomic,strong)NSArray *indexArray;

@end


@implementation PodiumMessage


- (id)init {
    self = [super init];
    if (self) {
        self.indexArray = @[
                        DISPLAY_MESSAGE_KEY,
                        ELAPSED_SECONDS_KEY,
                        START_RESUME_KEY,
                        SCROLL_PAGE_KEY,
                        CYCLE_VIEWS_KEY,
                        UPDATE_SETTINGS_KEY,
                        DO_NOTHING_COMMAND,
                        RESIGN_ACTIVE_COMMAND,
                        DISCONNECT_STOP_BROWSING_COMMAND,
                        DISCONNECT_ONLY_COMMAND,
                        PAUSE_STOP_COMMAND,
                        PAUSE_STOP_COMMAND
                        ];
    }
    return self;
}

- (NSUInteger)indexForKey:(NSString *)key {
    NSUInteger theIndex = [self.indexArray indexOfObject:key];
    
    return theIndex;
}

- (NSData *)messagePacket:(NSString *)message {
    return [NSKeyedArchiver archivedDataWithRootObject:@{ DISPLAY_MESSAGE_KEY : message }];
}
- (NSString *)messageFromPacket:(NSData *)data {
    return [[NSKeyedUnarchiver unarchiveObjectWithData:data] objectForKey:DISPLAY_MESSAGE_KEY];
}

- (NSData *)elapsedSecondsPacket:(NSInteger)seconds {
    return [NSKeyedArchiver archivedDataWithRootObject:@{ ELAPSED_SECONDS_KEY : @(seconds) }];
}
- (NSInteger)elapsedSecondsFromPacket:(NSData *)data {
    return [[[NSKeyedUnarchiver unarchiveObjectWithData:data] objectForKey:ELAPSED_SECONDS_KEY] integerValue];
}

- (NSData *)startResumePacketWithElapsedSeconds:(NSInteger)seconds {
    return [NSKeyedArchiver archivedDataWithRootObject:@{ START_RESUME_KEY : @(seconds + 1) }]; // elapsed seconds + 1
}
- (NSInteger)elapsedSecondsFromStartResumePacket:(NSData *)data {
    return [[[NSKeyedUnarchiver unarchiveObjectWithData:data] objectForKey:START_RESUME_KEY] integerValue] - 1;
}

- (NSData *)scrollPagePacketWithPage:(NSInteger)page {
    return [NSKeyedArchiver archivedDataWithRootObject:@{ SCROLL_PAGE_KEY : @(page + 1) }]; // current page + 1
}
- (NSInteger)scrollPageFromPacket:(NSData *)data {
    return [[[NSKeyedUnarchiver unarchiveObjectWithData:data] objectForKey:SCROLL_PAGE_KEY] integerValue] - 1;
}

- (NSData *)cycleViewsPacket:(BOOL)doCycle {
    return [NSKeyedArchiver archivedDataWithRootObject:@{ CYCLE_VIEWS_KEY : @(doCycle) }];
}
- (BOOL)doCycleFromCycleViewsPacket:(NSData *)data {
    return [[[NSKeyedUnarchiver unarchiveObjectWithData:data] objectForKey:CYCLE_VIEWS_KEY] boolValue];
}

- (NSData *)updateSettingsPacket:(NSArray *)settings {
    return [NSKeyedArchiver archivedDataWithRootObject:@{ UPDATE_SETTINGS_KEY : settings }];
}
- (NSArray *)settingsFromUpdateSettingsPacket:(NSData *)data {
    return [[NSKeyedUnarchiver unarchiveObjectWithData:data] objectForKey:UPDATE_SETTINGS_KEY];
}


// just need the keys, don't care about the value

- (NSData *)doNothingPacket {
    return [NSKeyedArchiver archivedDataWithRootObject:@{ DO_NOTHING_COMMAND : @(1) }];
}
- (NSData *)resignActivePacket {
    return [NSKeyedArchiver archivedDataWithRootObject:@{ RESIGN_ACTIVE_COMMAND : @(1) }];
}
- (NSData *)disconnectStopBrowsingPacket {
    return [NSKeyedArchiver archivedDataWithRootObject:@{ DISCONNECT_STOP_BROWSING_COMMAND : @(1) }];
}
- (NSData *)disconnectOnlyPacket {
    return [NSKeyedArchiver archivedDataWithRootObject:@{ DISCONNECT_ONLY_COMMAND : @(1) }];
}
- (NSData *)startResumePacket {
    return [NSKeyedArchiver archivedDataWithRootObject:@{ START_RESUME_COMMAND : @(1) }];
}
- (NSData *)pauseStopPacket {
    return [NSKeyedArchiver archivedDataWithRootObject:@{ PAUSE_STOP_COMMAND : @(1) }];
}


@end















