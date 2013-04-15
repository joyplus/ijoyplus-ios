//
//  DownloadViewController.m
//  yueshipin
//
//  Created by joyplus1 on 12-12-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SubdownloadViewController.h"
#import "CommonHeader.h"
#import "SubdownloadItem.h"
#import "GMGridView.h"
#import "AVPlayerViewController.h"
#import "AFDownloadRequestOperation.h"
#import "SegmentUrl.h"

@interface SubdownloadViewController ()<SubdownloadingDelegate, GMGridViewDataSource, GMGridViewActionDelegate>{
    UIButton *closeBtn;
    UILabel *titleLabel;
    int leftWidth;
    NSArray *subitems;
    
    UIButton *editBtn;
    UIButton *doneBtn;;
    BOOL displayNoSpaceFlag;
    __gm_weak GMGridView *_gmGridView;
}
@end

@implementation SubdownloadViewController
@synthesize itemId;
@synthesize parentDelegate;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    subitems = nil;
    _gmGridView = nil;
    closeBtn = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addGestureRecognizer:self.swipeRecognizer];
    [self reloadSubitems];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:CMConstants.backgroundColor];
        
        titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(LEFT_WIDTH, 35, 377, 30)];
        titleLabel.font = [UIFont boldSystemFontOfSize:23];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = CMConstants.titleBlueColor;
        titleLabel.layer.shadowColor = [UIColor colorWithRed:141/255.0 green:182/255.0 blue:213/255.0 alpha:1].CGColor;
        titleLabel.layer.shadowOffset = CGSizeMake(1, 1);
        [self.view addSubview:titleLabel];
        
        closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(456, 0, 50, 50);
        [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [closeBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
        [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeBtn];
        
        editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        editBtn.frame = CGRectMake(410, 80, 74, 26);
        [editBtn setBackgroundImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        [editBtn setBackgroundImage:[UIImage imageNamed:@"edit_pressed"] forState:UIControlStateHighlighted];
        [editBtn addTarget:self action:@selector(editBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:editBtn];
        
        doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = editBtn.frame;
        [doneBtn setBackgroundImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
        [doneBtn setBackgroundImage:[UIImage imageNamed:@"done_pressed"] forState:UIControlStateHighlighted];
        [doneBtn addTarget:self action:@selector(doneBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [doneBtn setHidden:YES];
        [self.view addSubview:doneBtn];
        
        GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(LEFT_WIDTH, 110, 450, 610)];
        gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        gmGridView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:gmGridView];
        _gmGridView = gmGridView;
        
        NSInteger spacing = 30;
        _gmGridView.style = GMGridViewStyleSwap;
        _gmGridView.itemSpacing = spacing;
        _gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
        _gmGridView.centerGrid = NO;
        _gmGridView.actionDelegate = self;
        _gmGridView.dataSource = self;
        _gmGridView.mainSuperView = self.view;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AppDelegate instance].padDownloadManager.subdelegate = self;
    titleLabel.text = self.titleContent;
    _gmGridView.editing = NO;
    [editBtn setHidden:NO];
    [doneBtn setHidden:YES];
    [self reloadSubitems];
    [_gmGridView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    displayNoSpaceFlag = NO;
    [AppDelegate instance].padDownloadManager.subdelegate = [AppDelegate instance].padDownloadManager;
}

- (void)reloadSubitems
{
    NSArray *tempSubitems = [DatabaseManager findByCriteria:SubdownloadItem.class queryString:[NSString stringWithFormat:@"WHERE itemId = %@", self.itemId]];
    subitems = [tempSubitems sortedArrayUsingComparator:^(SubdownloadItem *a, SubdownloadItem *b) {
        NSNumber *first =  [NSNumber numberWithInt:a.subitemId.intValue];
        NSNumber *second = [NSNumber numberWithInt:b.subitemId.intValue];
        return [first compare:second];
    }];
}


- (void)downloadFailure:(NSString *)operationId suboperationId:(NSString *)suboperationId error:(NSError *)error
{
    NSLog(@"error in SubdownloadViewController");
    [[AppDelegate instance].padDownloadManager stopDownloading];
    [self performSelector:@selector(restartNewDownloading) withObject:nil afterDelay:10];
}

- (void)restartNewDownloading
{
    [AppDelegate instance].padDownloadManager = 0;
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] != NotReachable) {
        [NSThread  detachNewThreadSelector:@selector(startDownloadingThreads) toTarget:[AppDelegate instance].padDownloadManager withObject:nil];
    }
}

- (void)downloadSuccess:(NSString *)operationId suboperationId:(NSString *)suboperationId
{
    for (int i = 0; i < subitems.count; i++) {
        SubdownloadItem *tempitem = [subitems objectAtIndex:i];
        if ([tempitem.itemId isEqualToString:operationId] && [suboperationId isEqualToString:tempitem.subitemId]) {
            [AppDelegate instance].currentDownloadingNum = 0;
            tempitem.percentage = 100;
            tempitem.downloadStatus  = @"done";
            [DatabaseManager update:tempitem];
            break;
        }
    }
    [_gmGridView reloadData];
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_DISK_STORAGE object:nil];
}

- (void)updateProgress:(NSString *)operationId suboperationId:(NSString *)suboperationId progress:(float)progress
{
    for (int i = 0; i < subitems.count; i++) {
        SubdownloadItem *tempitem = [subitems objectAtIndex:i];
        if ([tempitem.itemId isEqualToString:operationId] && [suboperationId isEqualToString:tempitem.subitemId]) {
            if (progress * 100 - tempitem.percentage > 2) {
                NSLog(@"percent in SubdownloadViewController= %f", progress);
                tempitem.percentage = (int)(progress*100);
                [DatabaseManager update:tempitem];
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_DISK_STORAGE object:nil];
            }
            GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
            UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:tempitem.rowId + 20000000];
            if(progressView != nil){
                progressView.progress = progress;                
                UILabel *progressLabel = (UILabel *)[cell viewWithTag:tempitem.rowId + 10000000];
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

- (void)videoImageClicked:(NSInteger)index
{
    Reachability *hostReach = [Reachability reachabilityForInternetConnection];
    if([hostReach currentReachabilityStatus] == NotReachable) {
        [UIUtility showNetWorkError:self.view];
        return;
    }
    if(index >= subitems.count){
        return;
    }
    GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:index];
    SubdownloadItem *subitem = [subitems objectAtIndex:index];
    UILabel *progressLabel = (UILabel *)[cell.contentView viewWithTag:subitem.rowId + 10000000];
    UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:subitem.rowId + 20000000];
    subitem.percentage = (int)(progressView.progress*100);
    if([subitem.downloadStatus isEqualToString:@"start"] || [subitem.downloadStatus isEqualToString:@"waiting"]){
        [[AppDelegate instance].padDownloadManager stopDownloading];
        progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%", (int)(progressView.progress*100)];
        subitem.downloadStatus = @"stop";
        [DatabaseManager update:subitem];
        [AppDelegate instance].currentDownloadingNum = 0;
    } else {
        [self getFreeDiskspacePercent];
        if (totalFreeSpace_ <= LEAST_DISK_SPACE) {
            [UIUtility showNoSpace:self.view];
            return;
        }
        progressLabel.text = [NSString stringWithFormat:@"等待中：%i%%", (int)(progressView.progress*100)];
        subitem.downloadStatus = @"waiting";
        [DatabaseManager update:subitem];
    }
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
    [_gmGridView reloadData];
}

- (void)removeLastPlaytime:(SubdownloadItem *)item
{
    NSString *key = [NSString stringWithFormat:@"%@_%@", item.itemId, item.name];
    [[CacheUtility sharedCache] putInCache:key result:[NSNumber numberWithInt:0]];
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return fmax([subitems count], 9);
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView
{
    return CGSizeMake(110, 165);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    if(index >= subitems.count){
        return nil;
    }
    CGSize size = [self sizeForItemsInGMGridView:gridView];
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-15, -15);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor clearColor];
        cell.contentView = view;
    }
    SubdownloadItem *item = [subitems objectAtIndex:index];
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 105, 146)];
    imageView.image = [UIImage imageNamed:@"movie_frame"];
    [cell.contentView addSubview:imageView];
    
    UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 98, 138)];
    [contentImage setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    [cell.contentView addSubview:contentImage];
    
    UILabel *bgLabel = [[UILabel alloc]initWithFrame:CGRectMake(3, 102, 98, 40)];
    bgLabel.tag = item.rowId + 30000000;
    bgLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    if (![item.downloadStatus isEqualToString:@"done"]) {
        [cell.contentView addSubview:bgLabel];
    }
    
    UILabel *progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(3, 100, 98, 25)];
    progressLabel.tag = item.rowId + 10000000;
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.font = [UIFont boldSystemFontOfSize:13];
    progressLabel.textColor = [UIColor whiteColor];
    if([item.downloadStatus isEqualToString:@"start"]){
        progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%", item.percentage];
    } else if([item.downloadStatus isEqualToString:@"stop"]){
        progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%", item.percentage];
    } else if([item.downloadStatus isEqualToString:@"done"]){
//        progressLabel.text = @"下载完成";
    } else if([item.downloadStatus isEqualToString:@"waiting"]){
        progressLabel.text = [NSString stringWithFormat:@"等待中：%i%%", item.percentage];
    } else if([item.downloadStatus isEqualToString:@"error"]){
        progressLabel.text = @"下载片源失效";
    } 
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.shadowColor = [UIColor blackColor];
    progressLabel.shadowOffset = CGSizeMake(1, 1);
    if (![item.downloadStatus isEqualToString:@"done"]) {        
        [cell.contentView addSubview:progressLabel];
    }
    
    if([item.downloadStatus isEqualToString:@"start"] || [item.downloadStatus isEqualToString:@"stop"] || [item.downloadStatus isEqualToString:@"waiting"]){
        UIProgressView *progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(5, 125, 94, 2)];
        progressView.progress = item.percentage/100.0;
        progressView.tag = item.rowId + 20000000;
        [cell.contentView addSubview:progressView];
    }
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(4, 150, 105, 30)];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = [NSString stringWithFormat:@"%@", item.name];
    nameLabel.center = CGPointMake(imageView.center.x, nameLabel.center.y);
    [cell.contentView addSubview:nameLabel];
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index
{
    SubdownloadItem *item = [subitems objectAtIndex:index];
    if ([item.downloadStatus isEqualToString:@"start"]) {
        [[AppDelegate instance].padDownloadManager stopDownloading];
        [AppDelegate instance].currentDownloadingNum = 0;
    }
    [self removeLastPlaytime:item];
    [DatabaseManager deleteObject:item];
    [DatabaseManager performSQLAggregation:[NSString stringWithFormat: @"delete from SubdownloadItem WHERE itemId = '%@' and subitemId = '%@'", item.itemId, item.subitemId]];
    double result = [DatabaseManager performSQLAggregation: [NSString stringWithFormat: @"delete from SegmentUrl WHERE itemId = '%@'", item.itemId]];
    NSLog(@"result = %f", result);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([item.downloadType isEqualToString:@"m3u8"]) {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@", DocumentsDirectory, item.itemId, item.subitemId];
        [fileManager removeItemAtPath:filePath error:nil];
    } else {
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:DocumentsDirectory error:NULL];
        NSEnumerator *e = [contents objectEnumerator];
        NSString *filename;
        while ((filename = [e nextObject])) {
            if ([filename hasPrefix:[NSString stringWithFormat:@"%@_%@.mp4", item.itemId, item.subitemId]]) {
                [fileManager removeItemAtPath:[DocumentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            }
        }
    }
    
    [self reloadSubitems];
    if(subitems == nil || subitems.count == 0){
        DownloadItem *pItem = (DownloadItem *)[DatabaseManager findFirstByCriteria: DownloadItem.class queryString:[NSString stringWithFormat:@"WHERE itemId = %@", self.itemId]];
        [DatabaseManager deleteObject:pItem];
        if ([item.downloadType isEqualToString:@"m3u8"]) {
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", DocumentsDirectory, item.itemId];
            [fileManager removeItemAtPath:filePath error:nil];
        }
        [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider];
        [self.parentDelegate reloadItems];
    }
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_DISK_STORAGE object:nil];
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    if(position < subitems.count){
        SubdownloadItem *item = [subitems objectAtIndex:position];
        if([item.downloadStatus isEqualToString:@"done"] || item.percentage == 100){
            item.downloadStatus = @"done";
            item.percentage = 100;
            [DatabaseManager update:item];
            NSString *filePath;
            if ([item.downloadType isEqualToString:@"m3u8"]) {
                filePath = [LOCAL_HTTP_SERVER_URL stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/%@/%@_%@.m3u8", item.itemId, item.subitemId, item.itemId, item.subitemId]];
            } else {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@_%@.mp4", item.itemId, item.subitemId]];
            }
    
            AVPlayerViewController *viewController = [[AVPlayerViewController alloc]init];
            viewController.videoFormat = item.downloadType;
            viewController.isDownloaded = YES;
            viewController.m3u8Duration = item.duration;
            viewController.closeAll = YES;
            viewController.videoUrl = filePath;
            viewController.type = 3;
            viewController.name = self.titleContent;
            viewController.subname = item.name;
            viewController.currentNum = 0;
            viewController.prodId = itemId;
            viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController pesentMyModalView:viewController];
        } else {
            if (![item.downloadStatus hasPrefix:@"error"]) {
                [self videoImageClicked:position];
            }
        }
    }
}

- (void)editBtnClicked
{
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


@end
