//
//  FeedBackViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "FeedBackViewController.h"
#import "AFServiceAPIClient.h"
#import "Reachability.h"
#import "UIUtility.h"
#import "ServiceConstants.h"
#import "UIImage+Scale.h"

@interface FeedBackViewController ()

@end

@implementation FeedBackViewController
@synthesize textView = textView_;
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
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.frame = CGRectMake(0, 0, 320, 480);
    [self.view addSubview:bg];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_return_common.png"]  toSize:CGSizeMake(20, 18)] forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
	self.title = @"意见反馈";
    textView_ = [[UITextView alloc] initWithFrame:CGRectMake(13, 15, 294, 94)];
    
    [self.view addSubview:textView_];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(239, 116, 65, 24)];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"send_btn.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"send_btn_disabled.png"] forState:UIControlStateHighlighted];
    
    [self.view addSubview:button];
}

-(void)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)buttonPressed:(id)sender{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [textView_ resignFirstResponder];
   
    if(textView_.text.length > 0){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: textView_.text, @"email", textView_.text, @"content", nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathFeekback parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSLog(@"feedback succeed");
            [self showSuccessModalView:1.5];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }



}

- (void)showSuccessModalView:(int)closeTime
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)];
    view.tag = 3268142;
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    UIImageView *temp = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"success_img"]];
    temp.frame = CGRectMake(0, 0, 324, 191);
    temp.center = view.center;
    [view addSubview:temp];
    [self.view addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:closeTime target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
}

- (void)removeOverlay
{
    UIView *view = (UIView *)[self.view viewWithTag:3268142];
    for(UIView *subview in view.subviews){
        [subview removeFromSuperview];
    }
    [view removeFromSuperview];
    view = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
