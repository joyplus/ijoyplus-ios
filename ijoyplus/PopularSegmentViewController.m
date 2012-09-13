//
//  PopularSegmentViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-12.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PopularSegmentViewController.h"
#import "MovieViewController.h"
#import "LoginViewController.h"
#import "AnimationFactory.h"
#import "SearchFilmViewController.h"
#import "RegisterViewController.h"
#import "CustomSegmentedControl.h"
#import "DramaViewController.h"
#import "VideoViewController.h"
#import "LocalViewController.h"

@interface PopularSegmentViewController (){
    MovieViewController *movieController;
    DramaViewController *dramaController;
    VideoViewController *videoController;
    LocalViewController *localController;
    UIViewController *selectedViewController;
}
@property (strong, nonatomic) IBOutlet CustomSegmentedControl *topSegment;
- (void)segmentValueChanged:(id)sender;
- (void)search;
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
    [UIUtility customizeNavigationBar:self.navigationController.navigationBar];
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
    [topSegment addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:topSegment];
    movieController = [[MovieViewController alloc] init];
    selectedViewController = movieController;
    movieController.view.backgroundColor = [UIColor whiteColor];
    [self addChildViewController:movieController];
    movieController.view.frame = CGRectMake(0, SEGMENT_HEIGHT + SEGMENT_HEIGHT_GAP * 2, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.view addSubview:movieController.view];
}

- (void)viewDidUnload
{
    [self setTopSegment:nil];
    [super viewDidUnload];
    topSegment = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)segmentValueChanged:(id)sender {
    if(topSegment.selectedSegmentIndex == 0){
        [selectedViewController.view removeFromSuperview];
        [selectedViewController removeFromParentViewController];
        if(movieController == nil){
            movieController = [[MovieViewController alloc] init];
        }
        selectedViewController = movieController;
        movieController.view.backgroundColor = [UIColor whiteColor];
        [self addChildViewController:movieController];
        movieController.view.frame = CGRectMake(0, SEGMENT_HEIGHT + SEGMENT_HEIGHT_GAP * 2, self.view.bounds.size.width, self.view.bounds.size.height);
        [self.view addSubview:dramaController.view];    } else if (topSegment.selectedSegmentIndex == 1){
        [selectedViewController.view removeFromSuperview];
        [selectedViewController removeFromParentViewController];
        if(dramaController == nil){
            dramaController = [[DramaViewController alloc] init];
        }
        selectedViewController = dramaController;
        dramaController.view.backgroundColor = [UIColor whiteColor];
        [self addChildViewController:dramaController];
        dramaController.view.frame = CGRectMake(0, SEGMENT_HEIGHT + SEGMENT_HEIGHT_GAP * 2, self.view.bounds.size.width, self.view.bounds.size.height);
        [self.view addSubview:dramaController.view];
    } else if (topSegment.selectedSegmentIndex == 2){
        [selectedViewController.view removeFromSuperview];
        [selectedViewController removeFromParentViewController];
        if(videoController == nil){
            videoController = [[VideoViewController alloc] init];
        }
        selectedViewController = videoController;
        videoController.view.backgroundColor = [UIColor whiteColor];
        [self addChildViewController:videoController];
        videoController.view.frame = CGRectMake(0, SEGMENT_HEIGHT + SEGMENT_HEIGHT_GAP * 2, self.view.bounds.size.width, self.view.bounds.size.height);
        [self.view addSubview:videoController.view];
    } else if (topSegment.selectedSegmentIndex == 3){
        [selectedViewController.view removeFromSuperview];
        [selectedViewController removeFromParentViewController];
        if(localController == nil){
            localController = [[LocalViewController alloc] init];
        }
        selectedViewController = localController;
        localController.view.backgroundColor = [UIColor whiteColor];
        [self addChildViewController:localController];
        localController.view.frame = CGRectMake(0, SEGMENT_HEIGHT + SEGMENT_HEIGHT_GAP * 2, self.view.bounds.size.width, self.view.bounds.size.height);
        [self.view addSubview:localController.view];
    }
    [self viewWillAppear:YES];
}

- (void)search
{
    SearchFilmViewController *viewController = [[SearchFilmViewController alloc]initWithNibName:@"SearchFilmViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentModalViewController:navController animated:YES];
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
