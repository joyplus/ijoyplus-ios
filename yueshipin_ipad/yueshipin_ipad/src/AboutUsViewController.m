//
//  ListViewController.m
//  yueshipin_ipad
//
//  Created by zhang zhipeng on 12-11-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "AboutUsViewController.h"
#import "MovieDetailViewController.h"
#import "DramaDetailViewController.h"
#import "ShowDetailViewController.h"

@interface AboutUsViewController (){
    UIImageView *bgImage;
    UIImageView *titleImage;
    UIImageView *contentImage;
}

@end

@implementation AboutUsViewController

- (void)viewDidUnload
{
    [super viewDidUnload];
    bgImage = nil;
    titleImage = nil;
    contentImage = nil;
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
    
    titleImage = [[UIImageView alloc]initWithFrame:CGRectMake(50, 35, 104, 27)];
    titleImage.image = [UIImage imageNamed:@"about_title"];
    [self.view addSubview:titleImage];
    
    contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(50, 90, 453, 642)];
    contentImage.image = [UIImage imageNamed:@"about_content"];
    [self.view addSubview:contentImage];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
