//
//  PopularSegmentViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-12.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PopularSegmentViewController.h"
#import "PopularViewController.h"
#import "PopularTabViewController.h"
#import "PopularViewController.h"
#import "UIGlossyButton.h"
#import "CMConstants.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "AnimationFactory.h"
#import "SearchFilmViewController.h"
#import "RegisterViewController.h"
#import "CustomSegmentedControl.h"
#import "UIUtility.h"

@interface PopularSegmentViewController (){
    PopularViewController *detailController1;
}
@property (strong, nonatomic) IBOutlet CustomSegmentedControl *topSegment;
- (void)segmentClicked:(id)sender;
- (void)search;
- (void)addToolBar;
- (void)registerScreen;
- (void)loginScreen;
@end

@implementation PopularSegmentViewController
@synthesize topSegment;

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
    self.title = NSLocalizedString(@"app_name", nil);
    self.navigationController.navigationBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.8;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if(appDelegate.userLoggedIn){
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"search", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(search)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    topSegment.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, SEGMENT_HEIGHT_GAP, SEGMENT_WIDTH, SEGMENT_HEIGHT);
    topSegment.selectedSegmentIndex = 0;
    [topSegment setTitle:NSLocalizedString(@"movie", nil) forSegmentAtIndex:0];
    [topSegment setTitle:NSLocalizedString(@"drama", nil) forSegmentAtIndex:1];
    [topSegment setTitle:NSLocalizedString(@"video", nil) forSegmentAtIndex:2];
    [topSegment setTitle:NSLocalizedString(@"local", nil) forSegmentAtIndex:3];
    [topSegment addTarget:self action:@selector(segmentClicked:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:topSegment];
    detailController1 = [[PopularViewController alloc] init];
    detailController1.view.backgroundColor = [UIColor whiteColor];
    [self addChildViewController:detailController1];
    detailController1.view.frame = CGRectMake(0, SEGMENT_HEIGHT + SEGMENT_HEIGHT_GAP * 2, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:detailController1.view];
}

- (void)viewDidUnload
{
    [self setTopSegment:nil];
    [super viewDidUnload];
    topSegment = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)segmentClicked:(id)sender {
    if(topSegment.selectedSegmentIndex == 0){
        [self addChildViewController:detailController1];
        [self.view addSubview:detailController1.view];
//        CATransition *animation = [AnimationFactory pushToRippleAnimation:^{
            detailController1.view.frame = CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height);
//        }];
//        [[self.view layer] addAnimation:animation forKey:@"animation"];
    } else {
        [detailController1.view removeFromSuperview];
        [detailController1 removeFromParentViewController];
        UIViewController *detailController2 = [[UIViewController alloc] init];
        detailController2.view.backgroundColor = [UIColor redColor];
        [self.view addSubview:detailController2.view];
        [self addChildViewController:detailController2];
//        CATransition *animation = [AnimationFactory pushToRippleAnimation:^{
            detailController2.view.frame = CGRectMake(0, 40, self.view.bounds.size.width, self.view.bounds.size.height);
//        }];
//        [[self.view layer] addAnimation:animation forKey:@"animation"];
    }
    [self viewWillAppear:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if(!appDelegate.userLoggedIn){
        [self addToolBar];
    }
}

- (void)search
{
    SearchFilmViewController *viewController = [[SearchFilmViewController alloc]initWithNibName:@"SearchFilmViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentModalViewController:navController animated:YES];
}

- (void)addToolBar
{
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - TAB_BAR_HEIGHT, self.view.frame.size.width, TAB_BAR_HEIGHT)];
    [UIUtility customizeToolbar:toolBar];
    UIGlossyButton *registerBtn = [[UIGlossyButton alloc] initWithFrame:CGRectMake(2, 2, self.view.frame.size.width/2-1, TAB_BAR_HEIGHT-3)];
    [registerBtn setActionSheetButtonWithColor: CMConstants.greyColor];
    registerBtn.buttonBorderWidth = 0;
    [registerBtn setTitle: NSLocalizedString(@"register", nil) forState:UIControlStateNormal];
    registerBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [registerBtn addTarget:self action:@selector(registerScreen) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:registerBtn];
    
    UIGlossyButton *loginBtn = [[UIGlossyButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 + 2, 2, self.view.frame.size.width/2 - 4, TAB_BAR_HEIGHT-3)];
    [loginBtn setActionSheetButtonWithColor: CMConstants.greyColor];
    loginBtn.buttonBorderWidth = 0;
    [loginBtn setTitle: NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    loginBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [loginBtn addTarget:self action:@selector(loginScreen) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:loginBtn];
    
    [self.view addSubview:toolBar];
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

@end
