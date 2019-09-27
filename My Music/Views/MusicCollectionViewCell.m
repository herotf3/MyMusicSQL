//
//  MusicCollectionViewCell.m
//  My Music
//
//  Created by CPU11808 on 9/27/19.
//  Copyright © 2019 CPU11808. All rights reserved.
//

#import "MusicCollectionViewCell.h"
#import "MusicInfo.h"

@interface MusicCollectionViewCell()

//MARK: Outlets
@property (weak, nonatomic) IBOutlet UILabel *lbSongName;
@property (weak, nonatomic) IBOutlet UILabel *lbGenre;
@property (weak, nonatomic) IBOutlet UILabel *lbAuthor;

@property (strong, nonatomic) MusicInfo* musicInfo;

@end

@implementation MusicCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)bindDataWith:(MusicInfo*)info {
    self.musicInfo = info;
    _lbSongName.text = info.songName;
    _lbAuthor.text = info.author;
    _lbGenre.text = info.genre;
}

//MARK: Actions
- (IBAction)onEditAction:(id)sender {
    if (self.delegate){
        [self.delegate didPressEdit:_musicInfo];
    }
}

- (IBAction)onDeleteAction:(id)sender {
    if (self.delegate){
        [self.delegate didPressDelete:_musicInfo];
    }
}

@end
