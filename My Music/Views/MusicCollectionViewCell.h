//
//  MusicCollectionViewCell.h
//  My Music
//
//  Created by CPU11808 on 9/27/19.
//  Copyright © 2019 CPU11808. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicInfo.h"

@protocol MusicCollectionDelegate <NSObject>

-(void) didPressDelete:(MusicInfo*) musicInfo;
-(void) didPressEdit:(MusicInfo*) musicInfo;

@end

@class MusicInfo;

#define MUSIC_COLLECTION_CELL_XIB @"MusicCollectionViewCell"
NS_ASSUME_NONNULL_BEGIN

@interface MusicCollectionViewCell : UICollectionViewCell


@property (nonatomic, weak, nullable) id<MusicCollectionDelegate> delegate;

- (void)bindDataWith:(MusicInfo *)info;
@end

NS_ASSUME_NONNULL_END
