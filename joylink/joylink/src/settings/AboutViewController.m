//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "AboutViewController.h"
#import "CommonHeader.h"
#import "ActionFactory.h"
#import "JSONKit.h"

#define HUD_TAG 323548711

@interface AboutViewController ()
@end

@implementation AboutViewController

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.title = @"关于我们";
    [self showBackBtnForNavController];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background@2x.jpg"]]];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 80, 161, 53)];
    imageView.image = [UIImage imageNamed:@"about"];
    imageView.center = CGPointMake(self.view.center.x, imageView.center.y);
    [self.view addSubview:imageView];
    
    UILabel *version = [[UILabel alloc]initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 40)];
    version.text = @"版本号: 1.0.0";
    version.font = [UIFont systemFontOfSize:18];
    version.textAlignment = UITextAlignmentCenter;
    version.textColor = CMConstants.textColor;
    version.backgroundColor = [UIColor clearColor];
    [self.view addSubview:version];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 350, self.view.frame.size.width, 40)];
    label.text = @"上海志精网络科技有限公司";
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = CMConstants.textColor;
    label.backgroundColor = [UIColor clearColor];
    [self.view addSubview:label];
    
}

- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
