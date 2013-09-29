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
#import "BaseUINavigationController.h"

@interface MusicListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)MPMusicPlayerController *musicPlayer;
@property (nonatomic, strong)UITableView *table;
@property (nonatomic,strong)NSArray *items;

@end

@implementation MusicListViewController
@synthesize table;
@synthesize items;
@synthesize musicPlayer;
@synthesize homeDelegate;

- (void)viewDidUnload
{
    [super viewDidUnload];
    table = nil;
    items = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"memory warning");
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
    [self addMenuView:-NAVIGATION_BAR_HEIGHT];
    [self addContententView:-NAVIGATION_BAR_HEIGHT];
    [self showMenuBtnForNavController];
    [self showBackBtnForNavController];
    
    musicPlayer = [AppDelegate instance].musicPlayer;
    MPMediaQuery *query = [[MPMediaQuery alloc]init];
    items = [query items];
    if (items) {
        NSLog(@"%@", items);
    }
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT)];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.showsVerticalScrollIndicator = NO;
    table.tableFooterView = [[UIView alloc] init];
    [self addInContentView:table];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
//        UIBarButtonItem* sureBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"Playing" style:UIBarButtonItemStyleDone target:self action:@selector(showPlayingMedia)];
//        self.navigationItem.rightBarButtonItem = sureBtnItem;
//    }
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
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 75)];
        image.image = [[UIImage imageNamed:@"cell_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        cell.selectedBackgroundView = image;
        
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 58, 58)];
        bgImageView.image = [UIImage imageNamed:@"cover_default"];
        [cell.contentView addSubview:bgImageView];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 54, 54)];
        imageView.tag = 1001;
        [cell.contentView addSubview:imageView];
        
        UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(90, 0, 170, 75)];
        name.tag = 2001;
        name.textColor = [UIColor whiteColor];
        name.font = [UIFont systemFontOfSize:18];
        //name.textAlignment = UITextAlignmentCenter;
        name.numberOfLines = 2;
        name.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:name];
        
        UILabel *duration = [[UILabel alloc]initWithFrame:CGRectMake(250, 0, 58, 75)];
        duration.textAlignment = NSTextAlignmentRight;
        duration.backgroundColor = [UIColor clearColor];
        duration.font = [UIFont systemFontOfSize:16];
        duration.textColor = [UIColor grayColor];
        duration.tag = 3001;
        [cell.contentView addSubview:duration];
        
        UIImageView *separator = [[UIImageView alloc]initWithFrame:CGRectMake(0, 73, self.bounds.size.width, 2)];
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
    if ([artworkItem imageWithSize:CGSizeMake(320, 320)])
    {
        [imageView setImage:[artworkItem imageWithSize:CGSizeMake (320, 320)]];
    }
    else
    {
        [imageView setImage:[UIImage imageNamed:@"song_default"]];
    }
    
    UILabel *name  = (UILabel *)[cell viewWithTag:2001];
    name.text = [media valueForProperty: MPMediaItemPropertyTitle];
    UILabel *duration = (UILabel *)[cell viewWithTag:3001];
    NSNumber *durationNum = (NSNumber *)[media valueForProperty:MPMediaItemPropertyPlaybackDuration];
    duration.text = [TimeUtility formatTimeInSecond:durationNum.doubleValue];
    UIImageView *playingImage  = (UIImageView *)[cell viewWithTag:4001];
    if (musicPlayer.playbackState == MPMoviePlaybackStatePlaying)
    {
        MPMediaItem *playItem = [musicPlayer nowPlayingItem];
        long playingId = ((NSNumber *)[playItem valueForKey:MPMediaItemPropertyPersistentID]).longValue;
        long mediaId = ((NSNumber *)[media valueForKey:MPMediaItemPropertyPersistentID]).longValue;
        if (playingId == mediaId) {
            name.textColor = CMConstants.textBlueColor;
            duration.textColor = CMConstants.textBlueColor;
            [playingImage setHidden:NO];
        } else {
            name.textColor = [UIColor whiteColor];
            duration.textColor = [UIColor grayColor];
            [playingImage setHidden:YES];
        }
    }
    else
    {
        name.textColor = [UIColor whiteColor];
        duration.textColor = [UIColor grayColor];
        [playingImage setHidden:YES];
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < items.count) {
        PlayMusicViewController *viewController = [[PlayMusicViewController alloc]init];
        viewController.mediaArray = items;
        viewController.startIndex = indexPath.row;
        BaseUINavigationController *navViewController = [[BaseUINavigationController alloc]initWithRootViewController:viewController];
        [self presentViewController:navViewController animated:YES completion:nil];
    }
}

- (void)showPlayingMedia
{
    if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        PlayMusicViewController *viewController = [[PlayMusicViewController alloc]init];
        viewController.mediaArray = items;
        viewController.showPlaying = YES;
        BaseUINavigationController *navViewController = [[BaseUINavigationController alloc]initWithRootViewController:viewController];
        [self presentViewController:navViewController animated:YES completion:nil];
    }
}

- (void)backButtonClicked
{
    [homeDelegate closeChildWindow:self];
    //[super homeButtonClicked];
}

- (void)homeButtonClicked
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [super homeButtonClicked];
}

@end
