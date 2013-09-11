//
//  DeviceListViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "DeviceListViewController.h"
#import "CommonHeader.h"
#import "CustomColoredAccessory.h"

@interface DeviceListViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation DeviceListViewController
@synthesize table;
@synthesize serverArray;
@synthesize delegate;
- (void)viewDidUnload
{
    [super viewDidUnload];
    serverArray = nil;
    table = nil;
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
    self.view.backgroundColor = [UIColor blackColor];
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 230, 230)];
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table.backgroundColor = [UIColor whiteColor];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    
    UILabel *t = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 30)];
    t.font = [UIFont boldSystemFontOfSize:14];
    t.textColor = [UIColor whiteColor];
    t.backgroundColor = [UIColor clearColor];
    t.textAlignment = UITextAlignmentCenter;
    t.text = @"请选择您的设备";
    [t sizeToFit];
    self.navigationItem.titleView = t;
    
//    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];

//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    leftBtn.frame = CGRectMake(5, 5, 30, 30);
//    leftBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//    [leftBtn setBackgroundImage:[UIImage imageNamed:@"pop_up_btn"] forState:UIControlStateNormal];
//    [leftBtn setBackgroundImage:[UIImage imageNamed:@"pop_up_btn_pressed"] forState:UIControlStateHighlighted];
//    [leftBtn addTarget:self action:@selector(leftBarButtonItemClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationController.navigationBar addSubview:leftBtn];
//    
//    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightBtn.frame = CGRectMake(200, 5, 30, 30);
//    rightBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//    [rightBtn setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
//    [rightBtn setBackgroundImage:[UIImage imageNamed:@"refresh_active"] forState:UIControlStateHighlighted];
//    [rightBtn addTarget:self action:@selector(refreshDeviceBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationController.navigationBar addSubview:rightBtn];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return serverArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
//        CustomColoredAccessory *accessory = [CustomColoredAccessory accessoryWithColor:[UIColor blackColor]];
//        accessory.highlightedColor = [UIColor whiteColor];
//        cell.accessoryView.;
        
//        UIButton *deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        deviceBtn.tag = 1201;
//        deviceBtn.frame = CGRectMake(70, 5, 225, 35);
//        deviceBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//        [deviceBtn setBackgroundImage:[UIImage imageNamed:@"device_btn"] forState:UIControlStateNormal];
//        [deviceBtn setBackgroundImage:[UIImage imageNamed:@"device_btnpressed"] forState:UIControlStateHighlighted];
//        [deviceBtn addTarget:self action:@selector(deviceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [deviceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [deviceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
//        deviceBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        [deviceBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
//        [cell addSubview:deviceBtn];
    }
    
//    UIButton *deviceBtn = (UIButton *)[cell viewWithTag:1201];
//    [deviceBtn setTitle:@"Device 1" forState:UIControlStateNormal];
    if (indexPath.row < serverArray.count) {
        NSDictionary *item = [serverArray objectAtIndex:indexPath.row];
        NSString *serverName = [NSString stringWithFormat:@"%@", [item objectForKey:@"deviceName"]];
        if([[AppDelegate instance].dongleServerName isEqualToString:serverName]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = serverName;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (int i = 0; i < serverArray.count; i++) {
        if (i == indexPath.row) {
            UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.accessoryView.backgroundColor = [UIColor blackColor];
            NSDictionary *item = [serverArray objectAtIndex:indexPath.row];
            [[AppDelegate instance] saveServerInfo:item];
        } else {
            UITableViewCell *cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    [delegate closePopupView];
}

- (void)leftBarButtonItemClicked
{
    
}

- (void)refreshDeviceBtnClicked
{
    
}

@end
