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
        if([downloader.idNum isEqualToString: self.itemId]){
            downloader.delegate = self;
            if(!downloader.isStop){
                [downloader start];
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initDownloadingThreads];
    titleLabel.text = self.titleContent;
    _gmGridView.editing = NO;
    [editBtn setHidden:NO];
    [doneBtn setHidden:YES];
    [self reloadSubitems];
    [_gmGridView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSArray *downLoaderArray = [[AppDelegate instance] getDownloaderQueue];
    for (McDownload *downloader in downLoaderArray) {
        if([downloader.idNum isEqualToString: self.itemId]){
            downloader.delegate = nil;
        }
    }
}

- (void)reloadSubitems
{
    NSString *subquery = [NSString stringWithFormat:@"WHERE item_id = '%@'", self.itemId];
    subitems = [SubdownloadItem findByCriteria:subquery];
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
    for (int i = 0; i < subitems.count; i++) {
        GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
        UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:aDownload.idNum.intValue + 20000000];
        if(progressView != nil){
            [progressView removeFromSuperview];
            UILabel *progressLabel = (UILabel *)[cell viewWithTag:aDownload.idNum.intValue + 10000000];
            [progressLabel removeFromSuperview];
            progressView = nil;
            progressLabel = nil;
            SubdownloadItem *item = [subitems objectAtIndex:i];
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
    NSLog(@"%@", @"Sub-下载中...");
    for (int i = 0; i < subitems.count; i++) {
        GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
        UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:aDownload.subidNum.intValue + 20000000];
        if(progressView != nil){
            progressView.progress = newProgress;
            UILabel *progressLabel = (UILabel *)[cell viewWithTag:aDownload.subidNum.intValue + 10000000];
            progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%", (int)(newProgress*100)];
            NSLog(@"%@", progressLabel.text);
        }
    }
}

- (void)stopDownloading:(NSInteger)index
{
    if(index >= subitems.count){
        return;
    }
    GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:index];
    SubdownloadItem *item = [subitems objectAtIndex:index];
    NSArray *downloaderArray = [[AppDelegate instance] getDownloaderQueue];
    for (McDownload *tempdownloder in downloaderArray) {
        if([tempdownloder.idNum isEqualToString:item.itemId] && [tempdownloder.subidNum isEqualToString:item.subitemId]){
            UILabel *progressLabel = (UILabel *)[cell.contentView viewWithTag:item.subitemId.intValue + 10000000];
            if(tempdownloder.isStop){
                progressLabel.text = [progressLabel.text stringByReplacingOccurrencesOfString:@"暂停" withString:@"下载中"];
                tempdownloder.delegate = self;
                [tempdownloder start];
                item.downloadingStatus = @"start";
                [item save];
            } else {
                progressLabel.text = [progressLabel.text stringByReplacingOccurrencesOfString:@"下载中" withString:@"暂停"];
                [tempdownloder stop];
                UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:item.subitemId.intValue + 20000000];
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
    SubdownloadItem *item = [subitems objectAtIndex:index];
    
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
    [item deleteObject];
    item = nil;
    [self reloadSubitems];
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

@end
