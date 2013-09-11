//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "VideoGridViewController.h"
#import "CommonHeader.h"
#import "GroupMediaObject.h"
#import "MediaObject.h"
#import "PlayVideoViewController.h"
#import "CustomNavigationViewController.h"

#define IMAGE_WIDTH 86

@interface VideoGridViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSMutableArray *mediaObjectArray;
@property (nonatomic, strong)UITableView *table;

@end

@implementation VideoGridViewController
@synthesize table;
@synthesize mediaObjectArray;
@synthesize homeDelegate;

- (void)viewDidUnload
{
    [super viewDidUnload];
    table = nil;
    [mediaObjectArray removeAllObjects];
    mediaObjectArray = nil;
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
    
    self.title = @"我的视频";
    [self addMenuView:-NAVIGATION_BAR_HEIGHT];
    [self addContententView:-NAVIGATION_BAR_HEIGHT];
    [self showMenuBtnForNavController];
    [self showBackBtnForNavController];
    
    self.mediaType = 2;
    [super loadLocalMediaFiles];
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT)];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.tableFooterView = [[UIView alloc] init];
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.showsVerticalScrollIndicator = NO;
    [self addInContentView:table];
}

- (void)reloadTableView
{
    mediaObjectArray = [[NSMutableArray alloc]initWithCapacity:10];
    for (GroupMediaObject *groupMedia in self.groupMediaArray) {
        [mediaObjectArray addObjectsFromArray:groupMedia.mediaObjectArray];
    }
    [table reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [table reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceil(self.mediaObjectArray.count / 3.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.contentView.backgroundColor = CMConstants.whiteBackgroundColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        for (int i = 0; i < 3; i++) {
            UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            imageBtn.frame = CGRectMake((IMAGE_WIDTH + 15) * i + 14, 0, IMAGE_WIDTH+ 10, IMAGE_WIDTH + 10);
            imageBtn.center = CGPointMake(imageBtn.center.x, IMAGE_WIDTH/2 + 10);
            [imageBtn addTarget:self action:@selector(mediaImageClicked:)forControlEvents:UIControlEventTouchUpInside];
            imageBtn.tag = 2001 + i;
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"cover_default"] forState:UIControlStateNormal];
            [imageBtn setBackgroundImage:[UIImage imageNamed:@"cover_active"] forState:UIControlStateHighlighted];
            [cell.contentView addSubview:imageBtn];
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
            imageView.tag = 1001 + i;
            imageView.frame = CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_WIDTH+2);
            imageView.center = imageBtn.center;
            [cell.contentView addSubview:imageView];
            
            
            UILabel *durationLabel = [[UILabel alloc]initWithFrame:CGRectMake((IMAGE_WIDTH + 15) * i + 19, 9 + imageView.frame.size.height * 0.7, IMAGE_WIDTH, imageView.frame.size.height * 0.3)];
            durationLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
            durationLabel.opaque = YES;
            durationLabel.tag = 3001 + i;
            durationLabel.textColor = [UIColor whiteColor];
            durationLabel.font = [UIFont systemFontOfSize:13];
            durationLabel.textAlignment = UITextAlignmentRight;
            [cell.contentView addSubview:durationLabel];
            
            UIImageView *videoIcon = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 15, 15)];
            videoIcon.image = [UIImage imageNamed:@"video_icon"];
            [durationLabel addSubview:videoIcon];
            
            UIImageView *playingImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
            playingImage.center = imageView.center;
            playingImage.image = [UIImage imageNamed:@"playing_icon"];
            [playingImage setHidden:YES];
            playingImage.tag = 4001 + i;
            [cell.contentView addSubview:playingImage];
        }
    }
    int num = 3;
    if(self.mediaObjectArray.count < (indexPath.row+1) * 3){
        num = self.mediaObjectArray.count - indexPath.row * 3;
    }
    for(int i = 0; i < 3; i++){
        UIImageView *imageView  = (UIImageView *)[cell viewWithTag:1001 + i];
        UIButton *imageBtn  = (UIButton *)[cell viewWithTag:2001 + i];
        UILabel *durationLabel  = (UILabel *)[cell viewWithTag:3001 + i];
        UIImageView *playingImage  = (UIImageView *)[cell viewWithTag:4001 + i];
        if(i < num){
            MediaObject *media = [self.mediaObjectArray objectAtIndex:indexPath.row * 3 + i];
            imageView.image = media.image;
            durationLabel.text = [TimeUtility formatTimeInSecond:media.duration];
//            if ([media.mediaURL isEqualToString:[AppDelegate instance].videoMedia.mediaURL]) {
//                [playingImage setHidden:NO];
//            } else {
//                [playingImage setHidden:YES];
//            }
        } else {
            imageView.image = nil;
            [imageBtn removeFromSuperview];
            [durationLabel removeFromSuperview];
            [playingImage setHidden:YES];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return IMAGE_WIDTH + 20;
}

- (void)mediaImageClicked:(UIButton *)btn
{
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    int index = indexPath.row * 3 + btn.tag - 2001;
    if(index >= mediaObjectArray.count){
        return;
    }
    MediaObject *media = [mediaObjectArray objectAtIndex:index];
    PlayVideoViewController *viewController = [[PlayVideoViewController alloc]init];
    viewController.media = media;
    viewController.playList = mediaObjectArray;
    CustomNavigationViewController *navViewController = [[CustomNavigationViewController alloc]initWithRootViewController:viewController];
    [self presentViewController:navViewController animated:YES completion:nil];
}

- (void)backButtonClicked
{
    [homeDelegate closeChildWindow:self];
}

@end
