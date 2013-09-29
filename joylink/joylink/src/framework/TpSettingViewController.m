//
//  TpSettingViewController.m
//  joylink
//
//  Created by joyplus1 on 13-4-28.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "TpSettingViewController.h"
#import "CommonHeader.h"
#import "TTSwitch.h"

@interface TpSettingViewController ()

@end

@implementation TpSettingViewController

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
	self.title = @"遥控器设置";
    [self showBackBtnForNavController];
    [self removeButtonsOnNavBar];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background@2x.jpg"]]];
    
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * 1.3)];

    [self.view addSubview:scrollView];
    
    int leftWidth = 10;
    
    UILabel *title1 = [[UILabel alloc]initWithFrame:CGRectMake(leftWidth, 5, 280, 30)];
    title1.text = @"触控灵敏度调整";
    title1.textColor = CMConstants.textColor;
    [title1 setBackgroundColor:[UIColor clearColor]];
    [scrollView addSubview:title1];
    
    UIImageView *bg1 = [[UIImageView alloc]initWithFrame:CGRectMake(leftWidth, 35, self.view.frame.size.width - leftWidth*2, 54)];
    bg1.image = [[UIImage imageNamed:@"setting_list1_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [scrollView addSubview:bg1];
    
    UILabel *quick = [[UILabel alloc]initWithFrame:CGRectMake(leftWidth+10, 45, 30, 30)];
    quick.text = @"慢";
    quick.textColor = [UIColor whiteColor];
    quick.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:quick];
    
    // Customizing the UISlider
    UIImage *minImage = [[UIImage imageNamed:@"slider_minimum.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];
    UIImage *maxImage;
    if (ver >= 6.0){
        maxImage = [[UIImage imageNamed:@"slider_maximum.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    } else {
        maxImage = [[UIImage imageNamed:@"slider_maximum.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    }
    UIImage *thumbImage = [UIImage imageNamed:@"thumb.png"];
    
    UISlider *speedSlide = [[UISlider alloc]initWithFrame:CGRectMake(leftWidth + 30, 50, self.view.frame.size.width - (leftWidth + 30) * 2, 10)];
    speedSlide.minimumValue = 1;
    speedSlide.maximumValue = 10;
    speedSlide.value = ((NSString *)[[ContainerUtility sharedInstance] attributeForKey:TOUCH_SCALE]).integerValue;
    [speedSlide setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [speedSlide setMinimumTrackImage:minImage  forState:UIControlStateNormal];
    [speedSlide setThumbImage:thumbImage forState:UIControlStateNormal];
    [speedSlide addTarget:self action:@selector(speedSliderClickUp:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:speedSlide];
    
    UILabel *slow = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - (leftWidth + 30), 45, 30, 30)];
    slow.text = @"快";
    slow.textColor = [UIColor whiteColor];
    slow.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:slow];
    
    UILabel *title2 = [[UILabel alloc]initWithFrame:CGRectMake(leftWidth, 100, 280, 30)];
    title2.text = @"重力传感器设置";
    [title2 setBackgroundColor:[UIColor clearColor]];
    title2.textColor = CMConstants.textColor;
    [scrollView addSubview:title2];
    
    UIImageView *bg2 = [[UIImageView alloc]initWithFrame:CGRectMake(leftWidth, 130, self.view.frame.size.width - leftWidth*2, 100)];
    bg2.image = [[UIImage imageNamed:@"setting_list2_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [scrollView addSubview:bg2];
    
    UILabel *firstOnLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftWidth+10, 140, 200, 30)];
    firstOnLabel.text = @"启用重力感应";
    firstOnLabel.textColor = [UIColor whiteColor];
    firstOnLabel.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:firstOnLabel];
    
    TTSwitch *firstOnSwitch = [[TTSwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - (leftWidth + 30) - 60, 140, 76, 28)];
    [firstOnSwitch setTrackImage:[UIImage imageNamed:@"round-switch-track-onoff"]];
    [firstOnSwitch setOverlayImage:[UIImage imageNamed:@"round-switch-overlay"]];
    [firstOnSwitch setTrackMaskImage:[UIImage imageNamed:@"round-switch-mask"]];
    [firstOnSwitch setThumbImage:[UIImage imageNamed:@"round-switch-thumb"]];
    [firstOnSwitch setThumbHighlightImage:[UIImage imageNamed:@"round-switch-thumb-highlight"]];
    [firstOnSwitch setThumbMaskImage:[UIImage imageNamed:@"round-switch-mask"]];
    [firstOnSwitch setThumbInsetX:-3.0f];
    [firstOnSwitch setThumbOffsetY:-3.0f];
    int turnon = [[NSString stringWithFormat:@"%@", [[ContainerUtility sharedInstance]attributeForKey:TURN_ON_GRAVITY]] integerValue];
    if (turnon == 1) {
        firstOnSwitch.on = YES;
    }
    [firstOnSwitch addTarget:self action:@selector(firstOnSwitchClicked:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:firstOnSwitch];
    
    UILabel *secondOnLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftWidth+10, 185, 200, 30)];
    secondOnLabel.text = @"重力传感器方向";
    secondOnLabel.textColor = [UIColor whiteColor];
    secondOnLabel.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:secondOnLabel];
    
    TTSwitch *secondOnSwitch = [[TTSwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (leftWidth + 30) - 60, 190, 76, 28)];
    [secondOnSwitch setTrackImage:[UIImage imageNamed:@"round-switch-track-lp"]];
    [secondOnSwitch setOverlayImage:[UIImage imageNamed:@"round-switch-overlay"]];
    [secondOnSwitch setTrackMaskImage:[UIImage imageNamed:@"round-switch-mask"]];
    [secondOnSwitch setThumbImage:[UIImage imageNamed:@"round-switch-thumb"]];
    [secondOnSwitch setThumbHighlightImage:[UIImage imageNamed:@"round-switch-thumb-highlight"]];
    [secondOnSwitch setThumbMaskImage:[UIImage imageNamed:@"round-switch-mask"]];
    [secondOnSwitch setThumbInsetX:-3.0f];
    [secondOnSwitch setThumbOffsetY:-3.0f];
    [secondOnSwitch addTarget:self action:@selector(secondOnSwitchClicked:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:secondOnSwitch];
    turnon = [[NSString stringWithFormat:@"%@", [[ContainerUtility sharedInstance]attributeForKey:GRAVITY_DIRECTION]] integerValue];
    if (turnon == 1) {
        secondOnSwitch.on = YES;
    }

    UILabel *thirdLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftWidth, 240, 200, 30)];
    thirdLabel.text = @"重力传感器灵敏度调整";
    thirdLabel.textColor = CMConstants.textColor;
    thirdLabel.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:thirdLabel];
    
    UIImageView *bg3 = [[UIImageView alloc]initWithFrame:CGRectMake(leftWidth, 275, self.view.frame.size.width - leftWidth*2, 54)];
    bg3.image = [[UIImage imageNamed:@"setting_list1_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [scrollView addSubview:bg3];
    
    UILabel *quick1 = [[UILabel alloc]initWithFrame:CGRectMake(leftWidth+10, 285, 30, 30)];
    quick1.text = @"慢";
    quick1.textColor = [UIColor whiteColor];
    quick1.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:quick1];
    
    UISlider *speedSlide1 = [[UISlider alloc]initWithFrame:CGRectMake(leftWidth + 30, 290, self.view.frame.size.width - (leftWidth + 30) * 2, 10)];
    speedSlide1.minimumValue = 1;
    speedSlide1.maximumValue = 10;
    speedSlide1.value = ((NSNumber *)[[ContainerUtility sharedInstance] attributeForKey:GRAVITY_SCALE]).floatValue;
    [speedSlide1 setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [speedSlide1 setMinimumTrackImage:minImage  forState:UIControlStateNormal];
    [speedSlide1 setThumbImage:thumbImage forState:UIControlStateNormal];
    [speedSlide1 addTarget:self action:@selector(sliderClickUp:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:speedSlide1];
    
    UILabel *slow1 = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width - (leftWidth + 30), 285, 30, 30)];
    slow1.text = @"快";
    slow1.textColor = [UIColor whiteColor];
    slow1.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:slow1];
}

- (void)speedSliderClickUp:(UISlider *)slider
{
    [[ContainerUtility sharedInstance] setAttribute:[NSString stringWithFormat:@"%f", slider.value] forKey:TOUCH_SCALE];
    // Don't know what the two input parameters are used for. 
    [AppDelegate instance].touchScale = slider.value;
}

- (void)sliderClickUp:(UISlider *)slider
{
    [[ContainerUtility sharedInstance] setAttribute:[NSNumber numberWithFloat:slider.value] forKey:GRAVITY_SCALE];
}


- (void)firstOnSwitchClicked:(TTSwitch *)secondOnSwitch
{
    if (secondOnSwitch.on) {
        NSLog(@"on");
        [[ContainerUtility sharedInstance] setAttribute:@"1" forKey:TURN_ON_GRAVITY];
    } else {
        NSLog(@"off");
        [[ContainerUtility sharedInstance] setAttribute:@"0" forKey:TURN_ON_GRAVITY];
    }
}

- (void)secondOnSwitchClicked:(TTSwitch *)secondOnSwitch
{
    if (secondOnSwitch.on) {
        NSLog(@"on");
        [[ContainerUtility sharedInstance] setAttribute:@"1" forKey:GRAVITY_DIRECTION];
    } else {
        NSLog(@"off");
        [[ContainerUtility sharedInstance] setAttribute:@"0" forKey:GRAVITY_DIRECTION];
    }
}

- (void)removeButtonsOnNavBar
{
    UIButton *btn1 = (UIButton *)[self.navigationController.navigationBar viewWithTag:SCREENSHOT_BTN_TAG];
    UIButton *btn2 = (UIButton *)[self.navigationController.navigationBar viewWithTag:CLEAR_BTN_TAG];
    UIButton *btn3 = (UIButton *)[self.navigationController.navigationBar viewWithTag:SETTING_BTN_TAG];
    [btn1 removeFromSuperview];
    btn1 = nil;
    [btn2 removeFromSuperview];
    btn2 = nil;
    [btn3 removeFromSuperview];
    btn3 = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
