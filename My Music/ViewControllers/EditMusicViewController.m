//
// Created by CPU11808 on 9/26/19.
// Copyright (c) 2019 CPU11808. All rights reserved.
//

#import "EditMusicViewController.h"
#import "DBManager.h"
#import "MusicInfo.h"

@interface EditMusicViewController(){
}
//MARK: Outlets
@property (weak, nonatomic) IBOutlet UIButton* btnSubmit;
@property (weak, nonatomic) IBOutlet UITextField *tfSongName;
@property (weak, nonatomic) IBOutlet UITextField *tfAuthor;
@property (weak, nonatomic) IBOutlet UITextField *tfGenre;

@property (nonatomic) enum EditMusicMode mode;
@property (nonatomic,strong) DBManager* dbManager;

@end


@implementation EditMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString*title = @"";
    switch (self.mode){
        case ModeEditing:
            title = @"Chỉnh sửa";
            [self showCurrentMusicInfo];
            break;
        case ModeAdding:
            title = @"Thêm bài hát";
            break;
    }
    [self.navigationItem setTitle:title];

    [_tfSongName becomeFirstResponder];
//    _tfSongName.delegate = self;
//    _tfAuthor.delegate = self;
//    _tfGenre.delegate = self;
    
    //init database
    self.dbManager = [[DBManager alloc] initWithDBFileName:MUSIC_DATABASE_FILENAME];
}

- (void)showCurrentMusicInfo {
    if (self.musicForEdit){
        _tfSongName.text = _musicForEdit.songName;
        _tfAuthor.text = _musicForEdit.author;
        _tfGenre.text = _musicForEdit.genre;
    }
}


- (void)setControllerMode:(enum EditMusicMode)mode {
    self.mode = mode;
}

- (BOOL)validateInput {
    if ([_tfAuthor.text isEqualToString:@""] || [_tfSongName.text isEqualToString:@""] || [_tfGenre.text isEqualToString:@""])
    {
        //show warning
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"Vui lòng điền đầy đủ thông tin." preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:alertVC animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)editMusic {
    // Prepare the query string.
    NSString *query = [NSString stringWithFormat:@"update Music set %@='%@', %@='%@', %@='%@' where %@=%d",
            MUSIC_COLUMN_SONG_NAME , self.tfSongName.text,
            MUSIC_COLUMN_AUTHOR, self.tfAuthor.text,
            MUSIC_COLUMN_GENRE, self.tfGenre.text,
            MUSIC_COLUMN_ID,_musicForEdit.musicId];

    [self.dbManager executeQuery:query];
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
        // Need to add delegate to callback for update?
        // Go back
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSLog(@"Could not execute the query.");
    }
}

- (void)addMusic {
    // Prepare the query string.
    NSString *query = [NSString stringWithFormat:@"insert into Music values(null, '%@', '%@', '%@')", self.tfSongName.text, self.tfAuthor.text, self.tfGenre.text];
 
    [self.dbManager executeQuery:query];
    if (self.dbManager.affectedRows != 0) {
        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
 
        // Go back
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSLog(@"Could not execute the query.");
    }
}

//MARK: Actions

- (IBAction)onActionSubmit:(id)sender {
    if (![self validateInput])
        return;
    
    switch (self.mode) {
        case ModeAdding:
            [self addMusic];
            break;
        case ModeEditing:
            [self editMusic];
            break;
    }
}

//MARK: TextField delegate
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [textField resignFirstResponder];
//    return YES;
//}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    NSLog(@"----");
//    return YES;
//}

@end
