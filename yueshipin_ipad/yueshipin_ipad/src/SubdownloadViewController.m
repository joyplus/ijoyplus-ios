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
#import "MyMediaPlayerViewController.h"

@interface SubdownloadViewController ()<McDownloadDelegate, GMGridViewDataSource, GMGridViewActionDelegate>{
    UIButton *closeBtn;
    UILabel *titleLabel;
    int leftWidth;
    NSArray *subitems;
    
    UIButton *editBtn;
    UIButton *doneBtn;;
    
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
    [self.view addGestureRecognizer:swipeRecognizer];
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
        closeBtn.frame = CGRectMake(465, 20, 40, 42);
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDownloadingThreads) name:ADD_NEW_DOWNLOAD_ITEM object:nil];
    }
    return self;
}
- (void)startDownloadingThread:(NSArray *)downLoaderArray startType:(int)startType
{
    for (McDownload *downloader in downLoaderArray) {
        if([downloader.idNum isEqualToString: self.itemId]){
            downloader.delegate = self;
        }
        if(downloader.status == 2){
            for (int i = 0; i < subitems.count; i++) {
                SubdownloadItem *item = [subitems objectAtIndex:i];
                if ([item.itemId isEqualToString:downloader.idNum] && downloader.subidNum == item.pk) {
                    downloader.delegate = self;
                    item.downloadStatus = @"done";
                    item.percentage = 100;
                    [item save];
                    break;
                }
            }
        } else if(downloader.status == startType){
            if([AppDelegate instance].currentDownloadingNum < MAX_DOWNLOADING_THREADS){
                [AppDelegate instance].currentDownloadingNum++;
                [self reloadSubitems];
                for (int i = 0; i < subitems.count; i++) {
                    SubdownloadItem *item = [subitems objectAtIndex:i];
                    if ([item.itemId isEqualToString:downloader.idNum]&& downloader.subidNum == item.pk) {
                        item.downloadStatus = @"start";
                        [item save];
                        break;
                    }
                }
                downloader.status = 1;
                [downloader start];
            }
        }
    }
}
- (void)startDownloadingThreads
{
    NSArray *downLoaderArray = [[AppDelegate instance] getDownloaderQueue];
    [self startDownloadingThread:downLoaderArray startType:1]; // start
    [self startDownloadingThread:downLoaderArray startType:3]; // waiting
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    titleLabel.text = self.titleContent;
    _gmGridView.editing = NO;
    [editBtn setHidden:NO];
    [doneBtn setHidden:YES];
    [self reloadSubitems];
    [_gmGridView reloadData];
    [self startDownloadingThreads];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSArray *downLoaderArray = [[AppDelegate instance] getDownloaderQueue];
    for (McDownload *downloader in downLoaderArray) {
        if([downloader.idNum isEqualToString: self.itemId]){
            downloader.delegate = [AppDelegate instance];
        }
    }
}

- (void)reloadSubitems
{
    NSString *subquery = [NSString stringWithFormat:@"WHERE item_id = '%@'", self.itemId];
    subitems = [SubdownloadItem findByCriteria:subquery];
    subitems = [subitems sortedArrayUsingComparator:^(SubdownloadItem *a, SubdownloadItem *b) {
        NSNumber *first =  [NSNumber numberWithInt:a.subitemId.intValue];
        NSNumber *second = [NSNumber numberWithInt:b.subitemId.intValue];
        return [first compare:second];
    }];
}

//下载失败
- (void)downloadFaild:(McDownload *)aDownload didFailWithError:(NSError *)error
{
    NSLog(@"下载失败 %@", error);
    aDownload.status = 4;
    [AppDelegate instance].currentDownloadingNum--;
    if([AppDelegate instance].currentDownloadingNum < 0){
        [AppDelegate instance].currentDownloadingNum = 0;
    }
    for (int i = 0; i < subitems.count; i++) {
        SubdownloadItem *item = [subitems objectAtIndex:i];
        if (error == nil) {
            item.downloadStatus = @"error938";
        } else {
            item.downloadStatus = @"error";
        }
        [item save];
        [self reloadSubitems];
        [_gmGridView reloadData];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_NEW_DOWNLOAD_ITEM object:nil];
}
//下载结束
- (void)downloadFinished:(McDownload *)aDownload
{
    NSLog(@"下载完成");
    aDownload.status = 2;
    [AppDelegate instance].currentDownloadingNum--;
    if([AppDelegate instance].currentDownloadingNum < 0){
        [AppDelegate instance].currentDownloadingNum = 0;
    }
    for (int i = 0; i < subitems.count; i++) {
        SubdownloadItem *item = [subitems objectAtIndex:i];
        if ([item.itemId isEqualToString:aDownload.idNum] && aDownload.subidNum == item.pk) {
            GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
            UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:aDownload.subidNum + 20000000];
            if(progressView != nil){
                [progressView removeFromSuperview];
                UILabel *progressLabel = (UILabel *)[cell viewWithTag:aDownload.subidNum + 10000000];
                progressLabel.text = @"下载完成";
                progressView = nil;
                
                item.percentage = 100;
                item.downloadStatus  = @"done";
                [item save];
                [self reloadSubitems];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_NEW_DOWNLOAD_ITEM object:nil];
}
//下载开始(responseHeaders为服务器返回的下载文件的信息)
- (void)downloadBegin:(McDownload *)aDownload didReceiveResponseHeaders:(NSURLResponse *)responseHeaders
{
    NSLog(@"下载开始");
}
//更新下载的进度
- (void)downloadProgressChange:(McDownload *)aDownload progress:(double)newProgress
{
    for (int i = 0; i < subitems.count; i++) {
        SubdownloadItem *item = [subitems objectAtIndex:i];
        if ([item.itemId isEqualToString:aDownload.idNum] && aDownload.subidNum == item.pk) {
            item.downloadStatus = @"start";
            item.percentage = (int)(newProgress * 100);
            [item save];
            GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
            UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:aDownload.subidNum + 20000000];
            if(progressView != nil){
                progressView.progress = newProgress;
                
                UILabel *progressLabel = (UILabel *)[cell viewWithTag:aDownload.subidNum + 10000000];
                progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%", (int)(newProgress*100)];
//                NSLog(@"%@", progressLabel.text);
            }
            break;
        }
    }
}

- (void)videoImageClicked:(NSInteger)index
{
    if(index >= subitems.count){
        return;
    }
    GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:index];
    SubdownloadItem *item = [subitems objectAtIndex:index];
    NSArray *downloaderArray = [[AppDelegate instance] getDownloaderQueue];
    NSLog(@"%i", downloaderArray.count);
    for (McDownload *tempdownloder in downloaderArray) {
        if([tempdownloder.idNum isEqualToString:item.itemId] && tempdownloder.subidNum == item.pk){
            UILabel *progressLabel = (UILabel *)[cell.contentView viewWithTag:item.pk + 10000000];
            UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:item.pk + 20000000];
            item.percentage = (int)(progressView.progress*100);
            if(tempdownloder.status == 0){
                progressLabel.text = [NSString stringWithFormat:@"等待中：%i%%", (int)(progressView.progress*100)];
                item.downloadStatus = @"waiting";
                [item save];
                tempdownloder.status = 3;
            } else {
                progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%", (int)(progressView.progress*100)];
                item.downloadStatus = @"stop";
                [item save];
                [AppDelegate instance].currentDownloadingNum--;
                if([AppDelegate instance].currentDownloadingNum < 0){
                    [AppDelegate instance].currentDownloadingNum = 0;
                }
                tempdownloder.status = 0;
                [tempdownloder stop];
            }
            [self reloadSubitems];
            break;
        }
    }
    [self startDownloadingThreads];
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
    bgLabel.tag = item.pk + 30000000;
    bgLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [cell.contentView addSubview:bgLabel];
    
    UILabel *progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(3, 100, 98, 25)];
    progressLabel.tag = item.pk + 10000000;
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.font = [UIFont boldSystemFontOfSize:13];
    progressLabel.textColor = [UIColor whiteColor];
    if([item.downloadStatus isEqualToString:@"start"]){
        progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%", item.percentage];
    } else if([item.downloadStatus isEqualToString:@"stop"]){
        progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%", item.percentage];
    } else if([item.downloadStatus isEqualToString:@"done"]){
        progressLabel.text = @"下载完成";
    } else if([item.downloadStatus isEqualToString:@"waiting"]){
        progressLabel.text = [NSString stringWithFormat:@"等待中：%i%%", item.percentage];
    } else if([item.downloadStatus isEqualToString:@"error938"]){
        progressLabel.text = @"下载片源失效";
    } else {
        progressLabel.text = @"下载失败";
    }
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.shadowColor = [UIColor blackColor];
    progressLabel.shadowOffset = CGSizeMake(1, 1);
    [cell.contentView addSubview:progressLabel];
    
    if([item.downloadStatus isEqualToString:@"start"] || [item.downloadStatus isEqualToString:@"stop"] || [item.downloadStatus isEqualToString:@"waiting"]){
        UIProgressView *progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(3, 125, 98, 2)];
        progressView.progress = item.percentage/100.0;
        progressView.tag = item.pk + 20000000;
        [cell.contentView addSubview:progressView];
    }
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(4, 150, 105, 30)];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = item.name;
    nameLabel.center = CGPointMake(imageView.center.x, nameLabel.center.y);
    [cell.contentView addSubview:nameLabel];
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index
{
    SubdownloadItem *item = [subitems objectAtIndex:index];
    
    [[AppDelegate instance] deleteDownloaderInQueue:item];
    [item deleteObject];
    
    NSString *extension = @"mp4";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        if ([filename hasPrefix:[NSString stringWithFormat:@"%@_%@.%@", item.itemId, item.subitemId, extension]]) {
            [[AppDelegate instance] deleteDownloaderInQueue:item];
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
    
    if ([item.downloadStatus isEqualToString:@"start"]) {
        [AppDelegate instance].currentDownloadingNum--;
        if([AppDelegate instance].currentDownloadingNum < 0){
            [AppDelegate instance].currentDownloadingNum = 0;
        }
    }
    [self reloadSubitems];
    if(subitems == nil || subitems.count == 0){
        NSString *subquery = [NSString stringWithFormat:@"WHERE item_id = '%@'", item.itemId];
        NSArray *downloadingItems = [DownloadItem findByCriteria:subquery];
        for (DownloadItem *pItem in downloadingItems){
            [pItem deleteObject];
            [[AppDelegate instance] deleteDownloaderInQueue:pItem];
        }
        [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider];
        [self.parentDelegate reloadItems];
    }
    [self reloadSubitems];
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    [self closeMenu];
    if(position < subitems.count){
        SubdownloadItem *item = [subitems objectAtIndex:position];
        if([item.downloadStatus isEqualToString:@"done"] || item.percentage == 100){
            item.downloadStatus = @"done";
            item.percentage = 100;
            [item save];
            NSString *extension = @"mp4";
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
            NSEnumerator *e = [contents objectEnumerator];
            NSString *filename;
            NSString *filePath;
            while ((filename = [e nextObject])) {
                if ([filename hasPrefix:[NSString stringWithFormat:@"%@_%@.%@", item.itemId, item.subitemId, extension]]) {
                    filePath = [documentsDirectory stringByAppendingPathComponent:filename];
                    break;
                }
            }
            
            MyMediaPlayerViewController *viewController = [[MyMediaPlayerViewController alloc]init];
            viewController.isDownloaded = YES;
            viewController.closeAll = YES;
            NSMutableArray *urlsArray = [[NSMutableArray alloc]initWithCapacity:1];
            [urlsArray addObject:filePath];
            viewController.videoUrls = urlsArray;
            viewController.prodId = item.itemId;
            viewController.type = item.type;
            viewController.name = self.titleContent;
            viewController.subname = item.name;
            viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            [[AppDelegate instance].rootViewController pesentMyModalView:[[UINavigationController alloc]initWithRootViewController:viewController]];
        } else {
            if (![item.downloadStatus hasPrefix:@"error938"]) {
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
