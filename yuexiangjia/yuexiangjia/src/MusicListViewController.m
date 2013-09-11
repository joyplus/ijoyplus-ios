//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "MusicListViewController.h"
#import "CommonHeader.h"
#import "GroupMediaObject.h"
#import "MediaObject.h"
#import "PlayMusicViewController.h"

@interface MusicListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)MPMusicPlayerController *musicPlayer;
@property (nonatomic, strong)UITableView *table;
@property (nonatomic,strong)NSArray *items;

@end

@implementation MusicListViewController
@synthesize table;
@synthesize items;
@synthesize musicPlayer;

- (void)viewDidUnload
{
    [super viewDidUnload];
    table = nil;
    items = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的音乐";
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT - TOOLBAR_HEIGHT)];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.showsVerticalScrollIndicator = NO;
    table.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:table];
    
    musicPlayer = [AppDelegate instance].musicPlayer;
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    items = [query items];
    [super showNavigationBar:@"我的音乐"];
    [super showToolbar];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        UIBarButtonItem* sureBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"Playing" style:UIBarButtonItemStyleDone target:self action:@selector(showPlayingMedia)];
        self.navBar.topItem.rightBarButtonItem = sureBtnItem;
    }
    [table reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.contentView.backgroundColor = CMConstants.whiteBackgroundColor;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 70, 70)];
        imageView.tag = 1001;
        [cell.contentView addSubview:imageView];
        
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(90, 28, 180, 30)];
        name.tag = 2001;
        name.textColor = CMConstants.textGreyColor;
        name.font = [UIFont systemFontOfSize:15];
        name.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:name];
        
        UILabel *duration = [[UILabel alloc]initWithFrame:CGRectMake(250, 28, 60, 30)];
        duration.textAlignment = NSTextAlignmentRight;
        duration.backgroundColor = [UIColor clearColor];
        duration.font = [UIFont systemFontOfSize:14];
        duration.textColor = CMConstants.textGreyColor;
        duration.tag = 3001;
        [cell.contentView addSubview:duration];
        
        UIImageView *separator = [[UIImageView alloc]initWithFrame:CGRectMake(0, 78, self.bounds.size.width, 2)];
        separator.image = [UIImage imageNamed:@"divider_640"];
        [cell.contentView addSubview:separator];
        
        UIImageView *playingImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        playingImage.center = imageView.center;
        playingImage.image = [UIImage imageNamed:@"playing_icon"];
        [playingImage setHidden:YES];
        playingImage.tag = 4001;
        [cell.contentView addSubview:playingImage];
    }
    MPMediaItem *media = [items objectAtIndex:indexPath.row];
    
    UIImageView *imageView  = (UIImageView *)[cell viewWithTag:1001];
    MPMediaItemArtwork *artworkItem = [media valueForProperty: MPMediaItemPropertyArtwork];
    if ([artworkItem imageWithSize:CGSizeMake(320, 320)]) {
        [imageView setImage:[artworkItem imageWithSize:CGSizeMake (320, 320)]];
    } else {
        [imageView setImage:[UIImage imageNamed:@"song_default"]];
    }
    
    UILabel *name  = (UILabel *)[cell viewWithTag:2001];
    name.text = [media valueForProperty: MPMediaItemPropertyTitle];
    UILabel *duration = (UILabel *)[cell viewWithTag:3001];
    NSNumber *durationNum = (NSNumber *)[media valueForProperty:MPMediaItemPropertyPlaybackDuration];
    duration.text = [TimeUtility formatTimeInSecond:durationNum.doubleValue];
    UIImageView *playingImage  = (UIImageView *)[cell viewWithTag:4001];
    if (musicPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        MPMediaItem *playItem = [musicPlayer nowPlayingItem];
        long playingId = ((NSNumber *)[playItem valueForKey:MPMediaItemPropertyPersistentID]).longValue;
        long mediaId = ((NSNumber *)[media valueForKey:MPMediaItemPropertyPersistentID]).longValue;
        if (playingId == mediaId) {
            name.textColor = CMConstants.textBlueColor;
            duration.textColor = CMConstants.textBlueColor;
            [playingImage setHidden:NO];
        } else {
            name.textColor = CMConstants.textGreyColor;
            duration.textColor = CMConstants.textGreyColor;
            [playingImage setHidden:YES];
        }
    } else {
        [playingImage setHidden:YES];
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < items.count) {
        PlayMusicViewController *viewController = [[PlayMusicViewController alloc]init];
        viewController.mediaArray = items;
        viewController.startIndex = indexPath.row;
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)showPlayingMedia
{
    if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        PlayMusicViewController *viewController = [[PlayMusicViewController alloc]init];
        viewController.mediaArray = items;
        viewController.showPlaying = YES;
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)backButtonClicked
{
    [super homeButtonClicked];
}



@end
