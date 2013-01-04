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
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }



}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
