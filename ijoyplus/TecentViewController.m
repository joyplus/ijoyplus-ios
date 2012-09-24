//
//  TecentViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "TecentViewController.h"
#import "CustomBackButton.h"
#import "CustomBackButtonHolder.h"
#import "FillFormViewController.h"

@interface TecentViewController (){
    TencentOAuth* _tencentOAuth;
    NSMutableArray* _permissions; 
}
- (void)closeSelf;
@end

@implementation TecentViewController

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
    self.title = NSLocalizedString(@"sina_weibo_login", nil);
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _permissions =  [NSArray arrayWithObjects:
					  @"get_user_info",@"add_share", @"add_topic",@"add_one_blog", @"list_album",
					  @"upload_pic",@"list_photo", @"add_album", @"check_page_fans",nil];
	
	
	_tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"100266567"
											andDelegate:self];
	_tencentOAuth.redirectURI = @"www.qq.com";
	self.view = [_tencentOAuth authorize:_permissions inSafari:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tencentDidLogin
{
    FillFormViewController *viewController = [[FillFormViewController alloc]initWithNibName:@"FillFormViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
