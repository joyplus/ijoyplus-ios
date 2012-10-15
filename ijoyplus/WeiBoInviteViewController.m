//
//  FriendDetailViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "WeiBoInviteViewController.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "UIImageView+WebCache.h"
#import "UIUtility.h"
#import "CMConstants.h"
#import "WBEngine.h"
#import "MBProgressHUD.h"

@interface WeiBoInviteViewController ()

@end

@implementation WeiBoInviteViewController
@synthesize avatarImageView;
@synthesize titleLabel;
@synthesize subtitleNameLabel;
@synthesize titleNameLabel;
@synthesize descriptionLabel;
@synthesize submitBtn;
@synthesize friendInfo;

- (void)viewDidUnload
{
    [self setAvatarImageView:nil];
    [self setTitleLabel:nil];
    [self setSubtitleNameLabel:nil];
    [self setTitleNameLabel:nil];
    [self setDescriptionLabel:nil];
    [self setSubmitBtn:nil];
    self.friendInfo = nil;
    [super viewDidUnload];
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
    self.title = NSLocalizedString(@"friend_detail", nil);
    self.titleNameLabel.text = @"昵称：";
    self.titleLabel.text = [friendInfo objectForKey:@"screen_name"];
    self.subtitleNameLabel.text = [friendInfo objectForKey:@"description"];
    self.descriptionLabel.text = [NSString stringWithFormat:@"您的好友 %@ 还未加入悦+，您可以：", [friendInfo objectForKey:@"screen_name"]];
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:[friendInfo objectForKey:@"profile_image_url"]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    self.avatarImageView.layer.cornerRadius = 27.5;
    self.avatarImageView.layer.masksToBounds = YES;
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.submitBtn setTitle:NSLocalizedString(@"weibo_invite", nil) forState:UIControlStateNormal];
    [self.submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.submitBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [UIUtility addTextShadow:submitBtn.titleLabel];
    [self.submitBtn setBackgroundImage:[[UIImage imageNamed:@"log_btn_normal"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [self.submitBtn setBackgroundImage:[[UIImage imageNamed:@"log_btn_active"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    self.submitBtn.layer.cornerRadius = 10;
    self.submitBtn.layer.masksToBounds = YES;
    self.submitBtn.layer.zPosition = 1;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitBtnClicked:(id)sender {
    [[WBEngine sharedClient] sendWeiBoWithText: [NSString stringWithFormat: NSLocalizedString(@"weibo_invite_template", nil), [friendInfo objectForKey:@"screen_name"]] image:nil];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = NSLocalizedString(@"invite_success", nil);
    [HUD showWhileExecuting:@selector(postSuccess) onTarget:self withObject:nil animated:YES];
}

- (void)postSuccess
{
    sleep(1.5);
    [self performSelectorOnMainThread:@selector(closeSelf) withObject:nil waitUntilDone:YES];
}

@end
