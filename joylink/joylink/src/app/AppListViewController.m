//
//  GroupImageViewController.m
//  yuexiangjia
//
//  Created by joyplus1 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "AppListViewController.h"
#import "CommonHeader.h"
#import "BrowserViewController.h"
#import "AsyncSocket.h"
#import "JSONKit.h"
#import "MouseRemoteViewController.h"

#define HUD_TAG 1091

@interface AppListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)NSArray *appList;
@property (nonatomic, strong)UITableView *table;
@property (nonatomic, strong)NSMutableArray *imageViewArray;
@property (nonatomic, strong)NSTimer *requstTimer;

@end

@implementation AppListViewController
@synthesize table;;
@synthesize appList;
@synthesize imageViewArray;
@synthesize requstTimer;

- (void)viewDidUnload
{
    [super viewDidUnload];
    table = nil;
    appList = nil;
    [imageViewArray removeAllObjects];
    imageViewArray = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RELOAD_APP_LIST object:nil];
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
    [self addMenuView:-NAVIGATION_BAR_HEIGHT];
    [self addContententView:-NAVIGATION_BAR_HEIGHT];
    [self showMenuBtnForNavController];
    self.title = @"应用程序";
    [self showBackBtnForNavController];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAppList) name:RELOAD_APP_LIST object:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - NAVIGATION_BAR_HEIGHT)];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.backgroundColor = [UIColor clearColor];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    table.showsVerticalScrollIndicator = NO;
    [self addInContentView:table];
    
    imageViewArray = [[NSMutableArray alloc]initWithCapacity:30];
    // load data from Cache first
    appList = [AppDelegate instance].appList;
    // retrieve data from Dongle
    if (appList && appList.count > 0) {
        [self performSelectorInBackground:@selector(prepareImageData) withObject:nil];
    } else {
        [self retrieveAppList];
    }
}

- (void)prepareImageData
{
    for(int i = 0; i < appList.count; i++){
        NSDictionary *app = [appList objectAtIndex:i];
        NSArray *iconArray = [app objectForKey:@"icon"];
        Byte byte[iconArray.count];
        for (int i = 0; i < iconArray.count; i++) {
            NSString *bStr = [iconArray objectAtIndex:i];
            byte[i] = bStr.intValue;
        }
        NSData *imageData = [[NSData alloc] initWithBytes:byte length:sizeof(byte)];
        [imageViewArray addObject:imageData];
        @try {
            UITableViewCell *cell = [table cellForRowAtIndexPath: [NSIndexPath indexPathForRow:floor(i/3.0) inSection:0]];
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:1001 + i % 3];
            imageView.image = [UIImage imageWithData:imageData];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showRefreshBtn];
}

- (void)showRefreshBtn
{
    UIButton *imageBtn = (UIButton *)[self.navigationController.navigationBar viewWithTag:REFRESH_BTN_TAG];
    if (imageBtn == nil) {
        UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        imageBtn.tag = REFRESH_BTN_TAG;
        [imageBtn setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
        [imageBtn setBackgroundImage:[UIImage imageNamed:@"refresh_active"] forState:UIControlStateHighlighted];
        [imageBtn setFrame:CGRectMake(self.view.frame.size.width - 85, 0, NAVIGATION_BAR_HEIGHT, NAVIGATION_BAR_HEIGHT)];
        [imageBtn addTarget:self action:@selector(retrieveAppList)forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addSubview:imageBtn];
    } else {
        [imageBtn setHidden:NO];
    }
}

- (void)reloadAppList
{
    if (requstTimer) {
        [requstTimer invalidate];
        requstTimer = nil;
    }
    appList = [AppDelegate instance].appList;
    if (appList.count > 0) {
        NSArray *iconArray = [[appList objectAtIndex:0] objectForKey:@"icon"];
        if (iconArray.count > 0) {
            [self prepareImageData];
        }
    }
    [self.table reloadData];
    MBProgressHUD *HUD = (MBProgressHUD *)[self.view viewWithTag:HUD_TAG];
    [HUD hide:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceil(appList.count / 3.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        for (int i = 0; i < 3; i++) {
            UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [imageBtn setFrame:CGRectMake(98 * i + (i+1)*10, 10, 65, 65)];
            [imageBtn addTarget:self action:@selector(appImageClicked:)forControlEvents:UIControlEventTouchUpInside];
            imageBtn.tag = 2001 + i;
            [cell.contentView addSubview:imageBtn];
            
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(98 * i + (i+1)*10 + 4, 14, 65, 65)];
            imageView.tag = 1001 + i;
            [cell.contentView addSubview:imageView];
            
            UILabel *nameLabe = [[UILabel alloc]initWithFrame:CGRectMake(imageView.frame.origin.x, 103 - 15, imageView.frame.size.width + 5, 25)];
            nameLabe.tag = 3001 + i;
            nameLabe.font = [UIFont systemFontOfSize:14];
            nameLabe.textAlignment = NSTextAlignmentCenter;
            nameLabe.backgroundColor= [UIColor clearColor];
            nameLabe.textColor = CMConstants.textColor;
            [cell.contentView addSubview:nameLabe];            
        }
    }
    int num = 3;
    if(appList.count < (indexPath.row+1) * 3){
        num = appList.count - indexPath.row * 3;
    }
    for(int i = 0; i < 3; i++){
        UIImageView *imageView  = (UIImageView *)[cell viewWithTag:1001 + i];
        UIButton *imageBtn  = (UIButton *)[cell viewWithTag:2001 + i];
        UILabel *nameLabel  = (UILabel *)[cell viewWithTag:3001 + i];
        if(i < num){
            NSDictionary *app = [appList objectAtIndex:indexPath.row * 3 + i];
            NSData *imageData = nil;
            if (indexPath.row * 3 + i < imageViewArray.count) {
                imageData = [imageViewArray objectAtIndex:indexPath.row * 3 + i];
            }
            if (imageData.length > 0) {
                imageView.image = [UIImage imageWithData:imageData];
            } else {
                imageView.image = [UIImage imageNamed:@"appbg"];
            }
            
            nameLabel.text = [app objectForKey:@"title"];
            [imageView setHidden:NO];
            [imageBtn setHidden:NO];
            [nameLabel setHidden:NO];
        } else {
            [imageView setHidden:YES];
            [imageBtn setHidden:YES];
            [nameLabel setHidden:YES];
        }
    }
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)appImageClicked:(UIButton *)btn
{
    if(![self serverIsConnected]) return;
    CGPoint point = btn.center;
    point = [table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [table indexPathForRowAtPoint:point];
    int index = indexPath.row * 3 + btn.tag - 2001;
    if(index >= appList.count){
        return;
    }
    NSDictionary *app = [appList objectAtIndex:index];
    NSDictionary *sendInfo = [NSDictionary dictionaryWithObjectsAndKeys:[app objectForKey:@"className"], @"className", [app objectForKey:@"packegeName"], @"packegeName", [NSString stringWithFormat:@"%@", [app objectForKey:@"firstInstallTime"]], @"firstInstallTime", [NSString stringWithFormat:@"%@", [app objectForKey:@"flags"]], @"flags", nil];
    if ([@"浏览器" isEqualToString:[app objectForKey:@"title"]]) {
        BrowserViewController *viewController = [[BrowserViewController alloc]init];
        viewController.appInfo = sendInfo;
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        if ([sendInfo isEqualToDictionary:[AppDelegate instance].lastApp]) {
            NSLog(@"The app is started already!");
        } else {
            [[AppDelegate instance] closePreviousApp];
            [[AppDelegate instance] startNewApp:sendInfo];
        }
        RemoteViewController *viewController = [[MouseRemoteViewController alloc]init];
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)backButtonClicked
{
    if (requstTimer) {
        [requstTimer invalidate];
        requstTimer = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)retrieveAppList
{
    if(![self serverIsConnected]) return;
    if (requstTimer) {
        [requstTimer invalidate];
        requstTimer = nil;
    }
    requstTimer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(sendRequest) userInfo:nil repeats:YES];
    [requstTimer fire];
    MBProgressHUD *HUD = (MBProgressHUD *)[self.view viewWithTag:HUD_TAG];
    if (HUD == nil) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
    }
    HUD.tag = HUD_TAG;
    HUD.opacity = 1;
    HUD.labelText = @"加载中...";
    [HUD show:YES];
}

- (void)sendRequest
{
    [imageViewArray removeAllObjects];
    RemoteAction *action = [ActionFactory getMessageAction:SYNC_LAUNCHER_LIST_INFO];
    [action trigger:[CommonMethod getIPAddress]];    
}

@end
