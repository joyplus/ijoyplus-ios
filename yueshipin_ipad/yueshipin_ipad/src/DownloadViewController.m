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

@interface DownloadViewController ()<McDownloadDelegate, GMGridViewDataSource, GMGridViewActionDelegate>{
    UIButton *menuBtn;
    UIImageView *topImage;
    UIImageView *bgImage;
    
    int leftWidth;
    NSArray *allItem;
    
    UIButton *editBtn;
    UIButton *doneBtn;;
    
    __gm_weak GMGridView *_gmGridView;
    UINavigationController *_optionsNav;
    UIPopoverController *_optionsPopOver;
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

- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
		[self.view setFrame:frame];
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        bgImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 24)];
        bgImage.image = [UIImage imageNamed:@"left_background"];
        [self.view addSubview:bgImage];
        
        leftWidth = 80;
        menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        menuBtn.frame = CGRectMake(0, 28, 60, 60);
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn"] forState:UIControlStateNormal];
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"menu_btn_pressed"] forState:UIControlStateHighlighted];
        [menuBtn addTarget:self action:@selector(menuBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:menuBtn];
        
        topImage = [[UIImageView alloc]initWithFrame:CGRectMake(leftWidth, 40, 140, 35)];
        topImage.image = [UIImage imageNamed:@"search_title"];
        [self.view addSubview:topImage];
        
        editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        editBtn.frame = CGRectMake(420, 80, 40, 32);
        [editBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [editBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
        [editBtn addTarget:self action:@selector(editBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:editBtn];
        
        doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = editBtn.frame;
        [doneBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [doneBtn setBackgroundImage:[UIImage imageNamed:@"cancel_pressed"] forState:UIControlStateHighlighted];
        [doneBtn addTarget:self action:@selector(doneBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [doneBtn setHidden:YES];
        [self.view addSubview:doneBtn];
        
        [self initDownloadingThreads];
        GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(LEFT_WIDTH, 110, 450, 610)];
        gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        gmGridView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:gmGridView];
        _gmGridView = gmGridView;
        
        NSInteger spacing = 30;
        _gmGridView.style = GMGridViewStyleSwap;
        _gmGridView.itemSpacing = spacing;
        _gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
        _gmGridView.centerGrid = YES;
        _gmGridView.actionDelegate = self;
        _gmGridView.dataSource = self;
        _gmGridView.mainSuperView = self.view;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initDownloadingThreads) name:ADD_NEW_DOWNLOAD_ITEM object:nil];
    }
    return self;
}
- (void)initDownloadingThreads
{
    
    NSArray *downLoaderArray = [[AppDelegate instance] getDownloaderQueue];
    for (McDownload *downloader in downLoaderArray) {
        downloader.delegate = self;
        if(!downloader.isStop){
            [downloader start];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _gmGridView.editing = NO;
    [editBtn setHidden:NO];
    [doneBtn setHidden:YES];
    allItem = [DownloadItem allObjects];
    [_gmGridView reloadData];
}

//下载失败
- (void)downloadFaild:(McDownload *)aDownload didFailWithError:(NSError *)error
{
    NSLog(@"下载失败");
}
//下载结束
- (void)downloadFinished:(McDownload *)aDownload
{
    NSLog(@"下载完成");
    for (int i = 0; i < allItem.count; i++) {
        GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
        UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:aDownload.idNum.intValue + 20000000];
        if(progressView != nil){
            [progressView removeFromSuperview];
            UILabel *progressLabel = (UILabel *)[cell viewWithTag:aDownload.idNum.intValue + 10000000];
            [progressLabel removeFromSuperview];
            progressView = nil;
            progressLabel = nil;
            DownloadItem *item = [allItem objectAtIndex:i];
            item.percentage = 100;
            item.downloadingStatus = @"done";
            [item save];
        }
    }
}
//下载开始(responseHeaders为服务器返回的下载文件的信息)
- (void)downloadBegin:(McDownload *)aDownload didReceiveResponseHeaders:(NSURLResponse *)responseHeaders
{
    NSLog(@"下载开始");
}
//更新下载的进度
- (void)downloadProgressChange:(McDownload *)aDownload progress:(double)newProgress
{
    NSLog(@"%@", @"下载中...");
    for (int i = 0; i < allItem.count; i++) {
        GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
        UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:aDownload.idNum.intValue + 20000000];
        if(progressView != nil){
            progressView.progress = newProgress;
            UILabel *progressLabel = (UILabel *)[cell viewWithTag:aDownload.idNum.intValue + 10000000];
            progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%", (int)(newProgress*100)];
            NSLog(@"%@", progressLabel.text);
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
            if(tempdownloder.isStop){
                progressLabel.text = [progressLabel.text stringByReplacingOccurrencesOfString:@"暂停" withString:@"下载中"];
                [tempdownloder start];
                item.downloadingStatus = @"start";
                [item save];
            } else {
                progressLabel.text = [progressLabel.text stringByReplacingOccurrencesOfString:@"下载中" withString:@"暂停"];
                [tempdownloder stop];
                UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:item.itemId.intValue + 20000000];
                item.percentage = (int)(progressView.progress*100);
                item.downloadingStatus = @"stop";
                [item save];
            }
            break;
        }
    }
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
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 105, 146)];
    imageView.image = [UIImage imageNamed:@"movie_frame"];
    [cell.contentView addSubview:imageView];
    
    UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 98, 138)];
    [contentImage setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    [cell.contentView addSubview:contentImage];
    
    UILabel *progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(3, 110, 98, 25)];
    progressLabel.tag = item.itemId.intValue + 10000000;
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.font = [UIFont boldSystemFontOfSize:10];
    progressLabel.textColor = [UIColor whiteColor];
    if([item.downloadingStatus isEqualToString:@"start"]){
        progressLabel.text = @"下载中：  %";
    } else if([item.downloadingStatus isEqualToString:@"stop"]){
        progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%", item.percentage];
    } else{
        progressLabel.text = @"";
    }
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.shadowColor = [UIColor blackColor];
    progressLabel.shadowOffset = CGSizeMake(1, 1);
    [cell.contentView addSubview:progressLabel];
    
    UIProgressView *progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(3, 132, 98, 2)];
    progressView.progress = item.percentage/100.0;
    progressView.tag = item.itemId.intValue + 20000000;
    [cell.contentView addSubview:progressView];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(4, 150, 105, 30)];
    nameLabel.font = [UIFont systemFontOfSize:18];;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = item.name;
    [nameLabel sizeToFit];
    nameLabel.center = CGPointMake(imageView.center.x, nameLabel.center.y);
    [cell.contentView addSubview:nameLabel];
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index
{
    DownloadItem *item = [allItem objectAtIndex:index];
    
    NSString *extension = @"mp4";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        if ([filename hasPrefix:[NSString stringWithFormat:@"%@.%@", item.itemId, extension]]) {
            [[AppDelegate instance] deleteDownloaderInQueue:item];
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
    [item deleteObject];
    item = nil;
    allItem = [DownloadItem allObjects];    
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    [self stopDownloading:position];
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

- (void)menuBtnClicked
{
    [self.menuViewControllerDelegate menuButtonClicked];
}
@end
