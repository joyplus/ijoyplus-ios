//
//  TestViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "HomeViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "CMConstants.h"
#import "PlayRootViewController.h"
#import "FollowedUserViewController.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"

#define TOP_IMAGE_HEIGHT 180
#define TOP_GAP 50

@interface HomeViewController (){
    WaterflowView *flowView;
    NSMutableArray *imageUrls;
    int currentPage;
    int tempCount;
}

- (void)addHeaderContent:(UIView *)view;
@end

@implementation HomeViewController
@synthesize segment;
@synthesize topImageView;
@synthesize avatarImageView;
@synthesize roundImageView;
@synthesize loveNumberLabel;
@synthesize watchedNumberLabel;
@synthesize collectionNumberLabel;
@synthesize loveBtn;
@synthesize watchBtn;
@synthesize collectionBtn;
@synthesize username;

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
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	
    imageUrls = [NSMutableArray arrayWithObjects:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg",@"http://img1.douban.com/lpic/s11184513.jpg",@"http://img1.douban.com/lpic/s9127643.jpg",@"http://img3.douban.com/lpic/s6781186.jpg",@"http://img1.douban.com/mpic/s9039761.jpg",nil];
    tempCount = imageUrls.count;
    [self addContentView];
    
}

- (void)addContentView
{
    if(flowView != nil){
        [flowView removeFromSuperview];
    }
    flowView = [[WaterflowView alloc] initWithFrame:self.view.frame];
    [flowView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *flag = @"0";
    if(appDelegate.userLoggedIn){
        flag = @"1";
    }
    flowView.cellSelectedNotificationName = [NSString stringWithFormat:@"%@%@", @"myVideoSelected",flag];
    [flowView showsVerticalScrollIndicator];
    flowView.flowdatasource = self;
    flowView.flowdelegate = self;
    flowView.mergeRow = 0;
    flowView.mergeCell = YES;
    [self.view addSubview:flowView];
    
    currentPage = 1;
    
    [self.topImageView removeFromSuperview];
    [self.avatarImageView removeFromSuperview];
    [self.roundImageView removeFromSuperview];
    [self.loveBtn removeFromSuperview];
    [self.watchBtn removeFromSuperview];
    [self.collectionBtn removeFromSuperview];
    [self.loveNumberLabel removeFromSuperview];
    [self.watchedNumberLabel removeFromSuperview];
    [self.collectionNumberLabel removeFromSuperview];
    [self.segment removeFromSuperview];
    [self.username removeFromSuperview];
    [flowView reloadData];
    
}

- (void)viewDidUnload
{
    [self setSegment:nil];
    [self setTopImageView:nil];
    [self setAvatarImageView:nil];
    [self setRoundImageView:nil];
    [self setLoveNumberLabel:nil];
    [self setWatchedNumberLabel:nil];
    [self setCollectionNumberLabel:nil];
    [self setLoveBtn:nil];
    [self setWatchBtn:nil];
    [self setCollectionBtn:nil];
    [self setUsername:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)addHeaderContent:(UIView *)view
{
    
    [view addSubview:self.topImageView];
    self.avatarImageView.image = [UIImage imageNamed:@"u0_normal"];
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    self.avatarImageView.layer.cornerRadius = 27.5;
    self.avatarImageView.layer.masksToBounds = YES;
    [view addSubview:self.avatarImageView];
    [view addSubview:self.roundImageView];
    [view addSubview:self.loveBtn];
    [view addSubview:self.watchBtn];
    [view addSubview:self.collectionBtn];
    [view addSubview:self.loveNumberLabel];
    [view addSubview:self.watchedNumberLabel];
    [view addSubview:self.collectionNumberLabel];
    self.username.text = @"Joyce";
    [view addSubview:self.username];
    
    self.segment.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, TOP_IMAGE_HEIGHT + 40, self.view.frame.size.width - MOVIE_LOGO_WIDTH_GAP * 2, SEGMENT_HEIGHT);
    self.segment.selectedSegmentIndex = 0;
    [self.segment setTitle:NSLocalizedString(@"watched", nil) forSegmentAtIndex:0];
    [self.segment setTitle:NSLocalizedString(@"my_collection", nil) forSegmentAtIndex:1];
    [self.segment addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:self.segment];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark-
#pragma mark- WaterflowDataSource

- (NSInteger)numberOfColumnsInFlowView:(WaterflowView *)flowView
{
    return NUMBER_OF_COLUMNS;
}

- (NSInteger)flowView:(WaterflowView *)flowView numberOfRowsInColumn:(NSInteger)column
{
    return 10;
}

- (WaterFlowCell*)flowView:(WaterflowView *)flowView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"movieCell";
    WaterFlowCell *cell = [[WaterFlowCell alloc] initWithReuseIdentifier:CellIdentifier];
    cell.cellSelectedNotificationName = flowView.cellSelectedNotificationName;
    if(indexPath.row == 0){
        if(indexPath.section == 0){
            [self addHeaderContent:cell];
        }
    } else {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        if(indexPath.section == 0){
            imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
        } else if(indexPath.section == NUMBER_OF_COLUMNS - 1){
            imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
        } else {
            imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
        }
        [imageView setImageWithURL:[NSURL URLWithString:[imageUrls objectAtIndex:(indexPath.row + indexPath.section) % tempCount]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        imageView.layer.shadowOffset = CGSizeMake(1, 1);
        imageView.layer.shadowOpacity = 1;
        [cell addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(MOVIE_LOGO_WIDTH_GAP, MOVIE_LOGO_HEIGHT + 5, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT)];
        titleLabel.text = [NSString stringWithFormat:@"%i, %i", indexPath.row, indexPath.section];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = CMConstants.titleFont;
        [cell addSubview:titleLabel];
    }
    return cell;
    
}

#pragma mark-
#pragma mark- WaterflowDelegate
-(CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0;
	switch (indexPath.row) {
		case 0:
			height = TOP_IMAGE_HEIGHT + SEGMENT_HEIGHT + TOP_GAP;
			break;
		default:
            height = MOVIE_LOGO_HEIGHT + MOVE_NAME_LABEL_HEIGHT + 5 + 10;
			break;
	}
	
	return height;
}

- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;
    PlayRootViewController *viewController = [[PlayRootViewController alloc]init];
    //    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [navController pushViewController:viewController animated:YES];
}

- (void)flowView:(WaterflowView *)_flowView willLoadData:(int)page
{
    [imageUrls addObject:@"http://img5.douban.com/mpic/s10389149.jpg"];
    tempCount = imageUrls.count;
    [flowView reloadData];
}

- (void)segmentValueChanged:(id)sender {
}

- (IBAction)followUser:(id)sender {
    FollowedUserViewController *viewController = [[FollowedUserViewController alloc]initWithNibName:@"FollowedUserViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)closeSelf
{
    UIViewController *viewController = [self.navigationController popViewControllerAnimated:YES];
    if(viewController == nil){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
