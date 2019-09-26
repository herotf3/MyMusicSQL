//
// Created by CPU11808 on 9/26/19.
// Copyright (c) 2019 CPU11808. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"

#define MUSIC_COLUMN_ID @"musicId"
#define MUSIC_COLUMN_SONG_NAME @"songName"
#define MUSIC_COLUMN_AUTHOR @"author"
#define MUSIC_COLUMN_GENRE @"genre"

@interface MusicInfo : NSObject
@property (assign) int musicId;
@property (nonatomic, copy) NSString *songName;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *genre;
@property (nonatomic, strong) NSDate* dateCreated;

- (instancetype)initWithSongName:(NSString *)name author:(NSString *)aAuthor genre:(NSString *)aGenre;
+ (instancetype)infoWithSongName:(NSString *)name author:(NSString *)author genre:(NSString *)genre;

@end
