//
//  ListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ClauseViewController.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"

@interface ClauseViewController (){
    UIScrollView *bgScrollView;
    UIImageView *bgImage;
    UIImageView *titleImage;
    UIImageView *contentImage;
}

@end

@implementation ClauseViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    bgImage = nil;
    titleImage = nil;
    contentImage = nil;
    bgScrollView = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    bgImage.image = [UIImage imageNamed:@"detail_bg"];
    [self.view addSubview:bgImage];
    
    bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 520, 720)];
    [bgScrollView setBackgroundColor:[UIColor clearColor]];
    bgScrollView.contentSize = CGSizeMake(420, 850);
    bgScrollView.scrollEnabled = YES;
    bgScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:bgScrollView];
    
    titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(50, 35, 110, 27)];
    titleImage.image = [UIImage imageNamed:@"clause_title"];
    [bgScrollView addSubview:titleImage];
    
    contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(50, 100, 418, 733)];
    contentImage.image = [UIImage imageNamed:@"clause_content"];
    [bgScrollView addSubview:contentImage];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
