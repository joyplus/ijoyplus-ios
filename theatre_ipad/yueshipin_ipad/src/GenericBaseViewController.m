//
//  GenericBaseViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "GenericBaseViewController.h"
#import "Reachability.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ContainerUtility.h"
#import "CMConstants.h"
#import "AppDelegate.h"
#import "StackScrollViewController.h"
#import "RootViewController.h"
#import "CommonHeader.h"
#import "CloseTipsView.h"

#define CLOSE_TIPS_VIEW_TAG (1111)

@implementation GenericBaseViewController
@synthesize swipeRecognizer;
@synthesize bgImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    myHUD = [[UIUtility alloc]init];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    swipeRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(closeBtnClicked)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRecognizer.numberOfTouchesRequired=1;
    
    CloseTipsView * cView = [[CloseTipsView alloc] initWithFrame:CGRectMake(0, 627, self.view.frame.size.width, 121)];
    [self.view addSubview:cView];
    cView.tag = CLOSE_TIPS_VIEW_TAG;
    cView.hidden = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    myHUD = nil;
    swipeRecognizer = nil;
}

- (void)closeBtnClicked
{
   [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
}

- (float)getFreeDiskspacePercent
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace_ = [fileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
        totalFreeSpace_ = [freeFileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
    }
    float percent = (totalSpace_-totalFreeSpace_)/totalSpace_;
    return percent;
}

- (void)setCloseTipsViewHidden:(BOOL)isHidden
{
    UIView * cView = [self.view viewWithTag:CLOSE_TIPS_VIEW_TAG];
    if (NO == isHidden)
    {
        [self.view bringSubviewToFront:cView];
    }
    cView.hidden = isHidden;
}

@end
