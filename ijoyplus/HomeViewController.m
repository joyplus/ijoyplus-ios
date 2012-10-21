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
    flowView = nil;
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"MessageListViewController"];
        [self parseData:cacheResult];
        [flowView reloadData];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kAppKey, @"app_key",
                                    @"1", @"page_num", @"30", @"page_size", self.userid, @"userid", nil];
        [[AFServiceAPIClient sharedClient] getPath:serviceName parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
            [flowView reloadData];
            [[CacheUtility sharedCache] putInCache:@"DramaViewController" result:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            videoArray = [[NSMutableArray alloc]initWithCapacity:10];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        }];
    }
}


- (void)parseData:(id)result
{
    videoArray = [[NSMutableArray alloc]initWithCapacity:10];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *videos = [result objectForKey:key];
        if(videos.count > 0){
            [videoArray addObjectsFromArray:videos];
        }
        [flowView reloadData];
    } else {
        
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    if(videoArray == nil){
        [self showProgressBar];
    }
}

- (void)addContentView
{
    if(flowView != nil){
        [flowView removeFromSuperview];
    }
    flowView = [[WaterflowView alloc] initWithFrameWithoutHeader:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.offsety)];
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
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kAppKey, @"app_key",
                                self.userid, @"userid",
                                nil];
    //    if(!accessed){
    [[AFServiceAPIClient sharedClient] getPath:kPathUserView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
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
            self.fansNumberLabel.text = [result valueForKey:@"fan_num"];
            self.watchedNumberLabel.text = [result valueForKey:@"follow_num"];
            theUserFollowed = [[result valueForKey:@"isFollowed"] intValue];
            if(theUserFollowed != 1){
                UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"follow", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(follow)];
                self.navigationItem.rightBarButtonItem = rightButton;
            }
            self.username.text = [result valueForKey:@"nickname"];
            
            self.title = [NSString stringWithFormat:@"%@的主页", [result valueForKey:@"nickname"]];
            self.tabBarItem.title = NSLocalizedString(@"list", nil);
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    //    }
    //    if(!accessed){
    //        accessed = YES;
    //    }
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
        int index = (indexPath.row-1) * 3 + indexPath.section;
        if(index >= videoArray.count){
            return cell;
        }
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        float height = [self flowView:nil heightForRowAtIndexPath:indexPath];
        if(indexPath.section == 0){
            imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, 0, MOVIE_LOGO_WIDTH, height - MOVE_NAME_LABEL_HEIGHT);
        } else if(indexPath.section == NUMBER_OF_COLUMNS - 1){
            imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, height - MOVE_NAME_LABEL_HEIGHT);
        } else {
            imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, height - MOVE_NAME_LABEL_HEIGHT);
        }
        NSString *imageUrl = [[videoArray objectAtIndex: index] objectForKey:@"content_pic_url"];
        [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        imageView.layer.shadowOffset = CGSizeMake(1, 1);
        imageView.layer.shadowOpacity = 1;
        [cell addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(MOVIE_LOGO_WIDTH_GAP, height - MOVE_NAME_LABEL_HEIGHT, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT)];
        titleLabel.text =  [[videoArray objectAtIndex:index] objectForKey:@"content_name"];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:13];
        [cell addSubview:titleLabel];
    }
    return cell;
    
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
    currentPage++;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kAppKey, @"app_key",
                                [NSString stringWithFormat:@"%i", currentPage], @"page_num", @"30", @"page_size", self.userid, @"userid", nil];
    [[AFServiceAPIClient sharedClient] getPath:serviceName parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *videos = [result objectForKey:key];
            if(videos != nil && videos.count > 0){
                [videoArray addObjectsFromArray:videos];
                [flowView reloadData];
            }
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

- (void)flowView:(WaterflowView *)_flowView refreshData:(int)page
{
    
}

- (void)segmentValueChanged:(id)sender {
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
    [videoArray removeAllObjects];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                kAppKey, @"app_key",
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    }];
}

- (IBAction)followUser:(id)sender {
    FollowedUserViewController *viewController = [[FollowedUserViewController alloc]initWithNibName:@"FollowedUserViewController" bundle:nil];
    viewController.type = @"1";// 1 关注的
    viewController.userid = self.userid;
    viewController.nickname = self.username.text;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)fansUser:(id)sender {
    FollowedUserViewController *viewController = [[FollowedUserViewController alloc]initWithNibName:@"FollowedUserViewController" bundle:nil];
    viewController.type = @"2";// 2 粉丝
    viewController.userid = self.userid;
    viewController.nickname = self.username.text;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)follow
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:kAppKey, @"app_key", self.userid, @"friend_ids", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathFriendFollow parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if([responseCode isEqualToString:kSuccessResCode]){
            HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
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
@end
