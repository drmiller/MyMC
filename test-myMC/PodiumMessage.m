//
//  PodiumMessage.m
//  test-myMC
//
//  Created by Don Miller on 3/12/14.
//  Copyright (c) 2014 eNATAL, LLC. All rights reserved.
//



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

#define DISPLAY_MESSAGE_KEY @"DISPLAY_MESSAGE_KEY"
#define ELAPSED_SECONDS_KEY @"ELAPSED_SECONDS_KEY"
#define START_RESUME_KEY @"START_RESUME_KEY"
#define SCROLL_PAGE_KEY @"SCROLL_PAGE_KEY"
#define CYCLE_VIEWS_KEY @"CYCLE_VIEWS_KEY"
#define UPDATE_SETTINGS_KEY @"UPDATE_SETTINGS_KEY"

#import "PodiumMessage.h"


@interface PodiumMessage()



@end



@implementation PodiumMessage



- (id)init {
    self = [super init];
    if (self) {
        self.indexArray = @[
                        DISPLAY_MESSAGE_KEY,
                        DISPLAY_MESSAGE_KEY
                        ];
    }
    return self;
}

- (NSUInteger)indexForKey:(NSString *)key {
    NSUInteger theIndex = [self.indexArray indexOfObject:key];
    
    return theIndex;
}


//- (NSData *)archiveDictionary:(NSDictionary *)dict {
//    return [NSKeyedArchiver archivedDataWithRootObject:dict];
//}


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

@end















