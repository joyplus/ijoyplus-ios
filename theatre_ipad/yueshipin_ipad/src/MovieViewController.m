//
//  HomeViewController.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-20.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MovieViewController.h"

@interface MovieViewController ()

@end

@implementation MovieViewController
- (void)viewDidUnload{
    [super viewDidUnload];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    UIButton *sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sortButton addTarget:self action:@selector(sort:) forControlEvents:UIControlEventTouchUpInside];
    sortButton.frame = CGRectMake(420, 50, 70, 27);
    sortButton.backgroundColor = [UIColor clearColor];
    [sortButton setBackgroundImage:[UIImage imageNamed:@"sort_iPad.png"] forState:UIControlStateNormal];
    //[sortButton setImage:[UIImage imageNamed:@"sort_iPad_s.png"] forState:UIControlStateHighlighted];
    [sortButton setBackgroundImage:[UIImage imageNamed:@"sort_iPad_s.png"] forState:UIControlStateSelected];
    sortButton.adjustsImageWhenHighlighted = NO;
    [self.view addSubview:sortButton];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithFrame:(CGRect)frame {
    umengPageName = MOVIE_CATEGORY;
    self.videoType = MOVIE_TYPE;
    self = [super initWithFrame:frame];
	return self;
}

@end
