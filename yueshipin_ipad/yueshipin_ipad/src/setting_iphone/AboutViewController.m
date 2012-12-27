//
//  ViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(37, 28, 240, 25)];
    label1.text = [NSString stringWithFormat:@"  志精网络科技洞察消费者视频娱乐消费习惯变革的趋势，致力于成为家庭娱乐分享的引擎。"];
    label1.lineBreakMode = UILineBreakModeWordWrap;
    label1.numberOfLines = 0;
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(37, 58, 240, 12)];
    label2.text = [NSString stringWithFormat:@"使命：分享生活和爱的乐趣"];
    label2.lineBreakMode = UILineBreakModeWordWrap;
    label2.numberOfLines = 0;
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(37, 85, 240, 12)];
    label3.text = [NSString stringWithFormat:@"愿景：成为家庭娱乐分享引擎"];
    label3.lineBreakMode = UILineBreakModeWordWrap;
    label3.numberOfLines = 0;
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(37, 115, 240, 25)];
    label4.text = [NSString stringWithFormat:@"宗旨：嫁接起移动屏幕和大屏幕的娱乐应用桥梁；体验极富乐趣的家庭互动娱乐生活；"];
    label4.lineBreakMode = UILineBreakModeWordWrap;
    label4.numberOfLines = 0;
    
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(37, 162, 240, 25)];
    label5.text = [NSString stringWithFormat:@"企业文化：先行与恒持－－行业先导与使命必达实现多屏合一智能化高效监播体系"];
    label5.lineBreakMode = UILineBreakModeWordWrap;
    label5.numberOfLines = 0;
    
    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(130, 210, 180, 25)];
    label6.text = [NSString stringWithFormat:@"分享与共荣－－高效沟通与利益共享\n激情与守信－－阳光心境与信誉为先"];
    label6.lineBreakMode = UILineBreakModeWordWrap;
    label6.numberOfLines = 0;
    
    UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(37, 264, 240, 12)];
    label7.text = [NSString stringWithFormat:@"口号：Enjoy sharing life 看你想看"];
    label7.lineBreakMode = UILineBreakModeWordWrap;
    label7.numberOfLines = 0;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(98, 300, 124, 78)];
    [self.view addSubview:label1];
    [self.view addSubview:label2];
    [self.view addSubview:label3];
    [self.view addSubview:label4];
    [self.view addSubview:label5];
    [self.view addSubview:label6];
    [self.view addSubview:label7];
    [self.view addSubview:imageView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
