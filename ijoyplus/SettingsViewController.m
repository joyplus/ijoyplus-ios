//
//  SettingsViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SettingsViewController.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "BlockAlertView.h"
#import "AppDelegate.h"
#import "PopularSegmentViewController.h"
#import "UIUtility.h"

@interface SettingsViewController ()

- (void)closeSelf;
@end

@implementation SettingsViewController
@synthesize firstLabel;
@synthesize secondLabel;
@synthesize logoutBtn;
@synthesize searchFriendBtn;
@synthesize commentBtn;
@synthesize aboutUsBtn;
@synthesize scoreBtn;

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
    self.title = NSLocalizedString(@"settings", nil);
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];

    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.firstLabel.text = NSLocalizedString(@"your_account", nil);
    self.secondLabel.text = NSLocalizedString(@"other_settings", nil);
    [self.logoutBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"logout_user", nil), @"username"] forState:UIControlStateNormal];
    [self.searchFriendBtn setTitle:NSLocalizedString(@"search_add_friend", nil) forState:UIControlStateNormal];
    [self.commentBtn setTitle:NSLocalizedString(@"comment", nil) forState:UIControlStateNormal];

    [self.aboutUsBtn setTitle:NSLocalizedString(@"about_us", nil) forState:UIControlStateNormal];

    [self.scoreBtn setTitle:NSLocalizedString(@"score_app", nil) forState:UIControlStateNormal];

}

- (void)viewDidUnload
{
    [self setFirstLabel:nil];
    [self setSecondLabel:nil];
    [self setLogoutBtn:nil];
    [self setSearchFriendBtn:nil];
    [self setCommentBtn:nil];
    [self setAboutUsBtn:nil];
    [self setScoreBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)logout:(id)sender {
    BlockAlertView *alert = [BlockAlertView alertWithTitle:NSLocalizedString(@"logout_account", nil) message:NSLocalizedString(@"logout_message", nil)];
    
    [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel", nil) block:nil];
    [alert setDestructiveButtonWithTitle:NSLocalizedString(@"logout", nil) block:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.userLoggedIn = NO;
        [appDelegate refreshRootView];
    }];
    [alert show];
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
