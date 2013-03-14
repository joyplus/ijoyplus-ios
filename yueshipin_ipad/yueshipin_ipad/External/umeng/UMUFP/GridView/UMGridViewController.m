//
//  UMIconListViewController.m
//  UFP
//
//  Created by liu yu on 7/23/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "UMGridViewController.h"
#import "UMUFPImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "CMConstants.h"
#import "AppDelegate.h"
#import "UMUFPGridCell.h"
#import "GridViewCellDemo.h"

@interface UMGridViewController (){
    UIImageView *topImage;
    UIButton *closeBtn;
    UIView *backgroundView;
    UIImageView *bgImage;
}
@end

@implementation UMGridViewController

static int NUMBER_OF_COLUMNS = 3;
static int NUMBER_OF_APPS_PERPAGE = 18;

- (void)viewDidUnload
{
    [super viewDidUnload];
    closeBtn = nil;
    _mGridView.delegate = nil;
    _mGridView.datasource = nil;
    _mGridView.dataLoadDelegate = nil;
    _mGridView = nil;
}

- (NSString*)resolutionString
{
    NSString * resolution;
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
		resolution = [NSString stringWithFormat:@"%d x %d",(int)([[UIScreen mainScreen] bounds].size.height*[UIScreen mainScreen].scale),(int)([[UIScreen mainScreen] bounds].size.width*[UIScreen mainScreen].scale)];
	}else
    {
		resolution = [NSString stringWithFormat:@"%d x %d",(int)[[UIScreen mainScreen] bounds].size.height,(int)[[UIScreen mainScreen] bounds].size.width];
	}
    
    return resolution;
}

- (void)updateNumberOfColumns:(UIInterfaceOrientation)orientation
{
//    NSString *resolution = [self resolutionString];
//    
//    if (UIInterfaceOrientationIsLandscape(orientation))
//    {
//        if ([resolution isEqualToString:@"1136 x 640"])
//        {
//            NUMBER_OF_COLUMNS = 6;
//        }
//        else
//        {
//            NUMBER_OF_COLUMNS = 5;
//        }
//    }
//    else
//    {
//        NUMBER_OF_COLUMNS = 3;
//    }
//    
//    if ([resolution isEqualToString:@"1136 x 640"])
//    {
//        NUMBER_OF_APPS_PERPAGE = 18;
//    }
//    else
//    {
//        NUMBER_OF_APPS_PERPAGE = 30;
//    }
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        [backgroundView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:backgroundView];
        
        bgImage = [[UIImageView alloc]initWithFrame:backgroundView.frame];
        bgImage.image = [UIImage imageNamed:@"left_background"];
        [backgroundView addSubview:bgImage];
        
        [self.view addSubview:menuBtn];
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(80, 40, 197, 34)];
        topImage.image = [UIImage imageNamed:@"title_recommond"];
        [self.view addSubview:topImage];
        self.view.autoresizesSubviews = YES;
        
        UIApplication *application = [UIApplication sharedApplication];
        [self updateNumberOfColumns:application.statusBarOrientation];
        
        _mGridView = [[UMUFPGridView alloc] initWithFrame:CGRectMake(LEFT_WIDTH - 10, 115, self.view.frame.size.width - LEFT_WIDTH*2, self.view.frame.size.height-145) appkey:umengAppKey slotId:nil currentViewController:self];
        [_mGridView setBackgroundColor:[UIColor clearColor]];
        _mGridView.datasource = self;
        _mGridView.delegate = self;
        _mGridView.dataLoadDelegate = (id<GridViewDataLoadDelegate>)self;
        _mGridView.autoresizesSubviews = NO;
        _mGridView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [_mGridView requestPromoterDataInBackground];
        
        [self.view addSubview:_mGridView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:swipeCloseMenuRecognizer];
    [self.view addGestureRecognizer:openMenuRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([AppDelegate instance].closed) {
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
    } else {
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn_pressed"] forState:UIControlStateNormal];
    }
    [_mGridView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    
    [self updateNumberOfColumns:interfaceOrientation];
    
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    
    CGRect frame = self.navigationController.navigationBar.frame;
    _mGridView.frame = CGRectMake(0, frame.size.height, size.width, size.height - frame.size.height);
}

#pragma mark GridViewDataSource

- (NSInteger)numberOfColumsInGridView:(UMUFPGridView *)gridView{
    
    return NUMBER_OF_COLUMNS;
}

- (NSInteger)numberOfAppsPerPage:(UMUFPGridView *)gridView
{
    return NUMBER_OF_APPS_PERPAGE;
}

- (UIView *)gridView:(UMUFPGridView *)gridView cellForRowAtIndexPath:(IndexPath *)indexPath{
    
    GridViewCellDemo *view = [[GridViewCellDemo alloc] initWithIdentifier:nil];
    
    return view;
}

-(void)gridView:(UMUFPGridView *)gridView relayoutCellSubview:(UIView *)view withIndexPath:(IndexPath *)indexPath{
    
    int arrIndex = [gridView arrayIndexForIndexPath:indexPath];
    if (arrIndex < [_mGridView.mPromoterDatas count])
    {
        NSDictionary *promoter = [_mGridView.mPromoterDatas objectAtIndex:arrIndex];
        
        GridViewCellDemo *imageViewCell = (GridViewCellDemo *)view;
        imageViewCell.indexPath = indexPath;
        imageViewCell.titleLabel.text = [promoter valueForKey:@"title"];
        
        [imageViewCell.imageView setImageURL:[NSURL URLWithString:[promoter valueForKey:@"icon"]]];
    }
}

#pragma mark GridViewDelegate

- (CGFloat)gridView:(UMUFPGridView *)gridView heightForRowAtIndexPath:(IndexPath *)indexPath
{
    return 100.0f;
}

- (void)gridView:(UMUFPGridView *)gridView didSelectRowAtIndexPath:(IndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)UMUFPGridViewDidLoadDataFinish:(UMUFPGridView *)gridView promotersAmount:(NSInteger)promotersAmount
{
    NSLog(@"%s, %d", __PRETTY_FUNCTION__, promotersAmount);
    
    [gridView reloadData];
}

- (void)UMUFPGridView:(UMUFPGridView *)gridView didLoadDataFailWithError:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end