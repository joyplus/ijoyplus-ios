//
//  PathViewController.m
//  RaisedCenterTabBar
//
//  Created by Peter Boctor on 12/15/10.
//
// Copyright (c) 2011 Peter Boctor
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//

#import "BottomTabViewController.h"
#import "UIImageView+WebCache.h"
#import "FriendViewController.h"
#import "HomeViewController.h"
#import "MyselfViewController.h"
#import "PopularSegmentViewController.h"
#import "SearchFilmViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "UIUtility.h"
#import "CMConstants.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ContainerUtility.h"
#import "SearchFriendViewController.h"
#import "MessageListViewController.h"
#import "BlockAlertView.h"
#import "WBEngine.h"
#import "CacheUtility.h"
#import "SFHFKeychainUtils.h"


@interface BottomTabViewController (){
    PopularSegmentViewController *detailController1;
    FriendViewController *detailController2;
    HomeViewController *detailController3;
    MyselfViewController *detailController4;
    UIToolbar *bottomToolbar;
    UIBarButtonItem *rightButton;
}
- (void)initTabControllers;
- (void)search;
- (void)settings;
- (void)message;
- (void)searchFriend;
- (void)loginScreen;
- (void)registerScreen;
- (void)initToolBar;
- (UINavigationController*) addNavigation:(UIViewController*) rootViewController;
@end

@implementation BottomTabViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"receive memory warning in %@", self.class);
}

- (void)viewDidUnload {
    [super viewDidUnload];
    rightButton = nil;
    detailController1 = nil;
    detailController2 = nil;
    detailController3 = nil;
    detailController4 = nil;
    bottomToolbar = nil;
}

- (id)init {
    if ((self = [super init])) {
    }
    self.delegate = self;
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    [self initView];
    [self initTabControllers];
    self.viewControllers = [NSArray arrayWithObjects: detailController1, detailController2, detailController4,detailController3, nil];
    [self setSelectedIndex:0];
    
}

- (void) initView
{
    rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"search", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(search)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.tabBar setHidden:NO];
    self.title = NSLocalizedString(@"app_name", nil);
    [self setSelectedIndex:0];
}

- (void)initTabControllers
{
    if(detailController1 == nil){
        detailController1 = [[PopularSegmentViewController alloc] initWithNibName:@"PopularSegmentViewController" bundle:nil];
        detailController1.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"popular", nil)  image:[UIImage imageNamed:@"pop_tab"] tag:0];
    }
    
    detailController2 = [[FriendViewController alloc] init];
    detailController2.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"friend", nil) image:[UIImage imageNamed:@"rec_tab"] tag:1];
    
    detailController3 = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    detailController3.userid = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserId];
    detailController3.offsety = TAB_BAR_HEIGHT;
    detailController3.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"list", nil) image:[UIImage imageNamed:@"my_tab"] tag:2];
    
    detailController4 = [[MyselfViewController alloc]initWithNibName:@"MyselfViewController" bundle:nil];
    detailController4.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"myself", nil) image:[UIImage imageNamed:@"list_tab"] tag:3];
}

-(UINavigationController*) addNavigation:(UIViewController*) rootViewController
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    rootViewController.navigationItem.titleView = [UIUtility customizeAppTitle];
    return navController;
}

#pragma mark - Tab bar delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass: [FriendViewController class]] || [viewController isKindOfClass:[MyselfViewController class]] || [viewController isKindOfClass:[HomeViewController class]]) {
        NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
        if(![num boolValue]){
            [[WBEngine sharedClient] logOut];
            NSString *username = (NSString *)[[ContainerUtility sharedInstance] attributeForKey:kUserName];
            [SFHFKeychainUtils deleteItemForUsername:username andServiceName:kUserLoginService error:nil];
            [[CacheUtility sharedCache] clear];
            [[ContainerUtility sharedInstance] clear];
        }
    }
    if([viewController isKindOfClass:[PopularSegmentViewController class]]){
        rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"search", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(search)];
        self.navigationItem.rightBarButtonItem = rightButton;
        self.title = NSLocalizedString(@"app_name", nil);
    } else {
        NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
        if(![num boolValue]){
            [self loginScreen];
            return NO;
        }
        if ([viewController isKindOfClass: [FriendViewController class]]){
            rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"search_friend", nil) style:UIBarButtonSystemItemAction target:self action:@selector(searchFriend)];
            self.navigationItem.rightBarButtonItem = rightButton;
            self.title = NSLocalizedString(@"friend", nil);
        } else if ([viewController isKindOfClass: [HomeViewController class]]){
            rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"settings", nil) style:UIBarButtonSystemItemAction target:self action:@selector(settings)];
            self.navigationItem.rightBarButtonItem = rightButton;
            self.title = NSLocalizedString(@"list", nil);
        } else if ([viewController isKindOfClass: [MyselfViewController class]]){
            rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"message", nil) style:UIBarButtonSystemItemAction target:self action:@selector(message)];
            self.navigationItem.rightBarButtonItem = rightButton;
            self.title = NSLocalizedString(@"myself", nil);
        }
    }
    return YES;
}

- (void)search
{
    SearchFilmViewController *viewController = [[SearchFilmViewController alloc]initWithNibName:@"SearchFilmViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self presentViewController:navController animated:YES completion:nil];
    //    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //    [appDelegate.window.rootViewController presentModalViewController:navController animated:YES];
}

- (void)settings
{
    SettingsViewController *viewController = [[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
    ////    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    //    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;
    ////    [appDelegate.window.rootViewController presentModalViewController:navController animated:YES];
    //    [navController pushViewController:viewController animated:YES];
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentModalViewController:navController animated:YES];
    
}

- (void)searchFriend
{
    SearchFriendViewController *viewController = [[SearchFriendViewController alloc]initWithNibName:@"SearchFriendViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentModalViewController:navController animated:YES];
}

- (void)message
{
    MessageListViewController *viewController = [[MessageListViewController alloc]initWithNibName:@"MessageListViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentModalViewController:navController animated:YES];
}

- (void)initToolBar
{
    bottomToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - TAB_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - SEGMENT_HEIGHT + 9, self.view.frame.size.width, TAB_BAR_HEIGHT)];
    [UIUtility customizeToolbar:bottomToolbar];
    //    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    [registerBtn setFrame:CGRectMake(MOVIE_LOGO_WIDTH_GAP, 5, LOG_BTN_WIDTH, LOG_BTN_HEIGHT)];
    //    [registerBtn setTitle:NSLocalizedString(@"register", nil) forState:UIControlStateNormal];
    //    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [registerBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    //    [UIUtility addTextShadow:registerBtn.titleLabel];
    //    registerBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    //    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    //    [registerBtn setBackgroundImage:[[UIImage imageNamed:@"reg_btn_normal"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
    //    [registerBtn setBackgroundImage:[[UIImage imageNamed:@"reg_btn_active"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    //    [registerBtn addTarget:self action:@selector(registerScreen)forControlEvents:UIControlEventTouchUpInside];
    //    [bottomToolbar addSubview:registerBtn];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [loginBtn setFrame:CGRectMake(MOVIE_LOGO_WIDTH_GAP, 5, LOG_BTN_WIDTH * 2, LOG_BTN_HEIGHT)];
    [loginBtn setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [UIUtility addTextShadow:loginBtn.titleLabel];
    loginBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [loginBtn setBackgroundImage:[[UIImage imageNamed:@"log_btn_normal"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[[UIImage imageNamed:@"log_btn_active"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [loginBtn addTarget:self action:@selector(loginScreen)forControlEvents:UIControlEventTouchUpInside];
    bottomToolbar.layer.zPosition = 1;
    [bottomToolbar addSubview:loginBtn];
}

- (void)loginScreen
{
    LoginViewController *viewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}


- (void)registerScreen
{
    RegisterViewController *viewController = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
}

- (void)closeChild
{
    [self dismissModalViewControllerAnimated:YES];
    [self initView];
    [self initTabControllers];
    self.viewControllers = [NSArray arrayWithObjects: detailController1, detailController2, detailController4,detailController3, nil];
    [self setSelectedIndex:0];
}

@end
