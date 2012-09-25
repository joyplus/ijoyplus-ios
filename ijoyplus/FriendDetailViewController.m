//
//  FriendDetailViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "FriendDetailViewController.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "UIImageView+WebCache.h"
#import "UIUtility.h"
#import "CMConstants.h"

@interface FriendDetailViewController ()

@end

@implementation FriendDetailViewController
@synthesize avatarImageView;
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize subtitleNameLabel;
@synthesize titleNameLabel;
@synthesize descriptionLabel;
@synthesize submitBtn;
@synthesize submitBtnClicked;

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
    self.titleNameLabel.text = @"姓 名：";
    self.subtitleNameLabel.text = @"手 机：";
    self.descriptionLabel.text = @"XXX还未加入悦+，您可以：";
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    self.avatarImageView.layer.cornerRadius = 27.5;
    self.avatarImageView.layer.masksToBounds = YES;
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.submitBtn setTitle:NSLocalizedString(@"sms_invite", nil) forState:UIControlStateNormal];
    [self.submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.submitBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [UIUtility addTextShadow:submitBtn.titleLabel];
    [self.submitBtn setBackgroundImage:[[UIImage imageNamed:@"log_btn_normal"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [self.submitBtn setBackgroundImage:[[UIImage imageNamed:@"log_btn_active"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    self.submitBtn.layer.cornerRadius = 10;
    self.submitBtn.layer.masksToBounds = YES;
    self.submitBtn.layer.zPosition = 1;
}

- (void)viewDidUnload
{
    [self setAvatarImageView:nil];
    [self setTitleLabel:nil];
    [self setSubtitleLabel:nil];
    [self setSubtitleNameLabel:nil];
    [self setTitleNameLabel:nil];
    [self setDescriptionLabel:nil];
    [self setSubmitBtn:nil];
    [self setSubmitBtnClicked:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
