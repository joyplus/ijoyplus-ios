

//
//  DownloadViewController.m
//  yueshipin
//
//  Created by joyplus1 on 12-12-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "DownloadViewController.h"
#import "CommonHeader.h"
#import "DownloadItem.h"
#import "GMGridView.h"
#import "SubdownloadViewController.h"
#import "AFDownloadRequestOperation.h"
#import "AVPlayerViewController.h"
#import "DDProgressView.h"
#import "SegmentUrl.h"
#import "CommonMotheds.h"

@interface DownloadViewController ()<GMGridViewDataSource, GMGridViewActionDelegate, DownloadingDelegate,UIAlertViewDelegate>{
    UIImageView *topImage;
    int leftWidth;
    NSInteger delItemIndex;
    GMGridView * delItem;
    
    UIButton *editBtn;
    UIButton *doneBtn;
    DDProgressView *diskUsedProgress_;
    UILabel *spaceInfoLabel;
    BOOL displayNoSpaceFlag;
    __gm_weak GMGridView *_gmGridView;
    BOOL isItunesFile;
    NSInteger retryConut;
}

@property (nonatomic, strong)NSArray *allDownloadItems;
- (void)deleteItemWithIndex:(NSInteger)index;
@end

@implementation DownloadViewController
@synthesize allDownloadItems;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    topImage = nil;
    _gmGridView = nil;
    spaceInfoLabel = nil;
    diskUsedProgress_ = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_DISK_STORAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateDownloadView" object:nil];
    
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    retryConut = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDiskStorage) name:UPDATE_DISK_STORAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNoEnoughSpace) name:NO_ENOUGH_SPACE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDownloadView) name:@"updateDownloadView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDiskStorage) name:APPLICATION_DID_BECOME_ACTIVE_NOTIFICATION object:nil];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    } else if([NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]){
        return NO;
    } else {
        for (int i = 0; i < allDownloadItems.count; i++) {
            CGPoint pt = [touch locationInView:self.view];
            GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
            CGPoint ptInbtn = [self.view convertPoint:pt toView:cell];
            BOOL inor = [cell pointInside:ptInbtn withEvent:nil];
            if (inor) {
                return inor;
            }
        }
        return YES;
    }
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        leftWidth = 15;
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(leftWidth, 40, 260, 42)];
        topImage.image = [UIImage imageNamed:@"download_title"];
        [self.view addSubview:topImage];
        
        editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        editBtn.frame = CGRectMake(380, 25, 100, 75);
        [editBtn setBackgroundImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        [editBtn setBackgroundImage:[UIImage imageNamed:@"edit_pressed"] forState:UIControlStateHighlighted];
        [editBtn addTarget:self action:@selector(editBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:editBtn];
        
        doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = editBtn.frame;
        [doneBtn setBackgroundImage:[UIImage imageNamed:@"finish"] forState:UIControlStateNormal];
        [doneBtn setBackgroundImage:[UIImage imageNamed:@"finish_pressed"] forState:UIControlStateHighlighted];
        [doneBtn addTarget:self action:@selector(doneBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [doneBtn setHidden:YES];
        [self.view addSubview:doneBtn];
        
        [self reloadItems];
        GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 90, 490, 600)];
        gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        gmGridView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:gmGridView];
        _gmGridView = gmGridView;
        
        NSInteger spacing = 10;
        _gmGridView.style = GMGridViewStyleSwap;
        _gmGridView.itemSpacing = spacing;
        _gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
        _gmGridView.centerGrid = NO;
        _gmGridView.actionDelegate = self;
        _gmGridView.dataSource = self;
        _gmGridView.mainSuperView = self.view;
        
        UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(10, self.view.frame.size.height - 75, self.view.frame.size.width- 30, 53)];
        spaceView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:spaceView];
        
        UIImageView *downalodBgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, spaceView.frame.size.width, spaceView.frame.size.height)];
        downalodBgImage.image = [[UIImage imageNamed:@"download_progress_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
        [spaceView addSubview:downalodBgImage];
        
        UIImageView *diskFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, spaceView.frame.size.width - 30, 28)];
        diskFrame.image = [[UIImage imageNamed:@"download_progress"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        diskFrame.center = CGPointMake(spaceView.frame.size.width/2, spaceView.frame.size.height/2);
        [spaceView addSubview:diskFrame];
        
        diskUsedProgress_ = [[DDProgressView alloc] initWithFrame:CGRectMake(0, 0, spaceView.frame.size.width - 26, 32)];
        diskUsedProgress_.center = CGPointMake(spaceView.frame.size.width/2, spaceView.frame.size.height/2 - 1);
        diskUsedProgress_.innerColor = [UIColor colorWithRed:248/255.0 green:148/255.0 blue:48/255.0 alpha:1];
        diskUsedProgress_.outerColor = [UIColor clearColor];
        [spaceView addSubview:diskUsedProgress_];
        
        spaceInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 25)];
        spaceInfoLabel.textAlignment = NSTextAlignmentCenter;
        spaceInfoLabel.backgroundColor = [UIColor clearColor];
        spaceInfoLabel.font = [UIFont systemFontOfSize:12];
        spaceInfoLabel.textColor = [UIColor whiteColor];
        spaceInfoLabel.center = CGPointMake(spaceView.frame.size.width/2, spaceView.frame.size.height/2);
        [spaceView addSubview:spaceInfoLabel];
        
        [self updateDiskStorage];
        delItemIndex = NSNotFound;
    }
    return self;
}

- (void)updateDiskStorage
{
    float percent = [self getFreeDiskspacePercent];
    diskUsedProgress_.progress = percent;
    spaceInfoLabel.text = [NSString stringWithFormat:@"剩余: %0.2fGB / 总空间: %0.2fGB",totalFreeSpace_, totalSpace_];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _gmGridView.editing = NO;
    [AppDelegate instance].padDownloadManager.delegate = self;
    [self reloadItems];
    [MobClick beginLogPageView:DOWNLOAD];
    [self updateDiskStorage];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [AppDelegate instance].padDownloadManager.delegate = [AppDelegate instance].padDownloadManager;
    [editBtn setHidden:NO];
    [doneBtn setHidden:YES];
    displayNoSpaceFlag = NO;
    [self updateDiskStorage];
    [MobClick endLogPageView:DOWNLOAD];
}

- (void)reloadItems
{
    isItunesFile = NO;
    if (![[AppDelegate instance].showVideoSwitch isEqualToString:@"0"]){
        isItunesFile = YES;
        allDownloadItems = [NSMutableArray arrayWithArray:[self getItunesSyncItems]];
    }
    else{
        allDownloadItems = [DatabaseManager allObjects:DownloadItem.class];
    }
    
    
    if (allDownloadItems.count == 0) {
        [editBtn setHidden:YES];
    } else {
        [editBtn setHidden:NO];
    }
    [_gmGridView reloadData];
}

-(NSArray *)getItunesSyncItems{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:5];
    NSError *error;
    // 创建文件管理器
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //指向文件目录
    NSString *documentsDirectory= [NSHomeDirectory()
                                   stringByAppendingPathComponent:@"Documents"];
    NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
    for (NSString *item in fileList) {
        if ([item hasSuffix:@"mp4"]) {
            DownloadItem *tempDbObj = [[DownloadItem alloc]init];
            tempDbObj.itemId =  @"0";
            tempDbObj.name = [[item componentsSeparatedByString:@"."] objectAtIndex:0];
            tempDbObj.fileName = [[item componentsSeparatedByString:@"."] objectAtIndex:0];
            tempDbObj.downloadStatus = @"done";
            tempDbObj.type = 1;
            tempDbObj.percentage = 100;
            tempDbObj.downloadType = @"mp4";
            [arr addObject:tempDbObj];
        }
    }
    return arr;
}

- (void)downloadFailure:(NSString *)operationId error:(NSError *)error
{
    NSLog(@"error in DownloadViewController");
    
    if (![CommonMotheds isNetworkEnbled])
    {
        NSLog(@"网络异常");
        return;
    }
    
    NSInteger retryNum = 0;
    if ([[AppDelegate instance].padDownloadManager.retryCountInfo objectForKey:operationId])
    {
        retryNum = [[[AppDelegate instance].padDownloadManager.retryCountInfo objectForKey:operationId] intValue];
    }
    
    if (retryNum <= DOWNLOAD_FAIL_RETRY_TIME)
    {
        retryNum ++;
        [[AppDelegate instance].padDownloadManager.retryCountInfo setObject:[NSString stringWithFormat:@"%d",retryNum] forKey:operationId];
        //[self stopDownloading];
        [self performSelector:@selector(restartNewDownloading) withObject:nil afterDelay:DOWNLOAD_FAIL_RETRY_INTERVAL];
    }
    else
    {
        [[AppDelegate instance].padDownloadManager.retryCountInfo setObject:@"0" forKey:operationId];
        DownloadItem * dlItem = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", operationId]];
        dlItem.downloadStatus = @"fail";
        [DatabaseManager update:dlItem];
        [[AppDelegate instance].padDownloadManager stopDownloading];
        [[AppDelegate instance].padDownloadManager startDownloadingThreads];
        
        [_gmGridView reloadData];
    }
}

- (void)restartNewDownloading
{
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [AppDelegate instance].currentDownloadingNum = 0;
        [NSThread  detachNewThreadSelector:@selector(startDownloadingThreads) toTarget:[AppDelegate instance].padDownloadManager withObject:nil];
    }
}

- (void)downloadSuccess:(NSString *)operationId
{
    DownloadItem * item = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", operationId]];
    item.downloadStatus = @"done";
    item.percentage = 100;
    [DatabaseManager update:item];
    
    [_gmGridView reloadData];
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
    [self updateDiskStorage];
}

- (void)updateProgress:(NSString *)operationId progress:(float)progress
{
    [[AppDelegate instance].padDownloadManager.retryCountInfo setObject:@"0" forKey:operationId];
    for (int i = 0; i < allDownloadItems.count; i++) {
        DownloadItem *item = [allDownloadItems objectAtIndex:i];
        if (item.type == 1 && [item.itemId isEqualToString:operationId]) {
            item = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", item.itemId]];
            int thisProgress = progress * 100;
            if (thisProgress < 1 && item.percentage != 0) {
                item.percentage = 0;
                [DatabaseManager update:item];
            }
            if (thisProgress- item.percentage > 5) {
                NSLog(@"percent in DownloadViewController= %f", progress);
                item.percentage = thisProgress;
                [DatabaseManager update:item];
                [self updateDiskStorage];
            }
            GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
            UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:operationId.intValue + 20000000];
            if(progressView != nil){
                progressView.progress = progress;
                UILabel *progressLabel = (UILabel *)[cell viewWithTag:operationId.intValue + 10000000];
                progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%", (int)(progress*100)];
            }
            break;
            
        }
    }
    [self getFreeDiskspacePercent];
    if (totalFreeSpace_ <= LEAST_DISK_SPACE) {
        if (!displayNoSpaceFlag) {
            [ActionUtility triggerSpaceNotEnough];
        }
        [_gmGridView reloadData];
    }
}

- (void)movieImageClicked:(NSInteger)index
{
    //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    if(index >= allDownloadItems.count){
        return;
    }
    GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:index];
    DownloadItem *item = [allDownloadItems objectAtIndex:index];
    item = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", item.itemId]];
    UILabel *progressLabel = (UILabel *)[cell.contentView viewWithTag:item.itemId.intValue + 10000000];
    UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:item.itemId.intValue + 20000000];
    item.percentage = (int)(progressView.progress*100);
    if([item.downloadStatus isEqualToString:@"start"] || [item.downloadStatus isEqualToString:@"waiting"]){
        if ([item.downloadStatus isEqualToString:@"start"]) {
            [[AppDelegate instance].padDownloadManager stopDownloading];
            [AppDelegate instance].currentDownloadingNum --;//0
        }
        progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%", (int)(progressView.progress*100)];
        item.downloadStatus = @"stop";
        [DatabaseManager update:item];
    } else if([item.downloadStatus isEqualToString:@"stop"] || [item.downloadStatus isEqualToString:@"fail"]){
        [self getFreeDiskspacePercent];
        if (totalFreeSpace_ <= LEAST_DISK_SPACE) {
            [UIUtility showNoSpace:self.view];
            return;
        }
        progressLabel.text = [NSString stringWithFormat:@"等待中：%i%%", (int)(progressView.progress*100)];
        item.downloadStatus = @"waiting";
        [DatabaseManager update:item];
    }
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
    [self reloadItems];
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return allDownloadItems.count;
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView
{
    return CGSizeMake(110, 165);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    if(index >= allDownloadItems.count){
        return nil;
    }
    CGSize size = [self sizeForItemsInGMGridView:gridView];
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-10, -10);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor clearColor];
        cell.contentView = view;
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    DownloadItem *item = [allDownloadItems objectAtIndex:index];
    if (!isItunesFile) {
        item = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", item.itemId]];
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 105, 146)];
    imageView.image = [UIImage imageNamed:@"video_bg_placeholder"];
    [cell.contentView addSubview:imageView];
    
    UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(imageView.frame.origin.x + 6, imageView.frame.origin.y + 8, imageView.frame.size.width - 12, imageView.frame.size.height - 12)];
    [contentImage setImageWithURL:[NSURL URLWithString:item.imageUrl]];
    [cell.contentView addSubview:contentImage];
    
    if (item.type == 1) {
        UILabel *bgLabel = [[UILabel alloc]initWithFrame:CGRectMake(contentImage.frame.origin.x, contentImage.frame.origin.y + contentImage.frame.size.height - 40, contentImage.frame.size.width, 40)];
        bgLabel.tag = item.itemId.intValue + 30000000;
        bgLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        if(![item.downloadStatus isEqualToString:@"done"]){
            [cell.contentView addSubview:bgLabel];
        }
        
        UILabel *progressLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        progressLabel.tag = item.itemId.intValue + 10000000;
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.font = [UIFont boldSystemFontOfSize:13];
        progressLabel.textColor = [UIColor whiteColor];
        if([item.downloadStatus isEqualToString:@"start"]){
            progressLabel.frame = CGRectMake(13, 110, 98, 25);
            progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%", item.percentage];
        } else if([item.downloadStatus isEqualToString:@"stop"]){
            progressLabel.frame = CGRectMake(13, 110, 98, 25);
            progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%", item.percentage];
        } else if([item.downloadStatus isEqualToString:@"done"] || item.percentage == 100){
            //            progressLabel.text = @"下载完成";
        } else if([item.downloadStatus isEqualToString:@"waiting"]){
            progressLabel.frame = CGRectMake(13, 110, 98, 25);
            progressLabel.text = [NSString stringWithFormat:@"等待中：%i%%", item.percentage];
        } else if([item.downloadStatus isEqualToString:@"error"]){
            progressLabel.frame = CGRectMake(13, 117, 98, 25);
            progressLabel.text = @"下载片源失效";
        } else if ([item.downloadStatus isEqualToString:@"fail"]){
            progressLabel.frame = CGRectMake(13, 117, 98, 25);
            progressLabel.text = @"下载失败";
        }
        
        progressLabel.textAlignment = NSTextAlignmentCenter;
        progressLabel.shadowColor = [UIColor blackColor];
        progressLabel.shadowOffset = CGSizeMake(1, 1);
        if(![item.downloadStatus isEqualToString:@"done"]){
            [cell.contentView addSubview:progressLabel];
        }
        
        if([item.downloadStatus isEqualToString:@"start"] || [item.downloadStatus isEqualToString:@"stop"] || [item.downloadStatus isEqualToString:@"waiting"]){
            UIProgressView *progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(17, 135, 90, 5)];
            progressView.progress = item.percentage/100.0;
            progressView.tag = item.itemId.intValue + 20000000;
            [cell.contentView addSubview:progressView];
        }
    }
    else
    {
        NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",item.itemId];
        NSArray *arr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
        UILabel *labeltotal = [[UILabel alloc] initWithFrame:CGRectMake(16, 128, 92, 25)];
        labeltotal.text = [NSString stringWithFormat:@"共%d集",[arr count]];
        labeltotal.textColor = [UIColor whiteColor];
        labeltotal.textAlignment = NSTextAlignmentCenter;
        labeltotal.backgroundColor = [UIColor blackColor];
        labeltotal.alpha = 0.6;
        labeltotal.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:labeltotal];
    }
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(14, 150, 105, 30)];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textColor = CMConstants.textColor;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = [NSString stringWithFormat:@"%@", item.name];
    nameLabel.center = CGPointMake(imageView.center.x, nameLabel.center.y);
    [cell.contentView addSubview:nameLabel];
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index
{
    delItemIndex = index;
    delItem = gridView;
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"是否确认删除所选视频"
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                           otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)removeLastPlaytime:(DownloadItem *)item
{
    NSString *key;
    if (item.type == 1) {
        key = item.itemId;
    } else {
        key = [NSString stringWithFormat:@"%@_%@", item.itemId, ((SubdownloadItem *)item).name];
    }
    [[CacheUtility sharedCache] putInCache:key result:[NSNumber numberWithInt:0]];
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    if(position < allDownloadItems.count){
        DownloadItem *item = [allDownloadItems objectAtIndex:position];
        if (!isItunesFile) {
            item = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", item.itemId]];
        }
        
        if([item.downloadStatus isEqualToString:@"done"] && item.type == 1){
            NSString *filePath;
            if ([item.downloadType isEqualToString:@"m3u8"]) {
                filePath = [NSString stringWithFormat:@"%@/%@/%@.m3u8", LOCAL_HTTP_SERVER_URL, item.itemId, item.itemId];
            } else {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                if (isItunesFile) {
                    filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.mp4", item.fileName]];
                }
                else{
                    filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.mp4", item.itemId]];
                }
                
            }
            AVPlayerViewController *viewController = [[AVPlayerViewController alloc]init];
            viewController.videoFormat = item.downloadType;
            viewController.isDownloaded = YES;
            viewController.m3u8Duration = item.duration;
            viewController.closeAll = YES;
            viewController.videoUrl = filePath;
            viewController.type = 1;
            viewController.name = item.name;
            viewController.prodId = item.itemId;
            viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 768);
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [[AppDelegate instance].rootViewController pesentMyModalView:viewController];
        } else {
            if(item.type == 1){
                if (![item.downloadStatus hasPrefix:@"error"]) {
                    [self movieImageClicked:position];
                }
                [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider];
            } else {
                SubdownloadViewController *viewController = [[SubdownloadViewController alloc] initWithFrame:CGRectMake(0, 0, RIGHT_VIEW_WIDTH, self.view.bounds.size.height)];
                viewController.parentDelegate = self;
                viewController.titleContent = item.name;
                viewController.itemId = item.itemId;
                [[AppDelegate instance].rootViewController.stackScrollViewController addViewInSlider:viewController invokeByController:self isStackStartView:FALSE removePreviousView:YES];
            }
        }
    }
}

- (void)editBtnClicked
{
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:self.class];
    _gmGridView.editing = YES;
    [editBtn setHidden:YES];
    [doneBtn setHidden:NO];
}

- (void)doneBtnClicked
{
    _gmGridView.editing = NO;
    [editBtn setHidden:NO];
    [doneBtn setHidden:YES];
}

- (void)showNoEnoughSpace
{
    [UIUtility showNoSpace:self.view];
}

- (void)deleteItemWithIndex:(NSInteger)index
{
    DownloadItem *item = [allDownloadItems objectAtIndex:index];
    if (!isItunesFile) {
        item = (DownloadItem *)[DatabaseManager findFirstByCriteria:DownloadItem.class queryString:[NSString stringWithFormat:@"where itemId = %@", item.itemId]];
    }
    
    if ([item.downloadStatus isEqualToString:@"start"]) {
        [[AppDelegate instance].padDownloadManager stopDownloading];
    }
    [self removeLastPlaytime:item];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:DocumentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        if(item.type == 1){
            if ([filename hasPrefix:[NSString stringWithFormat:@"%@.mp4", item.itemId]]) {
                [fileManager removeItemAtPath:[DocumentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            }
        } else {
            if ([filename hasPrefix:[NSString stringWithFormat:@"%@_", item.itemId]]) {
                [fileManager removeItemAtPath:[DocumentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            }
        }
    }
    NSString *filePath = nil;
    if (isItunesFile) {
        filePath = [NSString stringWithFormat:@"%@/%@.mp4", DocumentsDirectory, item.fileName];
    }
    else{
        filePath = [NSString stringWithFormat:@"%@/%@", DocumentsDirectory, item.itemId];
    }
    
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    NSArray *tempsubitems = [DatabaseManager findByCriteria:SubdownloadItem.class queryString:[NSString stringWithFormat:@"WHERE itemId = %@", item.itemId]];
    for (SubdownloadItem *subitem in tempsubitems) {
        if ([subitem.downloadStatus isEqualToString:@"start"]) {
            [[AppDelegate instance].padDownloadManager stopDownloading];
        }
        [self removeLastPlaytime:subitem];
    }
    [DatabaseManager performSQLAggregation:[NSString stringWithFormat:@"delete from SubdownloadItem WHERE itemId = %@", item.itemId]];
    [DatabaseManager deleteObject:item];
    if ([ActionUtility getStartItemNumber] == 0) {
        [AppDelegate instance].currentDownloadingNum = 0;
    }
    allDownloadItems = [DatabaseManager allObjects:DownloadItem.class];
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
    if (allDownloadItems.count == 0) {
        [editBtn setHidden:YES];
        [doneBtn setHidden:YES];
    }
    [self updateDiskStorage];
}

- (void)refreshDownloadView
{
    [_gmGridView reloadData];
}

#pragma mark -
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        if (NSNotFound == delItemIndex)
        {
            return;
        }
        [delItem removeObjectAtIndex:delItemIndex];
        [self deleteItemWithIndex:delItemIndex];
    }
}

@end
