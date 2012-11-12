//
//  TestViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "HomeViewController.h"
#import "UIImage+ResizeAdditions.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "CMConstants.h"
#import "PlayDetailViewController.h"
#import "FollowedUserViewController.h"
#import "CustomBackButton.h"
#import "ContainerUtility.h"
#import "MBProgressHUD.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ShowPlayDetailViewController.h"
#import "DramaPlayDetailViewController.h"
#import "VideoPlayDetailViewController.h"
#import "MyPlayDetailViewController.h"
#import "MyShowPlayDetailViewController.h"
#import "MyDramaPlayDetailViewController.h"
#import "MyVideoPlayDetailViewController.h"
#import "CacheUtility.h"
#import "UIUtility.h"

#define TOP_IMAGE_HEIGHT 170
#define TOP_GAP 40

@interface HomeViewController (){
    WaterflowView *flowView;
    int currentPage;
    MBProgressHUD *HUD;
    UIImage *selectedImage;
    BOOL imageChanged;
    BOOL isAvatarImage;
    NSInteger theUserFollowed;
    BOOL accessed;
    NSMutableArray *videoArray;
    NSString *key;
    NSString *serviceName;
}
- (void)addHeaderContent:(UIView *)view;
@end

@implementation HomeViewController
@synthesize watchedLabel;
@synthesize avatarImageViewBtn;
@synthesize fansLabel;
@synthesize bgView;
@synthesize segment;
@synthesize topImageView;
@synthesize avatarImageView;
@synthesize roundImageView;
@synthesize watchedNumberLabel;
@synthesize fansNumberLabel;
@synthesize watchBtn;
@synthesize collectionBtn;
@synthesize username;
@synthesize userid;
@synthesize offsety;

- (void)viewDidUnload
{
    [super viewDidUnload];
    flowView = nil;
    [videoArray removeAllObjects];
    videoArray = nil;
    key = nil;
    serviceName = nil;
    self.userid = nil;
    [self setSegment:nil];
    [self setTopImageView:nil];
    [self setAvatarImageView:nil];
    [self setRoundImageView:nil];
    [self setWatchedNumberLabel:nil];
    [self setFansNumberLabel:nil];
    [self setWatchBtn:nil];
    [self setCollectionBtn:nil];
    [self setUsername:nil];
    [self setWatchedLabel:nil];
    [self setFansLabel:nil];
    selectedImage = nil;
    [self setAvatarImageViewBtn:nil];
    [self setBgView:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"receive memory warning in %@", self.class);
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
    CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self addContentView];
    key = @"watchs";
    serviceName = kPathUserWatchs;
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:[NSString stringWithFormat:@"HomeViewController%@", self.userid]];
    if(cacheResult != nil){
        [self parseData:cacheResult];
    }
    [flowView reloadData];
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"1", @"page_num", @"30", @"page_size", self.userid, @"userid", nil];
        [[AFServiceAPIClient sharedClient] getPath:serviceName parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
            [flowView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            videoArray = [[NSMutableArray alloc]initWithCapacity:10];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        [UIUtility showNetWorkError:self.view];
    }
}


- (void)parseData:(id)result
{
    videoArray = [[NSMutableArray alloc]initWithCapacity:10];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"HomeViewController%@", self.userid] result:result];
        NSArray *videos = [result objectForKey:key];
        if(videos.count > 0){
            [videoArray addObjectsFromArray:videos];
        }
    } else {
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    if(videoArray == nil && HUD == nil && [[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [self showProgressBar];
    }
}

- (void)addContentView
{
    if(flowView != nil){
        [flowView removeFromSuperview];
    }
    CGRect getFrame = [[UIScreen mainScreen]applicationFrame];
    flowView = [[WaterflowView alloc] initWithFrameWithoutHeader:CGRectMake(0, 0, getFrame.size.width, getFrame.size.height - NAVIGATION_BAR_HEIGHT - self.offsety)];
    flowView.parentControllerName = @"HomeViewController";
    [flowView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    flowView.cellSelectedNotificationName = [NSString stringWithFormat:@"%@%@", @"myVideoSelected",self];
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
    [self.watchBtn removeFromSuperview];
    [self.collectionBtn removeFromSuperview];
    [self.watchedNumberLabel removeFromSuperview];
    [self.fansNumberLabel removeFromSuperview];
    [self.segment removeFromSuperview];
    [self.username removeFromSuperview];
    [self.watchedLabel removeFromSuperview];
    [self.fansLabel removeFromSuperview];
    [self.bgView removeFromSuperview];
    [self.avatarImageViewBtn removeFromSuperview];
    [flowView reloadData];
    
}

- (void)addHeaderContent:(UIView *)view
{
    [self.bgView addSubview:self.topImageView];
    [view addSubview:self.bgView];
    self.avatarImageView.layer.cornerRadius = 27.5;
    self.avatarImageView.layer.masksToBounds = YES;
    [view addSubview:self.avatarImageView];
    [view addSubview:self.roundImageView];
    [view addSubview:self.watchBtn];
    [view addSubview:self.collectionBtn];
    [view addSubview:self.watchedNumberLabel];
    [view addSubview:self.fansNumberLabel];
    [view addSubview:self.watchedLabel];
    [view addSubview:self.fansLabel];
    [view addSubview:self.username];
    [view addSubview:self.avatarImageViewBtn];
    
    UITapGestureRecognizer *tapgesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgImageClicked:)];
    tapgesture.delegate = self;
    tapgesture.numberOfTapsRequired=1;  //轻按对象次数（1）触发此行为
    tapgesture.numberOfTouchesRequired=1; //要求响应的手指数
    [self.bgView addGestureRecognizer:tapgesture];
    
    self.segment.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, TOP_IMAGE_HEIGHT + TOP_GAP, self.view.frame.size.width - MOVIE_LOGO_WIDTH_GAP * 2, SEGMENT_HEIGHT);
    self.segment.selectedSegmentIndex = self.segment.selectedSegmentIndex;
    [self.segment setTitle:NSLocalizedString(@"watched", nil) forSegmentAtIndex:0];
    [self.segment setTitle:NSLocalizedString(@"my_collection", nil) forSegmentAtIndex:1];
    [self.segment setTitle:NSLocalizedString(@"my_recommandation", nil) forSegmentAtIndex:2];
    [self.segment addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:self.segment];
}

- (void)parseHeaderData
{
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:[NSString stringWithFormat:@"HomeHeaderContent%@", self.userid]];
    if(cacheResult != nil){
        [self parseHeaderData:cacheResult];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.userid, @"userid",
                                    nil];
        //    if(!accessed){
        [[AFServiceAPIClient sharedClient] getPath:kPathUserView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseHeaderData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [UIUtility showSystemError:self.view];
        }];
    }
}

- (void)parseHeaderData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        [[CacheUtility sharedCache] putInCache:[NSString stringWithFormat:@"HomeHeaderContent%@", self.userid] result:result];
        accessed = YES;
        NSString *bgUrl = [result valueForKey:@"bg_url"];
        if([StringUtility stringIsEmpty:bgUrl]){
            self.topImageView.image = [UIImage imageNamed:@"user_picture.jpg"];
        } else {
            [self.topImageView setImageWithURL:[NSURL URLWithString:bgUrl] placeholderImage:[UIImage imageNamed:@"user_picture.jpg"]];
        }
        NSString *myUrl = [result valueForKey:@"pic_url"];
        if([StringUtility stringIsEmpty:myUrl]){
            self.avatarImageView.image = [UIImage imageNamed:@"u2_normal"];
        } else {
            [self.avatarImageView setImageWithURL:[NSURL URLWithString:[result valueForKey:@"pic_url"]] placeholderImage:[UIImage imageNamed:@"u2_normal"]];
        }
        self.fansNumberLabel.text = [NSString stringWithFormat:@"%@", [result valueForKey:@"fan_num"]];
        self.watchedNumberLabel.text = [NSString stringWithFormat:@"%@", [result valueForKey:@"follow_num"]];
        theUserFollowed = [[result valueForKey:@"isFollowed"] intValue];
        NSString *kUserIdString = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
        if (self.userid == nil || ![self.userid isEqualToString:kUserIdString]) {
            NSString *btnTitle;
            if(theUserFollowed != 1){
                btnTitle = NSLocalizedString(@"follow", nil);
            } else {
                btnTitle = NSLocalizedString(@"cancel_follow", nil);
            }
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:btnTitle style:UIBarButtonSystemItemSearch target:self action:@selector(cancelFollow:)];
            self.navigationItem.rightBarButtonItem = rightButton;
        }
        self.username.text = [result valueForKey:@"nickname"];
        
        self.title = [NSString stringWithFormat:@"%@的主页", [result valueForKey:@"nickname"]];
        self.tabBarItem.title = NSLocalizedString(@"list", nil);
    } else {
        [UIUtility showSystemError:self.view];
    }
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
    if(indexPath.row == 0){
        NSString *CellIdentifier = [NSString stringWithFormat:@"myProfileCell%i", indexPath.section];
        WaterFlowCell *cell = [flowView_ dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell  = [[WaterFlowCell alloc] initWithReuseIdentifier:CellIdentifier];
            if(indexPath.section == 0){
                [self addHeaderContent:cell];
            }
        }
        if(indexPath.section == 0){
            [self parseHeaderData];
        } else {
            cell.frame = CGRectZero;
        }
        return cell;
    } else {
        int index = (indexPath.row-1) * 3 + indexPath.section;
        if(index >= videoArray.count){
            return nil;
        }
        static NSString *CellIdentifier = @"myMovieCell";
        WaterFlowCell *cell = [flowView_ dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell  = [[WaterFlowCell alloc] initWithReuseIdentifier:CellIdentifier];
            cell.cellSelectedNotificationName = flowView.cellSelectedNotificationName;
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
            imageView.layer.borderWidth = 1;
            imageView.layer.borderColor = CMConstants.imageBorderColor.CGColor;
            imageView.layer.shadowColor = [UIColor blackColor].CGColor;
            imageView.layer.shadowOffset = CGSizeMake(1, 1);
            imageView.layer.shadowOpacity = 1;
            imageView.tag = 6001;
            [cell addSubview:imageView];
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            titleLabel.textAlignment = UITextAlignmentCenter;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = [UIFont systemFontOfSize:13];
            titleLabel.tag = 6002;
            [cell addSubview:titleLabel];
        }
        
        UIImageView *imageView  = (UIImageView *)[cell viewWithTag:6001];
        float height = [self flowView:nil heightForRowAtIndexPath:indexPath];
        if(indexPath.section == 0){
            imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, 0, MOVIE_LOGO_WIDTH, height - MOVE_NAME_LABEL_HEIGHT);
        } else if(indexPath.section == NUMBER_OF_COLUMNS - 1){
            imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, height - MOVE_NAME_LABEL_HEIGHT);
        } else {
            imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, height - MOVE_NAME_LABEL_HEIGHT);
        }
        NSString *imageUrl = [[videoArray objectAtIndex: index] objectForKey:@"content_pic_url"];
        [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"movie_placeholder"]];
        
        
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:6002];
        titleLabel.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, height - MOVE_NAME_LABEL_HEIGHT, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT);
        titleLabel.text =  [[videoArray objectAtIndex:index] objectForKey:@"content_name"];
        return cell;
        
    }
}

#pragma mark-
#pragma mark- WaterflowDelegate
-(CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 0;
    if(indexPath.row == 0) {
        height = TOP_IMAGE_HEIGHT + SEGMENT_HEIGHT + TOP_GAP + 8;
        return height;
    } else {
        int index = (indexPath.row-1) * 3 + indexPath.section;
        if(index >= videoArray.count){
            //            if((indexPath.row+1) % 10 == 0){
            //                return 120;
            //            }
            return 0;
        }
        NSString *type = [[videoArray objectAtIndex:index] objectForKey:@"content_type"];
        if([type isEqualToString:@"1"] || [type isEqualToString:@"2"]){
            height = MOVE_NAME_LABEL_HEIGHT + MOVIE_LOGO_HEIGHT;
        } else {
            height = MOVE_NAME_LABEL_HEIGHT + VIDEO_LOGO_HEIGHT;
        }
        return height;
    }
}

- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return;
    }
    int index = (indexPath.row-1) * 3 + indexPath.section;
    NSDictionary *program = [videoArray objectAtIndex:index];
    NSString *type = [[videoArray objectAtIndex:index] objectForKey:@"content_type"];
    PlayDetailViewController *viewController;
    if(self.segment.selectedSegmentIndex == 2){
        if([type isEqualToString:@"1"]){
            viewController = [[MyPlayDetailViewController alloc]initWithStretchImage];
        } else if([type isEqualToString:@"2"]){
            viewController = [[MyDramaPlayDetailViewController alloc]initWithStretchImage];
        } else if([type isEqualToString:@"3"]){
            viewController = [[MyShowPlayDetailViewController alloc]initWithStretchImage];
        } else if([type isEqualToString:@"4"]){
            viewController = [[MyVideoPlayDetailViewController alloc]initWithStretchImage];
        }
    } else {
        if([type isEqualToString:@"1"]){
            viewController = [[PlayDetailViewController alloc]initWithStretchImage];
        } else if([type isEqualToString:@"2"]){
            viewController = [[DramaPlayDetailViewController alloc]initWithStretchImage];
        } else if([type isEqualToString:@"3"]){
            viewController = [[ShowPlayDetailViewController alloc]initWithStretchImage];
        } else if([type isEqualToString:@"4"]){
            viewController = [[VideoPlayDetailViewController alloc]initWithStretchImage];
        }
    }
    viewController.userId = self.userid;
    viewController.programId = [program valueForKey:@"content_id"];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (void)flowView:(WaterflowView *)_flowView willLoadData:(int)page
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    currentPage++;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%i", currentPage], @"page_num", @"30", @"page_size", self.userid, @"userid", nil];
    [[AFServiceAPIClient sharedClient] getPath:serviceName parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *videos = [result objectForKey:key];
            if(videos != nil && videos.count > 0){
                [videoArray addObjectsFromArray:videos];
            }
        } else {
            
        }
        [flowView reloadData];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

- (void)segmentValueChanged:(id)sender {
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [self showProgressBar];
    if(self.segment.selectedSegmentIndex == 0){
        serviceName = kPathUserWatchs;
        key = @"watchs";
    } else if(self.segment.selectedSegmentIndex == 1){
        serviceName = kPathUserFavorities;
        key = @"favorities";
    } else {
        serviceName = kPathUserRecommends;
        key = @"recommends";
    }
    currentPage = 1;
    flowView.currentPage = 1;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%i", currentPage], @"page_num", @"30", @"page_size", self.userid, @"userid", nil];
    [[AFServiceAPIClient sharedClient] getPath:serviceName parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [videoArray removeAllObjects];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *videos = [result objectForKey:key];
            if(videos != nil && videos.count > 0){
                [videoArray addObjectsFromArray:videos];
            }
        } else {
            
        }
        [flowView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [videoArray removeAllObjects];
        [flowView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    }];
}

- (IBAction)followUser:(id)sender {
    FollowedUserViewController *viewController = [[FollowedUserViewController alloc]initWithNibName:@"FollowedUserViewController" bundle:nil];
    viewController.delegate = self;
    viewController.type = @"1";// 1 关注的
    viewController.userid = self.userid;
    viewController.nickname = self.username.text;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)fansUser:(id)sender {
    FollowedUserViewController *viewController = [[FollowedUserViewController alloc]initWithNibName:@"FollowedUserViewController" bundle:nil];
    viewController.delegate = self;
    viewController.type = @"2";// 2 粉丝
    viewController.userid = self.userid;
    viewController.nickname = self.username.text;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)cancelFollow:(id)sender
{
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.userid, @"friend_ids", nil];
    if([btn.title isEqualToString:NSLocalizedString(@"follow", nil)]){
        [btn setTitle:NSLocalizedString(@"cancel_follow", nil)];
        [[AFServiceAPIClient sharedClient] postPath:kPathFriendFollow parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                btn.title = NSLocalizedString(@"cancel_follow", nil);
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = NSLocalizedString(@"follow_success", nil);
                HUD.dimBackground = YES;
                [HUD show:YES];
                [HUD hide:YES afterDelay:1.5];
            } else {
                
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    } else {
        [[AFServiceAPIClient sharedClient] postPath:kPathFriendDestory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                btn.title = NSLocalizedString(@"follow", nil);
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = NSLocalizedString(@"cancel_follow_success", nil);
                HUD.dimBackground = YES;
                [HUD show:YES];
                [HUD hide:YES afterDelay:1.5];
            } else {
                
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
        
    }
    
    
    [[AFServiceAPIClient sharedClient] postPath:kPathFriendDestory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)closeSelf
{
    UIViewController *viewController = [self.navigationController popViewControllerAnimated:YES];
    if(viewController == nil){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)bgImageClicked:(id)sender {
    //    isAvatarImage = NO;
    //    [self photoCaptureButtonAction:sender];
}

- (IBAction)avatarImageClicked:(id)sender {
    //    isAvatarImage = YES;
    //    [self photoCaptureButtonAction:sender];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissModalViewControllerAnimated:NO];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if(isAvatarImage){
        UIImage *thumbnailImage = [originalImage thumbnailImage:60.0 transparentBorder:0.0f cornerRadius:10.0f interpolationQuality:kCGInterpolationDefault];
        selectedImage = originalImage;
        self.avatarImageView.image = thumbnailImage;
    } else {
        UIImage *thumbnailImage = [originalImage resizedImage:CGSizeMake(self.view.frame.size.width, TOP_IMAGE_HEIGHT) interpolationQuality:kCGInterpolationDefault];
        selectedImage = originalImage;
        self.topImageView.image = thumbnailImage;
        
    }
    imageChanged = YES;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self shouldStartCameraController];
    } else if (buttonIndex == 1) {
        [self shouldStartPhotoLibraryPickerController];
    }
}


#pragma mark - PAPTabBarController

- (BOOL)shouldPresentPhotoCaptureController {
    BOOL presentedPhotoCaptureController = [self shouldStartCameraController];
    
    if (!presentedPhotoCaptureController) {
        presentedPhotoCaptureController = [self shouldStartPhotoLibraryPickerController];
    }
    
    return presentedPhotoCaptureController;
}

#pragma mark - ()

- (void)photoCaptureButtonAction:(id)sender {
    BOOL cameraDeviceAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibraryAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraDeviceAvailable && photoLibraryAvailable) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take Photo", nil), NSLocalizedString(@"Choose Photo", nil), nil];
        [actionSheet showInView:self.view];
    } else {
        // if we don't have at least two options, we automatically show whichever is available (camera or roll)
        [self shouldPresentPhotoCaptureController];
    }
}

- (BOOL)shouldStartCameraController {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeCamera] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        } else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.showsCameraControls = YES;
    cameraUI.delegate = self;
    
    [self presentModalViewController:cameraUI animated:YES];
    
    return YES;
}


- (BOOL)shouldStartPhotoLibraryPickerController {
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
               && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage]) {
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
        
    } else {
        return NO;
    }
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = self;
    
    [self presentModalViewController:cameraUI animated:YES];
    
    return YES;
}

- (void)refreshContent
{
    [self.navigationController popViewControllerAnimated:YES];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%i", currentPage], @"page_num", @"30", @"page_size", self.userid, @"userid", nil];
    [[AFServiceAPIClient sharedClient] getPath:serviceName parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [flowView reloadData];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
