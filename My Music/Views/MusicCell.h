//
//  MusicCell.h
//  My Music
//
//  Created by CPU11808 on 9/26/19.
//  Copyright © 2019 CPU11808. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MusicInfo;
#define MUSIC_CELL_XIB @"MusicCell"

NS_ASSUME_NONNULL_BEGIN

@interface MusicCell : UITableViewCell

- (void)bindDataWith:(MusicInfo*)info;
@end

NS_ASSUME_NONNULL_END
