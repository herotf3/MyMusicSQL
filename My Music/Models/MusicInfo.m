//
// Created by CPU11808 on 9/26/19.
// Copyright (c) 2019 CPU11808. All rights reserved.
//

#import "MusicInfo.h"


@implementation MusicInfo
- (instancetype)initWithSongName:(NSString *)name author:(NSString *)aAuthor genre:(NSString *)aGenre {
    self = [super init];
    if (self) {
        self.songName = name;
        self.author = aAuthor;
        self.genre = aGenre;
    }

    return self;
}

+ (instancetype)infoWithSongName:(NSString *)name author:(NSString *)author genre:(NSString *)genre {
    return [[self alloc] initWithSongName:name author:author genre:genre];
}



@end