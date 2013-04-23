//
//  AppRecommendViewController.m
//  yueshipin
//
//  Created by 08 on 13-2-5.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "AppRecommendViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CMConstants.h"
#import "UMUFPGridCell.h"
#import "GridViewCellDemo.h"
@interface AppRecommendViewController ()

@end

@implementation AppRecommendViewController
@synthesize mGridView = _mGridView;

static int NUMBER_OF_COLUMNS = 3;
static int NUMBER_OF_APPS_PERPAGE = 18;
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
	// Do any additional setup after loading the view.
    self.title = @"精品推荐";
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 49, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    bg.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:bg];
    
//    UIImageView *appRecommedV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 109, 24)];
//    appRecommedV.image = [UIImage imageNamed:@"jing_pin_tui_jian.png"];
//    [self.view addSubview:appRecommedV];
    
    _mGridView = [[UMUFPGridView alloc] initWithFrame:CGRectMake(10, 24,300, kCurrentWindowHeight -34) appkey:umengAppKey slotId:nil currentViewController:self];
    [_mGridView setBackgroundColor:[UIColor clearColor]];
    _mGridView.datasource = self;
    _mGridView.delegate = self;
    _mGridView.dataLoadDelegate = (id<GridViewDataLoadDelegate>)self;
    _mGridView.autoresizesSubviews = NO;
    _mGridView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [_mGridView requestPromoterDataInBackground];
    
    [self.view addSubview:_mGridView];
    
}
-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
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
- (CGFloat)gridView:(UMUFPGridView *)gridView heightForRowAtIndexPath:(IndexPath *)indexPath
{
    return 100.0f;
}

- (void)gridView:(UMUFPGridView *)gridView didSelectRowAtIndexPath:(IndexPath *)indexPath
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    int arrIndex = [gridView arrayIndexForIndexPath:indexPath];
    if (arrIndex < [_mGridView.mPromoterDatas count])
    {
        NSDictionary *promoter = [_mGridView.mPromoterDatas objectAtIndex:arrIndex];
        NSString *url = [promoter valueForKey:@"url"];
        NSLog(@"%@", url);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
