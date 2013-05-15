//
//  ChannelViewController.m
//  theatreiphone
//
//  Created by Rong on 13-5-13.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ChannelViewController.h"
@interface ChannelViewController ()

@end

@implementation ChannelViewController
@synthesize titleButton = titleButton_;
@synthesize segV = _segV;
@synthesize videoTypeSeg = _videoTypeSeg;
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
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:backGround];
    
    titleButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton_.frame = CGRectMake(0, 0, 90, 60);
    titleButton_.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [titleButton_ setTitle:@"电影" forState:UIControlStateNormal];
    [titleButton_ setTitle:@"电影" forState:UIControlStateHighlighted];
    [titleButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [titleButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    titleButton_.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [titleButton_ setTitleShadowColor:[UIColor colorWithRed:121.0/255 green:64.0/255 blue:0 alpha:1]forState:UIControlStateNormal];
    [titleButton_ setTitleShadowColor:[UIColor colorWithRed:121.0/255 green:64.0/255 blue:0 alpha:1]forState:UIControlStateHighlighted];
    [titleButton_ addTarget:self action:@selector(setSegmentControl) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleButton_;
    
    _segV = [[SegmentControlView alloc] initWithFrame:CGRectMake(0, 0, 320, 42)];
    [self.view addSubview:_segV];
    
    _videoTypeSeg = [[VideoTypeSegment alloc] initWithFrame:CGRectMake(0, 0, 320, 65)];
    _videoTypeSeg.delegate = self;
    _videoTypeSeg.hidden = YES;
    [self.view addSubview: _videoTypeSeg];
}

//VideoTypeSegmentDelegate
-(void)segmentDidSelectedAtIndex:(int)index{
    typeSelectIndex_ = index;
}


-(void)setSegmentControl{
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
