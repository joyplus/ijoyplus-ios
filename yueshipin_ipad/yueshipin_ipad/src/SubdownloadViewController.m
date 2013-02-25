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

@interface SubdownloadViewController ()<SubdownloadingDelegate, GMGridViewDataSource, GMGridViewActionDelegate>{
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

- (void)reloadSubitems
{
    NSMutableArray *tempsubitems = [[NSMutableArray alloc]initWithCapacity:10];
    for (SubdownloadItem *item in [AppDelegate instance].subdownloadItems) {
        if ([item.itemId isEqualToString:self.itemId]) {
            [tempsubitems addObject:item];
        }
    }
    subitems = [tempsubitems sortedArrayUsingComparator:^(SubdownloadItem *a, SubdownloadItem *b) {
        NSNumber *first =  [NSNumber numberWithInt:a.subitemId.intValue];
        NSNumber *second = [NSNumber numberWithInt:b.subitemId.intValue];
        return [first compare:second];
    }];
}


- (void)downloadFailure:(NSString *)operationId suboperationId:(NSString *)suboperationId error:(NSError *)error
{
    [AppDelegate instance].currentDownloadingNum--;
    if([AppDelegate instance].currentDownloadingNum < 0){
        [AppDelegate instance].currentDownloadingNum = 0;
    }
}

- (void)downloadSuccess:(NSString *)operationId suboperationId:(NSString *)suboperationId
{
    for (int i = 0; i < subitems.count; i++) {
        SubdownloadItem *tempitem = [subitems objectAtIndex:i];
        if ([tempitem.itemId isEqualToString:operationId] && [suboperationId isEqualToString:tempitem.subitemId]) {
            [AppDelegate instance].currentDownloadingNum--;
            if([AppDelegate instance].currentDownloadingNum < 0){
                [AppDelegate instance].currentDownloadingNum = 0;
            }
            tempitem.percentage = 100;
            tempitem.downloadStatus  = @"done";
            [tempitem save];
            [_gmGridView reloadData];            
            [[AppDelegate instance].padDownloadManager startDownloadingThreads];
            break;
        }
    }
}

- (void)updateProgress:(NSString *)operationId suboperationId:(NSString *)suboperationId progress:(float)progress
{
    for (int i = 0; i < subitems.count; i++) {
        SubdownloadItem *tempitem = [subitems objectAtIndex:i];
        if ([tempitem.itemId isEqualToString:operationId] && [suboperationId isEqualToString:tempitem.subitemId]) {
            if (progress * 100 - tempitem.percentage > 5) {
                NSLog(@"percent = %f", progress);
                tempitem.percentage = (int)(progress*100);
                [tempitem save];
            }
            GMGridViewCell *cell = [_gmGridView cellForItemAtIndex:i];
            UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:tempitem.pk + 20000000];
            if(progressView != nil){
                progressView.progress = progress;                
                UILabel *progressLabel = (UILabel *)[cell viewWithTag:tempitem.pk + 10000000];
                progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%", (int)(progress*100)];
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
    SubdownloadItem *subitem = [subitems objectAtIndex:index];
    UILabel *progressLabel = (UILabel *)[cell.contentView viewWithTag:subitem.pk + 10000000];
    UIProgressView *progressView = (UIProgressView *)[cell.contentView viewWithTag:subitem.pk + 20000000];
    subitem.percentage = (int)(progressView.progress*100);
    if([subitem.downloadStatus isEqualToString:@"start"] || [subitem.downloadStatus isEqualToString:@"waiting"]){
        [[AppDelegate instance].padDownloadManager stopDownloading];
        progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%", (int)(progressView.progress*100)];
        subitem.downloadStatus = @"stop";
        [subitem save];
        [AppDelegate instance].currentDownloadingNum--;
        if([AppDelegate instance].currentDownloadingNum < 0){
            [AppDelegate instance].currentDownloadingNum = 0;
        }
    } else {
        progressLabel.text = [NSString stringWithFormat:@"等待中：%i%%", (int)(progressView.progress*100)];
        subitem.downloadStatus = @"waiting";
        [subitem save];
    }
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
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
    if (![item.downloadStatus isEqualToString:@"done"]) {
        [cell.contentView addSubview:bgLabel];
    }
    
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
    [[AppDelegate instance].subdownloadItems removeObject:item];
    [item deleteObject];
    if ([item.downloadStatus isEqualToString:@"start"]) {
        [[AppDelegate instance].padDownloadManager stopDownloading];
        [AppDelegate instance].currentDownloadingNum--;
        if([AppDelegate instance].currentDownloadingNum < 0){
            [AppDelegate instance].currentDownloadingNum = 0;
        }
    }
    
    NSString *extension = @"mp4";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        if ([filename hasPrefix:[NSString stringWithFormat:@"%@_%@.%@", item.itemId, item.subitemId, extension]]) {
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
    
    [self reloadSubitems];
    if(subitems == nil || subitems.count == 0){
        for (DownloadItem *pItem in [AppDelegate instance].downloadItems){
            if ([pItem.itemId isEqualToString:self.itemId]) {
                [[AppDelegate instance].downloadItems removeObject:pItem];
                [pItem deleteObject];
                break;
            }
        }
        [[AppDelegate instance].rootViewController.stackScrollViewController removeViewInSlider];
        [self.parentDelegate reloadItems];
    }
    [[AppDelegate instance].padDownloadManager startDownloadingThreads];
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
    
            AVPlayerViewController *viewController = [[AVPlayerViewController alloc]init];
            viewController.isDownloaded = YES;
            viewController.closeAll = YES;
            NSMutableArray *urlsArray = [[NSMutableArray alloc]initWithCapacity:1];
            [urlsArray addObject:filePath];
            viewController.videoUrlsArray = urlsArray;
            viewController.type = 1;
            viewController.name = self.titleContent;
            viewController.subname = item.name;
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
