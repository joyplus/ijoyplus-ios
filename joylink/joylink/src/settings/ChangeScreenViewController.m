//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ChangeScreenViewController.h"
#import "CommonHeader.h"
#import "ActionFactory.h"
#import "JSONKit.h"

#define HUD_TAG 323548711

@interface ChangeScreenViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSMutableArray *radioButArray;
@property (nonatomic, strong)UITableView *table;
@property (nonatomic, strong)NSArray *screenArray;
@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)NSTimer *requstTimer;
@end

@implementation ChangeScreenViewController
@synthesize radioButArray;
@synthesize table;
@synthesize screenArray;
@synthesize scrollView;
@synthesize requstTimer;
- (void)viewDidUnload
{
    [super viewDidUnload];
    [radioButArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_SCREEN_SETTING object:nil];
    for (UIView *subview in scrollView.subviews) {
        [subview removeFromSuperview];
    }
    scrollView = nil;
    radioButArray = nil;
    table = nil;
    screenArray = nil;
    [requstTimer invalidate];
    requstTimer = nil;
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
    self.title = @"屏幕调整";
    [self showBackBtnForNavController];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background@2x.jpg"]]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshScreen) name:RELOAD_SCREEN_SETTING object:nil];
    
    if ([AppDelegate instance].screenModeInfo == nil) {        
        NSString *ip = [CommonMethod getIPAddress];
        if (![ip isEqualToString:@"error"]) {
            if (requstTimer) {
                [requstTimer invalidate];
                requstTimer = nil;
            }
            requstTimer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(sendRequest:) userInfo:ip repeats:YES];
            [requstTimer fire];
            
            [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(syncScreenScaleInfo:) userInfo:ip repeats:NO];
        }
        MBProgressHUD *HUD = (MBProgressHUD *)[self.view viewWithTag:HUD_TAG];
        if (HUD == nil) {
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
        }
        HUD.tag = HUD_TAG;
        HUD.opacity = 1;
        HUD.labelText = @"加载中...";
        [HUD show:YES];
    } else {
        [self refreshScreen];
    }
}

- (void)sendRequest:(NSTimer *)timer
{
    NSLog(@"send request to get screen info");
    NSString *ip = [timer userInfo];
    RemoteAction *action = [ActionFactory getMessageAction:SYNC_SCREEN_MODE_INFO];
    [action trigger:ip];    
}

- (void)syncScreenScaleInfo:(NSTimer *)timer
{
    NSString *ip = [timer userInfo];
    RemoteAction *action = [ActionFactory getMessageAction:SYNC_SCREEN_SCALE_INFO];
    [action trigger:ip];
}

- (void)refreshScreen
{
    if (requstTimer) {
        [requstTimer invalidate];
        requstTimer = nil;
    }
    screenArray = [[AppDelegate instance].screenModeInfo objectForKey:@"IfaceEntries"];
    if (scrollView == nil && screenArray) {
        MBProgressHUD *HUD = (MBProgressHUD *)[self.view viewWithTag:HUD_TAG];
        [HUD hide:YES];
        scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + screenArray.count * 50)];
        scrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:scrollView];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20,self.view.bounds.size.width-40, 30)];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = CMConstants.textColor;
        headerLabel.font = [UIFont boldSystemFontOfSize:18];
        headerLabel.text =  @"HDMI输出设置";
        [scrollView addSubview:headerLabel];
        
        table = [[UITableView alloc]initWithFrame:CGRectMake(10, headerLabel.frame.origin.y + headerLabel.frame.size.height + 10, self.bounds.size.width - 20, 50 * screenArray.count) style:UITableViewStylePlain];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [table setScrollEnabled:NO];
        table.layer.cornerRadius = 5;
        table.layer.masksToBounds = YES;
        table.backgroundColor = [UIColor clearColor];
        table.delegate = self;
        table.dataSource = self;
        table.tableFooterView = [[UIView alloc]init];
        table.showsVerticalScrollIndicator = NO;
        
        UIView *bgImage = [[UIView alloc]initWithFrame:table.frame];
        bgImage.backgroundColor = [UIColor colorWithRed:172/255.0 green:172/255.0 blue:172/255.0 alpha:0.05];
        bgImage.layer.cornerRadius = 5;
        bgImage.layer.masksToBounds = YES;
        [scrollView addSubview:bgImage];
        
        [scrollView addSubview:table];
        
        UILabel *headerLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(20, table.frame.origin.y + table.frame.size.height + 20,self.view.bounds.size.width-40, 30)];
        headerLabel2.backgroundColor = [UIColor clearColor];
        headerLabel2.textColor = CMConstants.textColor;
        headerLabel2.font = [UIFont boldSystemFontOfSize:18];
        headerLabel2.text =  @"手动调整屏幕";
        [scrollView addSubview:headerLabel2];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(20, headerLabel2.frame.origin.y + headerLabel2.frame.size.height + 30, self.view.frame.size.width - 40, 2)];
        lineView.backgroundColor = CMConstants.textColor;
        lineView.layer.cornerRadius = 5;
        lineView.layer.masksToBounds = YES;
        [scrollView addSubview:lineView];
        
        UIImageView *image2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, lineView.frame.origin.y + lineView.frame.size.height + 30, 265, 77)];
        image2.center = CGPointMake(self.view.center.x, image2.center.y);
        image2.image = [UIImage imageNamed:@"adjust"];
        [scrollView addSubview:image2];
        
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
        UISlider *progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(20, image2.frame.origin.y + image2.frame.size.height + 30, self.bounds.size.width - 40, 10)];
        progressSlider.tag = 9844;
        progressSlider.minimumValue = 0;
        progressSlider.maximumValue = 10.0;
        
        [progressSlider setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        [progressSlider setMinimumTrackImage:minImage  forState:UIControlStateNormal];
        [progressSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        [progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:progressSlider];
    }
    UISlider *progressSlider = (UISlider *)[scrollView viewWithTag:9844];
    if (progressSlider) {
        progressSlider.value = [[[AppDelegate instance].scaleInfo objectForKey:@"progress"] floatValue];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return screenArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.backgroundColor= [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        UIButton *radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [radioButton setBackgroundImage:[UIImage imageNamed:@"radio"] forState:UIControlStateNormal];
        [radioButton setBackgroundImage:[UIImage imageNamed:@"radio_active"] forState:UIControlStateHighlighted];
        radioButton.frame = CGRectMake(250, 5, 40, 40);
        radioButton.tag = 1101;
        [radioButton addTarget:self action:@selector(radioBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:radioButton];
    }
    if (screenArray.count > indexPath.row) {
        if (indexPath.row < screenArray.count - 1) {
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 49, self.bounds.size.width - 40, 1)];
            lineView.backgroundColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1];
            [cell.contentView addSubview:lineView];
        }
        cell.textLabel.text = [screenArray objectAtIndex:indexPath.row];
        NSString *currentModeStr = [[AppDelegate instance].screenModeInfo objectForKey:@"mCurrent_mode_value"];
        if ([cell.textLabel.text isEqualToString:currentModeStr]) {
            UIButton *radioButton = (UIButton *)[cell viewWithTag:1101];
            [radioButton setBackgroundImage:[UIImage imageNamed:@"radio_active"] forState:UIControlStateNormal];
        }
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}



- (void)sliderValueChanged:(UISlider *)progressSlider
{
    NSDictionary *msgDic = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:progressSlider.value], @"progress", [[AppDelegate instance].scaleInfo objectForKey:@"mInterface"], @"mInterface",[[AppDelegate instance].scaleInfo objectForKey:@"mScaleValue"], @"mScaleValue",[[AppDelegate instance].scaleInfo objectForKey:@"maxRangeProgress"], @"maxRangeProgress",[[AppDelegate instance].scaleInfo objectForKey:@"mdisplay"], @"mdisplay",[[AppDelegate instance].scaleInfo objectForKey:@"minScaleValue"],@"minScaleValue", nil];
    NSString *str = [msgDic JSONString];
    RemoteAction *action = [ActionFactory getMessageAction:SET_SCREEN_SCALE];
    [action trigger:str];
}



- (void)radioBtnClicked:(UIButton *)btn
{
    for (int i = 0; i < screenArray.count; i++) {
        UITableViewCell *cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UIButton *tempBtn = (UIButton *)[cell viewWithTag:1101];
        [tempBtn setBackgroundImage:[UIImage imageNamed:@"radio"] forState:UIControlStateNormal];
    }
    [btn setBackgroundImage:[UIImage imageNamed:@"radio_active"] forState:UIControlStateNormal];
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    
    NSArray *array = [[AppDelegate instance].screenModeInfo objectForKey:@"IfaceValue"];
    if (indexPath.row < array.count) {
        NSArray *tempArray = [NSArray arrayWithObject:[array objectAtIndex:indexPath.row]];
        NSDictionary *msgDic = [NSDictionary dictionaryWithObjectsAndKeys:tempArray, @"IfaceValue", [tempArray objectAtIndex:0], @"mCurrent_mode_value", [[AppDelegate instance].screenModeInfo objectForKey:@"mInterface"], @"mInterface",[[AppDelegate instance].screenModeInfo objectForKey:@"mScaleValue"], @"mScaleValue",[[AppDelegate instance].screenModeInfo objectForKey:@"maxRangeProgress"], @"maxRangeProgress",[[AppDelegate instance].screenModeInfo objectForKey:@"mdisplay"], @"mdisplay",[[AppDelegate instance].screenModeInfo objectForKey:@"minScaleValue"],@ "minScaleValue", [[AppDelegate instance].screenModeInfo objectForKey:@"progress"], @"progress", nil];
        NSString *str = [msgDic JSONString];
        RemoteAction *action = [ActionFactory getMessageAction:SET_SCREEN_MODE];
        [action trigger:str];
    }
    
}

- (void)backButtonClicked
{
    if (requstTimer) {
        [requstTimer invalidate];
        requstTimer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
