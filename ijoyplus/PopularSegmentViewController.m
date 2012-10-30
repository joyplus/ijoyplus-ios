//
//  PopularSegmentViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-12.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PopularSegmentViewController.h"
#import "AnimationFactory.h"
#import "SearchFilmViewController.h"
#import "CustomSegmentedControl.h"
#import "CMConstants.h"
#import "AppDelegate.h"
#import "UIUtility.h"
#import "ContainerUtility.h"
#import "MovieTableViewController.h"
#import "DramaTableViewController.h"
#import "VideoTableViewController.h"
#import "ShowTableViewController.h"

@interface PopularSegmentViewController (){
    MovieTableViewController *movieController;
    DramaTableViewController *dramaController;
    VideoTableViewController *videoController;
    ShowTableViewController  *showController;
    UIViewController *selectedViewController;
}
@property (weak, nonatomic) IBOutlet CustomSegmentedControl *topSegment;
- (void)segmentValueChanged:(id)sender;
//- (void)search;
@end

@implementation PopularSegmentViewController
@synthesize topSegment;

- (void)didReceiveMemoryWarning
{
    NSLog(@"receive memory warning in %@", self.class);
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
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    [UIUtility customizeNavigationBar:self.navigationController.navigationBar];
//    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
//    if([num boolValue]){
//        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"search", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(search)];
//        self.navigationItem.rightBarButtonItem = rightButton;
//    }
    topSegment.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, SEGMENT_HEIGHT_GAP, SEGMENT_WIDTH, SEGMENT_HEIGHT);
    topSegment.selectedSegmentIndex = 0;
    [topSegment setTitle:NSLocalizedString(@"movie", nil) forSegmentAtIndex:0];
    [topSegment setTitle:NSLocalizedString(@"drama", nil) forSegmentAtIndex:1];
    [topSegment setTitle:NSLocalizedString(@"video", nil) forSegmentAtIndex:2];
    [topSegment setTitle:NSLocalizedString(@"local", nil) forSegmentAtIndex:3];
    [topSegment addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    topSegment.layer.shadowColor = [UIColor blackColor].CGColor;
    topSegment.layer.shadowOffset = CGSizeMake(0, 1);
    topSegment.layer.shadowOpacity = 1;
    [self.view addSubview:topSegment];
    movieController = [[MovieTableViewController alloc] initWithNibName:@"MovieTableViewController" bundle:nil];
    selectedViewController = movieController;
    [self addChildViewController:movieController];
    movieController.view.frame = CGRectMake(0, SEGMENT_HEIGHT + SEGMENT_HEIGHT_GAP * 2, self.view.bounds.size.width, self.view.bounds.size.height - SEGMENT_HEIGHT - SEGMENT_HEIGHT_GAP * 2);
    [self.view addSubview:movieController.view];
}

- (void)viewDidUnload
{
    [self setTopSegment:nil];
    movieController = nil;
    dramaController = nil;
    videoController = nil;
    showController = nil;
    selectedViewController = nil;
    [super viewDidUnload];
    topSegment = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)segmentValueChanged:(id)sender {
    if(topSegment.selectedSegmentIndex == 0){
        [selectedViewController.view removeFromSuperview];
        [selectedViewController removeFromParentViewController];
        selectedViewController = nil;
        if(movieController == nil){
            movieController =  [[MovieTableViewController alloc] initWithNibName:@"MovieTableViewController" bundle:nil];
        }
        selectedViewController = movieController;
        [self addChildViewController:movieController];
        movieController.view.frame = CGRectMake(0, SEGMENT_HEIGHT + SEGMENT_HEIGHT_GAP * 2, self.view.bounds.size.width, self.view.bounds.size.height - SEGMENT_HEIGHT - SEGMENT_HEIGHT_GAP * 2);
        [self.view addSubview:movieController.view];
    } else if (topSegment.selectedSegmentIndex == 1){
        [selectedViewController.view removeFromSuperview];
        [selectedViewController removeFromParentViewController];
        selectedViewController = nil;
        if(dramaController == nil){
            dramaController = [[DramaTableViewController alloc] initWithNibName:@"DramaTableViewController" bundle:nil];
        }
        selectedViewController = dramaController;
        [self addChildViewController:dramaController];
        dramaController.view.frame = CGRectMake(0, SEGMENT_HEIGHT + SEGMENT_HEIGHT_GAP * 2, self.view.bounds.size.width, self.view.bounds.size.height - SEGMENT_HEIGHT - SEGMENT_HEIGHT_GAP * 2);
        [self.view addSubview:dramaController.view];
    } else if (topSegment.selectedSegmentIndex == 2){
        [selectedViewController.view removeFromSuperview];
        [selectedViewController removeFromParentViewController];
        selectedViewController = nil;
        if(videoController == nil){
            videoController = [[VideoTableViewController alloc] initWithNibName:@"VideoTableViewController" bundle:nil];
        }
        selectedViewController = videoController;
        [self addChildViewController:videoController];
        videoController.view.frame = CGRectMake(0, SEGMENT_HEIGHT + SEGMENT_HEIGHT_GAP * 2, self.view.bounds.size.width, self.view.bounds.size.height - SEGMENT_HEIGHT - SEGMENT_HEIGHT_GAP * 2);
        [self.view addSubview:videoController.view];
    } else if (topSegment.selectedSegmentIndex == 3){
        [selectedViewController.view removeFromSuperview];
        [selectedViewController removeFromParentViewController];
        selectedViewController = nil;
        if(showController == nil){
            showController = [[ShowTableViewController alloc] initWithNibName:@"ShowTableViewController" bundle:nil];
        }
        selectedViewController = showController;
        [self addChildViewController:showController];
        showController.view.frame = CGRectMake(0, SEGMENT_HEIGHT + SEGMENT_HEIGHT_GAP * 2, self.view.bounds.size.width, self.view.bounds.size.height - SEGMENT_HEIGHT - SEGMENT_HEIGHT_GAP * 2);
        [self.view addSubview:showController.view];
    }
}

@end
