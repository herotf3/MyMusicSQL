//
//  ViewController.m
//  My Music
//
//  Created by CPU11808 on 9/25/19.
//  Copyright © 2019 CPU11808. All rights reserved.
//

#import "MyMusicViewController.h"
#import "MusicCell.h"
#import "EditMusicViewController.h"
#import "DBManager.h"
#import "MusicInfo.h"

#define MUSIC_TABLE_ROW_HEIGHT 120

#define EDIT_MUSIC_SEGUE @"editMusicSegue"

@interface MyMusicViewController () <UITableViewDelegate, UITableViewDataSource>{
    NSArray* sortMethods;
}

//MARK: Outlets
@property (nonatomic, weak) IBOutlet UITableView* musicTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnAZ;
@property (weak, nonatomic) IBOutlet UIButton *btnNewest;
@property (weak, nonatomic) IBOutlet UIButton *btnOldest;

@property (nonatomic, strong) DBManager *dbManager;
@property (nonatomic, strong) NSMutableArray *arrMusics;
@property(nonatomic, strong) MusicInfo* musicForEdit;

-(void) loadData;
@end

@implementation MyMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Short tool
    [_btnAZ setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_btnNewest setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_btnOldest setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    
    [_musicTableView registerNib:[UINib nibWithNibName:MUSIC_CELL_XIB bundle:nil] forCellReuseIdentifier:MUSIC_TABLE_CELL_REUSE_ID];
    _musicTableView.delegate = self;
    _musicTableView.dataSource = self;
    _musicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.dbManager = [[DBManager alloc] initWithDBFileName:MUSIC_DATABASE_FILENAME];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}

//MARK: TableView data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrMusics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:MUSIC_TABLE_CELL_REUSE_ID forIndexPath:indexPath];

    [cell bindDataWith:self.arrMusics[(NSUInteger) indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return MUSIC_TABLE_ROW_HEIGHT;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIContextualAction* deleteAction, *editAction;
    deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Xoá" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {
        
        NSLog(@"Deleting row: %ld",indexPath.row);
        [self deleteMusicAtIndex:indexPath.row];
        completionHandler(YES);
    }];

    editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Chỉnh sửa" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL)) {

        NSLog(@"Editing row: %ld",indexPath.row);
        [self editMusicAtIndex:indexPath.row];
        completionHandler(YES);
    }];

    return [UISwipeActionsConfiguration configurationWithActions:@[editAction,deleteAction]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}


//MARK: TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

//MARK: Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"addMusicSegue"]){
        EditMusicViewController* editVC = (EditMusicViewController *) segue.destinationViewController;
        [editVC setControllerMode:ModeAdding];
    }else if ([segue.identifier isEqualToString:@"editMusicSegue"]){
        EditMusicViewController* editVC = (EditMusicViewController *) segue.destinationViewController;
        editVC.musicForEdit = self.musicForEdit;
        [editVC setControllerMode:ModeEditing];
    }
}


//Private functions
-(void)loadData {
    NSLog(@"Loading data...");
    NSString *query = @"select * from Music";
    // Get the results.
    NSArray * rows = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    // parse results into array of MusicInfo models
    NSUInteger indexOfSongName = [_dbManager.arrColumnNames indexOfObject:MUSIC_COLUMN_SONG_NAME];
    NSUInteger indexOfAuthor =  [_dbManager.arrColumnNames indexOfObject:MUSIC_COLUMN_AUTHOR];
    NSUInteger indexOfGenre = [_dbManager.arrColumnNames indexOfObject:MUSIC_COLUMN_GENRE];

    self.arrMusics = [NSMutableArray new];
    for (NSUInteger i = 0; i < rows.count; i++){
        MusicInfo * musicInfo = [MusicInfo infoWithSongName:rows[i][indexOfSongName]
                author:rows[i][indexOfAuthor] genre:rows[i][indexOfGenre]];

        [musicInfo setMusicId:[rows[i][0] intValue]];
        [self.arrMusics addObject:musicInfo];
    }

    [self.musicTableView reloadData];
}

- (void)editMusicAtIndex:(NSInteger)row {
    // change to editing screen
    self.musicForEdit = self.arrMusics[(NSUInteger) row];
    [self performSegueWithIdentifier:EDIT_MUSIC_SEGUE sender:nil];
}

- (void)deleteMusicAtIndex:(NSInteger)index {
    MusicInfo * music = self.arrMusics[(NSUInteger) index];
    NSString * query = [NSString stringWithFormat:@"delete from Music where musicId = %d", music.musicId];

    [_dbManager executeQuery:query];
    [self loadData];
}

//MARK: Actions
- (IBAction)actionSortAZ:(id)sender {
    [self.arrMusics sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MusicInfo * m1 = obj1;
        MusicInfo * m2 = obj2;
        return [m1.songName compare:m2.songName];
    }];
    [_btnAZ setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [_btnNewest setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_btnOldest setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    [self.musicTableView reloadData];
}

- (IBAction)actionSortNewest:(id)sender {
    [self.arrMusics sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MusicInfo * m1 = obj1;
        MusicInfo * m2 = obj2;
        return m1.musicId < m2.musicId;
    }];
    
    [_btnAZ setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_btnNewest setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [_btnOldest setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    
    [self.musicTableView reloadData];
}

- (IBAction)actionSortOldest:(id)sender {
    [self.arrMusics sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MusicInfo * m1 = obj1;
        MusicInfo * m2 = obj2;
        return m1.musicId > m2.musicId;
    }];
    
    [_btnAZ setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_btnNewest setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [_btnOldest setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    
    [self.musicTableView reloadData];
}

-(void) setSelectedButton:(UIButton*) btn{
    
}

@end
