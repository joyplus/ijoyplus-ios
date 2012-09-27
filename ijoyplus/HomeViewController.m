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
#import "PlayRootViewController.h"
#import "FollowedUserViewController.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "ContainerUtility.h"
#import "MBProgressHUD.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define TOP_IMAGE_HEIGHT 170
#define TOP_GAP 40

@interface HomeViewController (){
    WaterflowView *flowView;
    NSMutableArray *imageUrls;
    int currentPage;
    int tempCount;
    MBProgressHUD *HUD;
    UIImage *selectedImage;
    BOOL imageChanged;
    UIButton *triggerBtn;
    
}
- (void)addHeaderContent:(UIView *)view;
@end

@implementation HomeViewController
@synthesize loveLabel;
@synthesize watchedLabel;
@synthesize bgImageViewBtn;
@synthesize avatarImageViewBtn;
@synthesize fansLabel;
@synthesize segment;
@synthesize topImageView;
@synthesize avatarImageView;
@synthesize roundImageView;
@synthesize loveNumberLabel;
@synthesize watchedNumberLabel;
@synthesize fansNumberLabel;
@synthesize loveBtn;
@synthesize watchBtn;
@synthesize collectionBtn;
@synthesize username;

- (void)viewDidUnload
{
    flowView = nil;
    imageUrls = nil;
    [self setSegment:nil];
    [self setTopImageView:nil];
    [self setAvatarImageView:nil];
    [self setRoundImageView:nil];
    [self setLoveNumberLabel:nil];
    [self setWatchedNumberLabel:nil];
    [self setFansNumberLabel:nil];
    [self setLoveBtn:nil];
    [self setWatchBtn:nil];
    [self setCollectionBtn:nil];
    [self setUsername:nil];
    [self setLoveLabel:nil];
    [self setWatchedLabel:nil];
    [self setFansLabel:nil];
    selectedImage = nil;
    triggerBtn = nil;
    [self setBgImageViewBtn:nil];
    [self setAvatarImageViewBtn:nil];
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
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"follow", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(follow)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
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
    NSString *flag = @"0";
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
    if([num boolValue]){
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
    [self.fansNumberLabel removeFromSuperview];
    [self.segment removeFromSuperview];
    [self.username removeFromSuperview];
    [self.loveLabel removeFromSuperview];
    [self.watchedLabel removeFromSuperview];
    [self.fansLabel removeFromSuperview];
    [flowView reloadData];
    
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
    [view addSubview:self.fansNumberLabel];
    [view addSubview:self.loveLabel];
    [view addSubview:self.watchedLabel];
    [view addSubview:self.fansLabel];
    self.username.text = @"Joyce";
    [view addSubview:self.username];
    [view addSubview:self.avatarImageViewBtn];
    [view addSubview:self.bgImageViewBtn];
    
    self.segment.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, TOP_IMAGE_HEIGHT + TOP_GAP, self.view.frame.size.width - MOVIE_LOGO_WIDTH_GAP * 2, SEGMENT_HEIGHT);
    self.segment.selectedSegmentIndex = self.segment.selectedSegmentIndex;
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
        float height = [self flowView:nil heightForRowAtIndexPath:indexPath];
        if(indexPath.section == 0){
            imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, 0, MOVIE_LOGO_WIDTH, height - MOVE_NAME_LABEL_HEIGHT);
        } else if(indexPath.section == NUMBER_OF_COLUMNS - 1){
            imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, height - MOVE_NAME_LABEL_HEIGHT);
        } else {
            imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, MOVIE_LOGO_WIDTH, height - MOVE_NAME_LABEL_HEIGHT);
        }
        [imageView setImageWithURL:[NSURL URLWithString:[imageUrls objectAtIndex:(indexPath.row + indexPath.section) % tempCount]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        imageView.layer.shadowOffset = CGSizeMake(1, 1);
        imageView.layer.shadowOpacity = 1;
        [cell addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(MOVIE_LOGO_WIDTH_GAP, height - MOVE_NAME_LABEL_HEIGHT, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT)];
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
	if(indexPath.row == 0) {
		height = TOP_IMAGE_HEIGHT + SEGMENT_HEIGHT + TOP_GAP + 8;
        return height;
    } else if(indexPath.section % 3 == 0) {
        height = MOVIE_LOGO_HEIGHT + MOVE_NAME_LABEL_HEIGHT;
    } else if(indexPath.section % 3 == 1 || indexPath.section % 3 == 2) {
        height = VIDEO_LOGO_HEIGHT + MOVE_NAME_LABEL_HEIGHT;
    }
    return height + MOVE_NAME_LABEL_HEIGHT;
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
    [imageUrls removeAllObjects];
    [imageUrls addObject:@"http://img5.douban.com/mpic/s10389149.jpg"];
    [imageUrls addObject:@"http://img5.douban.com/mpic/s10389149.jpg"];
    [imageUrls addObject:@"http://img5.douban.com/mpic/s10389149.jpg"];
    [imageUrls addObject:@"http://img5.douban.com/mpic/s10389149.jpg"];
    tempCount = imageUrls.count;
    [flowView reloadData];
}

- (IBAction)followUser:(id)sender {
    FollowedUserViewController *viewController = [[FollowedUserViewController alloc]initWithNibName:@"FollowedUserViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)follow
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"follow_success", nil);
    HUD.dimBackground = YES;
    [HUD show:YES];
	[HUD hide:YES afterDelay:2];
}

- (void)closeSelf
{
    UIViewController *viewController = [self.navigationController popViewControllerAnimated:YES];
    if(viewController == nil){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)bgImageClicked:(id)sender {
    triggerBtn = (UIButton *)sender;
    [self photoCaptureButtonAction:sender];
}

- (IBAction)avatarImageClicked:(id)sender {
    triggerBtn = (UIButton *)sender;
    [self photoCaptureButtonAction:sender];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissModalViewControllerAnimated:NO];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if(triggerBtn.tag == 0){
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
