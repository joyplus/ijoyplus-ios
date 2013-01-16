//
//  ProgramViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-8.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ProgramViewController.h"
#import "DateUtility.h"
#import "CMConstants.h"
#import "CacheUtility.h"
#import "CommonHeader.h"


@interface ProgramViewController (){
}

@end

@implementation ProgramViewController
@synthesize programUrl;
@synthesize webView;
@synthesize subname;
@synthesize type;
@synthesize prodId;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"receive memory warning in %@", self.class);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.webView loadRequest: nil];
    [self.webView removeFromSuperview];
    self.webView = nil;
    self.programUrl = nil;
    self.prodId = nil;
    self.subname = nil;
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
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(0, 0, 56, 29);
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn"] forState:UIControlStateNormal];
    [myButton setBackgroundImage:[UIImage imageNamed:@"left_btn_pressed"] forState:UIControlStateHighlighted];
    [myButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside]; 
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:myButton];
    self.navigationItem.leftBarButtonItem = customItem;
    
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    t.font = [UIFont boldSystemFontOfSize:18];
    t.textColor = [UIColor whiteColor];
    t.backgroundColor = [UIColor clearColor];
    t.textAlignment = UITextAlignmentCenter;
    t.text = self.title;
    self.navigationItem.titleView = t;
    
    NSURL *url = [NSURL URLWithString:self.programUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
    [self updateWatchRecord];
}

- (void)closeSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)updateWatchRecord
{
    self.subname = self.subname == nil ? @"" : self.subname;
    NSString *userId = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: userId, @"userid", self.prodId, @"prod_id", self.title, @"prod_name", self.subname, @"prod_subname", [NSNumber numberWithInt:self.type], @"prod_type", @"2", @"play_type", @"0", @"playback_time", @"0", @"duration", self.programUrl, @"video_url", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathAddPlayHistory parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WATCH_HISTORY_REFRESH object:nil];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
   return toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
    
}
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIDeviceOrientationLandscapeLeft;
}



- (void) hideGradientBackground:(UIView*)theView
{
    for (UIView * subview in theView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
        
        [self hideGradientBackground:subview];
    }
}

//- (UIButton *)findButtonInView:(UIView *)view {
//    UIButton *button = nil;
//
//    if ([view isMemberOfClass:[UIButton class]]) {
//        return (UIButton *)view;
//    }
//
//    if (view.subviews && [view.subviews count] > 0) {
//        for (UIView *subview in view.subviews) {
//            button = [self findButtonInView:subview];
//            if (button) return button;
//        }
//    }
//
//    return button;
//}

@end
