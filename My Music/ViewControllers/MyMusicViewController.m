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
#import "MusicCollectionViewCell.h"

#define MUSIC_TABLE_ROW_HEIGHT 120

#define EDIT_MUSIC_SEGUE @"editMusicSegue"

#define MUSIC_COLLECTION_CELL_ID @"CollectionCellID"

@interface MyMusicViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MusicCollectionDelegate>{
    NSArray* sortMethods;
}

//MARK: Outlets
@property (nonatomic, weak) IBOutlet UITableView* musicTableView;
@property (nonatomic, weak) IBOutlet UICollectionView * musicCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;


@property (weak, nonatomic) IBOutlet UIButton *btnAZ;
@property (weak, nonatomic) IBOutlet UIButton *btnNewest;
@property (weak, nonatomic) IBOutlet UIButton *btnOldest;
@property (weak, nonatomic) IBOutlet UIButton *btnChangeLayout;

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

    self.isInGirdMode = YES;
    [_musicTableView registerNib:[UINib nibWithNibName:MUSIC_CELL_XIB bundle:nil] forCellReuseIdentifier:MUSIC_TABLE_CELL_REUSE_ID];
    _musicTableView.delegate = self;
    _musicTableView.dataSource = self;
    _musicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self setupCollectionView];

    self.dbManager = [[DBManager alloc] initWithDBFileName:MUSIC_DATABASE_FILENAME];
}

- (void)setIsInGirdMode:(BOOL)isInGirdMode{
    _isInGirdMode = isInGirdMode;
    UIImage* icon = isInGirdMode? [UIImage imageNamed:@"icon-gridview"] : [UIImage imageNamed:@"icon-tableview"];
    [_btnChangeLayout setImage: icon forState:UIControlStateNormal];
}

- (void)setupCollectionView {
    [_musicCollectionView registerNib:[UINib nibWithNibName:MUSIC_COLLECTION_CELL_XIB bundle:nil] forCellWithReuseIdentifier:MUSIC_COLLECTION_CELL_ID];
    _musicCollectionView.dataSource = self;
    _musicCollectionView.delegate = self;
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

    [self reloadView];
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

    [self reloadView];
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

    [self reloadView];
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

    [self reloadView];
}

- (void)reloadView {
    [self.musicCollectionView reloadData];
    [self.musicTableView reloadData];
}

- (IBAction)actionChangeLayout:(id)sender {
    UIView * fromView = self.isInGirdMode ? _musicCollectionView : _musicTableView;
    UIView * toView = !self.isInGirdMode ? _musicCollectionView : _musicTableView;
    self.isInGirdMode = !self.isInGirdMode;

    [UIView transitionFromView:fromView toView:toView
                      duration:0.5f options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionShowHideTransitionViews completion:nil];
}


//MARK: Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrMusics.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MusicCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:MUSIC_COLLECTION_CELL_ID forIndexPath:indexPath];
    [cell bindDataWith:_arrMusics[indexPath.row]];
    cell.delegate = self;
    [cell setNeedsLayout];
    return cell;
}

//MARK: Collection view flow layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(200, 200);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {

    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 8    ;
}

//MARK: Collection cell delegate
- (void)didPressDelete:(MusicInfo *)musicInfo {
    NSUInteger index = [self.arrMusics indexOfObject:musicInfo];
    [self deleteMusicAtIndex:index];
}

- (void)didPressEdit:(MusicInfo *)musicInfo {
    NSUInteger index = [self.arrMusics indexOfObject:musicInfo];
    [self editMusicAtIndex:index];
}


@end
