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
#import "MediaPlayerViewController.h"
#import "SQLiteInstanceManager.h"

@interface DownloadViewController ()<McDownloadDelegate, GMGridViewDataSource, GMGridViewActionDelegate>{
    UIButton *menuBtn;
    UIImageView *topImage;
    UIImageView *topIcon;
    UIImageView *bgImage;
    UIImageView *nodownloadImage;
    
    int leftWidth;
    NSArray *allItem;
    
    UIButton *editBtn;
    UIButton *doneBtn;;
    
    __gm_weak GMGridView *_gmGridView;
}
@end

@implementation DownloadViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    menuBtn = nil;
    topImage = nil;
    bgImage = nil;
    allItem = nil;
    _gmGridView = nil;
    
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    closeMenuRecognizer.delegate = self;
    [self.view addGestureRecognizer:closeMenuRecognizer];
    [self.view addGestureRecognizer:swipeCloseMenuRecognizer];
    [self.view addGestureRecognizer:openMenuRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    } else if([NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]){
        return NO;
    } else {
        return YES;
    }
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        bgImage.image = [UIImage imageNamed:@"left_background"];
        [self.view addSubview:bgImage];
        
        nodownloadImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
        nodownloadImage.center = CGPointMake(bgImage.center.x, bgImage.center.y - 100);
        nodownloadImage.image = [UIImage imageNamed:@"nodownload"];
        [self.view addSubview:nodownloadImage];
        
        leftWidth = 80;
        menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0, 28, 60, 60);
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn_pressed"] forState:UIControlStateHighlighted];
        [menuBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuBtn];
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(leftWidth + 50, 40, 143, 35)];
        topImage.image = [UIImage imageNamed:@"download_title"];
        [self.view addSubview:topImage];
        
        topIcon = [[UIImageView alloc]initWithFrame:CGRectMake(leftWidth, 40, 32, 32)];
        topIcon.image = [UIImage imageNamed:@"download_icon"];
        [self.view addSubview:topIcon];
        
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
        
        [self reloadItems];
        [self startDownloadingThreads];
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
        downloader.delegate = self;
        if(downloader.status == startType){
            if([AppDelegate instance].currentDownloadingNum < MAX_DOWNLOADING_THREADS){
                [AppDelegate instance].currentDownloadingNum++;
                for (int i = 0; i < allItem.count; i++) {
                    DownloadItem *item = [allItem objectAtIndex:i];
                    if ([item.itemId isEqualToString:downloader.idNum]) {
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
    allItem = [DownloadItem allObjects];
    if (allItem.count > 0) {
        [editBtn setHidden:NO];
        [nodownloadImage setHidden:YES];
    } else {
        [editBtn setHidden:YES];
        [nodownloadImage setHidden:NO];
    }
    NSArray *downLoaderArray = [[AppDelegate instance] getDownloaderQueue];
    [self startDownloadingThread:downLoaderArray startType:1]; // start
    [self startDownloadingThread:downLoaderArray startType:3]; // waiting
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _gmGridView.editing = NO;
    [self reloadItems];
}

- (void)reloadItems
{
    allItem = [DownloadItem allObjects];
    [_gmGridView reloadData];
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
    for (int i = 0; i < allItem.count; i++) {
        DownloadItem *item = [allItem objectAtIndex:i];
        if ([item.itemId isEqualToString:aDownload.idNum]) {
            DownloadItem *item = [allItem objectAtIndex:i];
            item.downloadStatus = @"error";
            [item save];
        }
    }
    [self startDownloadingThreads];
    [self reloadItems];
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
    for (int i = 0; i < allItem.count; i++) {
        DownloadItem *item = [allItem objectAtIndex:i];
        if ([item.itemId isEqualToString:aDownload.idNum]) {
            item.percentage = 100;
            item.downloadStatus = @"done";
            [item save];
        }
    }
    [self startDownloadingThreads];
    [self reloadItems];
}

//下载开始(responseHeaders为服务器返回的下载文件的信息)
- (void)downloadBegin:(McDownload *)aDownload didReceiveResponseHeaders:(NSURLResponse *)responseHeaders
{
    NSLog(@"下载开始");
}
//更新下载的进度
- (void)downloadProgressChange:(McDownload *)aDownload progress:(double)newProgress
{
    for (int i = 0; i < allItem.count; i++) {
        DownloadItem *item = [allItem objectAtIndex:i];
        if ([item.itemId isEqualToString:aDownload.idNum]) {
            item.downloadStatus = @"start";
            item.percentage = (int)(newProgress * 100);
            [item save];
            GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
            UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:aDownload.idNum.intValue + 20000000];
            if(progressView != nil){
                progressView.progress = newProgress;
                UILabel *progressLabel = (UILabel *)[cell viewWithTag:aDownload.idNum.intValue + 10000000];
                progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%", (int)(newProgress*100)];
            }
            break;
        }
    }
}

- (void)stopDownloading:(NSInteger)index
{
    if(index >= allItem.count){
        return;
    }
    GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:index];
    DownloadItem *item = [allItem objectAtIndex:index];
    NSArray *downloaderArray = [[AppDelegate instance] getDownloaderQueue];
    for (McDownload *tempdownloder in downloaderArray) {
        if([tempdownloder.idNum isEqualToString:item.itemId]){
            UILabel *progressLabel = (UILabel *)[cell.contentView viewWithTag:item.itemId.intValue + 10000000];
            UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:item.itemId.intValue + 20000000];
            item.percentage = (int)(progressView.progress*100);
            if(tempdownloder.status != 0){
                progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%", (int)(progressView.progress*100)];
                item.downloadStatus = @"stop";
                [item save];
                [AppDelegate instance].currentDownloadingNum--;
                if([AppDelegate instance].currentDownloadingNum < 0){
                    [AppDelegate instance].currentDownloadingNum = 0;
                }
                tempdownloder.status = 0;
                [tempdownloder stop];
            } else {
                progressLabel.text = [NSString stringWithFormat:@"等待中：%i%%", (int)(progressView.progress*100)];
                item.downloadStatus = @"waiting";
                [item save];
                tempdownloder.status = 3;
            }
            break;
        }
    }
    [self startDownloadingThreads];
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return fmax([allItem count], 9);
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView
{
    return CGSizeMake(110, 165);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    if(index >= allItem.count){
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
    DownloadItem *item = [allItem objectAtIndex:index];
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    imageView.frame = CGRectMake(0, 0, 105, 146);
    [cell.contentView addSubview:imageView];
    
    UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 98, 138)];
    [contentImage setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    [cell.contentView addSubview:contentImage];
    
    if (item.type == 1) {
        imageView.image = [UIImage imageNamed:@"movie_frame"];
        
        if(![item.downloadStatus isEqualToString:@"done"]){
            UILabel *bgLabel = [[UILabel alloc]initWithFrame:CGRectMake(3, 102, 98, 40)];
            bgLabel.tag = item.itemId.intValue + 30000000;
            bgLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
            [cell.contentView addSubview:bgLabel];
        }
        
        UILabel *progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(3, 100, 98, 25)];
        progressLabel.tag = item.itemId.intValue + 10000000;
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
        } else {
            progressLabel.text = @"下载失败";
        }
        
        progressLabel.textAlignment = NSTextAlignmentCenter;
        progressLabel.shadowColor = [UIColor blackColor];
        progressLabel.shadowOffset = CGSizeMake(1, 1);
        [cell.contentView addSubview:progressLabel];
        
        if(![item.downloadStatus isEqualToString:@"done"]){
            UIProgressView *progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(3, 125, 98, 5)];
            progressView.progress = item.percentage/100.0;
            progressView.tag = item.itemId.intValue + 20000000;
            [cell.contentView addSubview:progressView];
        }
    } else {
        imageView.frame = CGRectMake(0, 0, 110, 150);
        contentImage.frame = CGRectMake(10, 5, 88, 130);
        imageView.image = [UIImage imageNamed:@"moviecard_list"];
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
    DownloadItem *item = [allItem objectAtIndex:index];
    
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
        if(item.type == 1){
            if ([filename hasPrefix:[NSString stringWithFormat:@"%@.%@", item.itemId, extension]]) {
                [[AppDelegate instance] deleteDownloaderInQueue:item];
                [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            }
        } else {
            if ([filename hasPrefix:[NSString stringWithFormat:@"%@_", item.itemId]]) {
                [[AppDelegate instance] deleteDownloaderInQueue:item];
                [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            }
        }
    }
    
    if ([item.downloadStatus isEqualToString:@"start"]) {
        [AppDelegate instance].currentDownloadingNum--;
        if([AppDelegate instance].currentDownloadingNum < 0){
            [AppDelegate instance].currentDownloadingNum = 0;
        }
    }
    NSString *subquery = [NSString stringWithFormat:@"WHERE item_id = '%@'", item.itemId];
    NSArray *downloadingItems = [SubdownloadItem findByCriteria:subquery];
    for (SubdownloadItem *subitem in downloadingItems) {
        [subitem deleteObject];
        [[AppDelegate instance] deleteDownloaderInQueue: subitem];
    }
    item = nil;
    allItem = [DownloadItem allObjects];
    if (allItem.count > 0) {
        [self startDownloadingThreads];
    } else {
        [editBtn setHidden:YES];
        [doneBtn setHidden:YES];
        [nodownloadImage setHidden:NO];
    }
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    [self closeMenu];
    if(position < allItem.count){
        DownloadItem *item = [allItem objectAtIndex:position];
        if([item.downloadStatus isEqualToString:@"done"] && item.type == 1){
            NSString *extension = @"mp4";
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
            NSEnumerator *e = [contents objectEnumerator];
            NSString *filename;
            NSString *filePath;
            while ((filename = [e nextObject])) {
                if ([filename hasPrefix:[NSString stringWithFormat:@"%@.%@", item.itemId, extension]]) {
                    filePath = [documentsDirectory stringByAppendingPathComponent:filename];
                    break;
                }
            }
            
            MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
            viewController.videoUrl = filePath;
            viewController.prodId = item.itemId;
            viewController.name = item.name;
            viewController.subname = @"";
            viewController.isDownloaded = YES;
            viewController.type = 1;
            [[AppDelegate instance].rootViewController pesentMyModalView:viewController];
        } else {
            if(item.type == 1){
                [self stopDownloading:position];
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
    [self closeMenu];
    [[AppDelegate instance].rootViewController.stackScrollViewController removeViewToViewInSlider:self.class];
    _gmGridView.editing = YES;
    [editBtn setHidden:YES];
    [doneBtn setHidden:NO];
}

- (void)doneBtnClicked
{
    [self closeMenu];
    _gmGridView.editing = NO;
    [editBtn setHidden:NO];
    [doneBtn setHidden:YES];
}

@end
