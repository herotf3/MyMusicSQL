//
//  MusicCell.m
//  My Music
//
//  Created by CPU11808 on 9/26/19.
//  Copyright © 2019 CPU11808. All rights reserved.
//

#import "MusicCell.h"
#import "MusicInfo.h"

@interface MusicCell()

//MARK: Outlets
@property (weak, nonatomic) IBOutlet UILabel *lbSongName;
@property (weak, nonatomic) IBOutlet UILabel *lbAuthor;
@property (weak, nonatomic) IBOutlet UILabel *lbGenre;


@end

@implementation MusicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bindDataWith:(MusicInfo*)info {
    _lbSongName.text = info.songName;
    _lbAuthor.text = info.author;
    _lbGenre.text = info.genre;
}

@end
