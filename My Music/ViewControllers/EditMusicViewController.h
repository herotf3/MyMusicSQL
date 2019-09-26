//
// Created by CPU11808 on 9/26/19.
// Copyright (c) 2019 CPU11808. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MusicInfo;

enum EditMusicMode {
    ModeAdding,
    ModeEditing
};

@interface EditMusicViewController : UIViewController

@property(nonatomic, strong) MusicInfo* musicForEdit;

-(void)setControllerMode:(enum EditMusicMode) mode;

@end
