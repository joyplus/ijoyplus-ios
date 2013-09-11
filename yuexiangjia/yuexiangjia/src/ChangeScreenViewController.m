//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ChangeScreenViewController.h"
#import "CommonHeader.h"


@interface ChangeScreenViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *table;
@property (nonatomic, strong)NSMutableArray *radioButArray;
@end

@implementation ChangeScreenViewController
@synthesize table;
@synthesize radioButArray;

- (void)viewDidUnload
{
    [super viewDidUnload];
    table = nil;
    [radioButArray removeAllObjects];
    radioButArray = nil;
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
    [self.navigationItem setHidesBackButton:YES];
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-NAVIGATION_BAR_HEIGHT-TOOLBAR_HEIGHT-20) style:UITableViewStyleGrouped];
    table.backgroundView = nil;
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.showsVerticalScrollIndicator = NO;
    [self.view addSubview:table];
    
    radioButArray = [[NSMutableArray alloc]initWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        UIButton *radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [radioButton setBackgroundImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
        [radioButton setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateHighlighted];
        radioButton.frame = CGRectMake(250, 10, 40, 40);
        radioButton.tag = 1101 + i;
        [radioButton addTarget:self action:@selector(radioBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [radioButArray addObject:radioButton];
    }
    [super showToolbar:NAVIGATION_BAR_HEIGHT];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = CMConstants.textGreyColor;
    }
    switch (indexPath.section) {
        case 0:
        {
            UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 65, 50)];
            label1.textColor = CMConstants.textGreyColor;
            label1.backgroundColor = [UIColor clearColor];
            label1.textAlignment = NSTextAlignmentCenter;
            label1.font = [UIFont boldSystemFontOfSize:17];
            label1.layer.borderColor = [UIColor lightGrayColor].CGColor;
            label1.layer.borderWidth = 1;
            label1.layer.cornerRadius = 5;
            label1.layer.masksToBounds = YES;
            
            UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(80, 5, 180, 50)];
            label2.textColor = CMConstants.textGreyColor;
            label2.font = [UIFont boldSystemFontOfSize:16];
            label2.backgroundColor = [UIColor clearColor];
            if (indexPath.row == 0) {
                label1.text = @"1080p";
                label2.text = @"频率：50 Hz";
            } else if(indexPath.row == 1){
                label1.text = @"720p";
                label2.text = @"频率：60 Hz";
            } else if(indexPath.row == 2){
                label1.text = @"576p";
                label2.text = @"频率：50 Hz";
            }
            if (indexPath.row >= 0 && indexPath.row < 3) {
                [cell.contentView addSubview:[radioButArray objectAtIndex:indexPath.row]];
            }
            [cell.contentView addSubview:label1];
            [cell.contentView addSubview:label2];
            break;
        }
        case 1:
        {
            UIImageView *image1 = [[UIImageView alloc]initWithFrame:CGRectMake(40, 20, 64, 45)];
            image1.image = [UIImage imageNamed:@"tv_pic_small"];
            [cell.contentView addSubview:image1];
            
            UIImageView *image2 = [[UIImageView alloc]initWithFrame:CGRectMake(170, 15, 87, 55)];
            image2.image = [UIImage imageNamed:@"tv_pic_big"];
            [cell.contentView addSubview:image2];
            
            UISlider *progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(20, 90, self.bounds.size.width - 60, 10)];
            progressSlider.minimumValue = 0;
            progressSlider.maximumValue = 1.0;
            progressSlider.value = 0.5;
            [progressSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:progressSlider];
        }
        default:
            break;
    }
    return cell;
}

- (void)sliderValueChanged
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    } else {
        return 130;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
        case 1:
            return 40;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 30)];
    customView.backgroundColor = [UIColor clearColor];
    
    // create the label objects
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,self.view.bounds.size.width-10, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = CMConstants.textGreyColor;
    headerLabel.font = [UIFont boldSystemFontOfSize:15];
    if(section == 0){
        headerLabel.text =  @"HDMI输出设置";
    } else {
        headerLabel.text =  @"手动调整屏幕";
    }
    [customView addSubview:headerLabel];
    
    return customView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return nil;
    }
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 40)];
    customView.backgroundColor = [UIColor clearColor];
    
    // create the label objects
    UITextView *label = [[UITextView alloc] initWithFrame:CGRectMake(5,0,self.view.bounds.size.width-10, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = CMConstants.textGreyColor;
    label.font = [UIFont boldSystemFontOfSize:12];
    label.text =  @"如悦享TV的显示区域与您的电视屏幕不能完整匹配（过大或过小），您可以通过滑动滑块进行匹配。";
    [customView addSubview:label];
    
    return customView;
}

- (void)radioBtnClicked:(UIButton *)btn
{
    for (UIButton *tempBtn in radioButArray) {
        [tempBtn setBackgroundImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    }
    [btn setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
