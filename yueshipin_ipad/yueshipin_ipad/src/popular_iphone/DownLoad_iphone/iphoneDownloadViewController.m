//
//  IphoneDownloadViewController.m
//  yueshipin
//
//  Created by 08 on 13-1-21.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "IphoneDownloadViewController.h"
#import "UIImageView+WebCache.h"
#import "DownloadItem.h"
#import "DownLoadManager.h"
#import "McDownload.h"
#import "IphoneSubdownloadViewController.h"
#import "MediaPlayerViewController.h"
#import "AppDelegate.h"
@interface IphoneDownloadViewController ()

@end

@implementation IphoneDownloadViewController
@synthesize editButtonItem = editButtonItem_;
@synthesize doneButtonItem = doneButtonItem_;
@synthesize itemArr = itemArr_;
@synthesize progressArr = progressArr_;
@synthesize diskUsedProgress = diskUsedProgress_;
@synthesize progressLabelArr = progressLabelArr_;
@synthesize downLoadManager = downLoadManager_;
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
	// Do any additional setup after loading the view.
    self.title = @"视频缓存";
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:backGround];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"top_return_common.png"] forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton addTarget:self action:@selector(editPressed:) forControlEvents:UIControlEventTouchUpInside];
    editButton.frame = CGRectMake(0, 0, 63, 44);
    [editButton setImage:[UIImage imageNamed:@"download_edit.png"] forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"download_edit_s.png"] forState:UIControlStateHighlighted];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    editButtonItem_ = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = editButtonItem_;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
     doneButton.frame = CGRectMake(0, 0, 63, 44);
    [doneButton setImage:[UIImage imageNamed:@"download_done.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"download_done_s.png"] forState:UIControlStateHighlighted];
    [doneButton setTitle:@"done" forState:UIControlStateNormal];
    doneButtonItem_ = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    itemArr_ = [NSMutableArray arrayWithArray:[DownloadItem allObjects]];
    progressArr_ = [NSMutableArray arrayWithCapacity:5];
    progressLabelArr_ = [NSMutableArray arrayWithCapacity:5];
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 0, 320, kCurrentWindowHeight-30)];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gmGridView];
    gMGridView_ = gmGridView;
   
    NSInteger spacing = 20;
    gMGridView_.style = GMGridViewStyleSwap;
    gMGridView_.itemSpacing = spacing;
    gMGridView_.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    gMGridView_.centerGrid = NO;
    gMGridView_.actionDelegate = self;
    gMGridView_.dataSource = self;
    gMGridView_.mainSuperView = self.view;
    
    UIImageView *diskView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_download_3.png"]];
    diskView.frame = CGRectMake(0, kCurrentWindowHeight-74, 320, 30);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(66, 9, 42, 13)];
    label.text = @"存储容量";
    label.textColor = [UIColor colorWithRed:88/255 green:87/255 blue:87/255 alpha:1];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:9];
    [diskView addSubview:label];
    
    float percent = [self getFreeDiskspacePercent];
    UIImageView *diskFrame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_download_2.png"]];
    diskFrame.frame = CGRectMake(8, 6, 302, 18);
    [diskView addSubview:diskFrame];
    
    diskUsedProgress_ = [[DDProgressView alloc] initWithFrame:CGRectMake(7, 4, 306, 27)];
    diskUsedProgress_.progress = percent;
    diskUsedProgress_.innerColor = [UIColor colorWithRed:100/255.0 green:165/255.0 blue:248/255.0 alpha:1];
    diskUsedProgress_.outerColor = [UIColor clearColor];
    
    UILabel *spaceInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 200, 10)];
    spaceInfoLabel.text = [NSString stringWithFormat:@"总空间:%0.2fGB/剩余%0.2fGB",totalSpace_,totalFreeSpace_];
    spaceInfoLabel.textAlignment = NSTextAlignmentCenter;
    spaceInfoLabel.backgroundColor = [UIColor clearColor];
    spaceInfoLabel.font = [UIFont systemFontOfSize:8];
    spaceInfoLabel.textColor = [UIColor whiteColor];
    [diskUsedProgress_ addSubview:spaceInfoLabel];
    
    
    
    [diskView addSubview:diskUsedProgress_];
    
    [self.view addSubview:diskView];
    
    downLoadManager_ = [AppDelegate instance].downLoadManager;
    downLoadManager_.downLoadMGdelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:@"DELETE_ALL_SUBITEMS_MSG" object:nil];

}

- (void)viewWillAppear:(BOOL)animated{
    //重新将downLoadManager的代理指向self;
  downLoadManager_.downLoadMGdelegate = self;
}

-(void)initData{
    progressArr_ = [NSMutableArray arrayWithCapacity:5];
    progressLabelArr_ = [NSMutableArray arrayWithCapacity:5];
    itemArr_ = itemArr_ = [NSMutableArray arrayWithArray:[DownloadItem allObjects]];
}
-(void)reloadDataSource{
    [self initData];
    [gMGridView_ reloadData];
}
-(float)getFreeDiskspacePercent{

    NSError *error = nil;
     
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
   
    if (dictionary) {
        
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        
        totalSpace_ = [fileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
        
        totalFreeSpace_ = [freeFileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
    }
    float percent = (totalSpace_-totalFreeSpace_)/totalSpace_;
    
    return percent;
}

- (void)reFreshProgress:(double)progress withId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneDownloadViewController"]) {
        float value = (float)progress;
        for (UIProgressView *progress in progressArr_) {
            if (progress.tag == [itemId intValue]) {
                [progress setProgress:value];
                break;
            }
        }
        int progressValue = (int)(100*value);
        for (UILabel *label in progressLabelArr_) {
            if (label.tag == [itemId intValue]) {
                if (progressValue == 100) {
                    label.text = [NSString stringWithFormat:@"下载完成"];
                }
                else{
                    label.text = [NSString stringWithFormat:@"下载中：%i%%",progressValue];
                }
                break;
            }
        }
        

    }
}

- (void)downloadFailedwithId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneDownloadViewController"]){
        for (UILabel *label in progressLabelArr_){
            if (label.tag == [itemId intValue]){
                label.text = @"下载失败";
                break;
            }
        }
    }
}

-(void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)editPressed:(id)sender{
   gMGridView_.editing = YES;
    self.navigationItem.rightBarButtonItem = doneButtonItem_;
}

-(void)donePressed:(id)sender{
    gMGridView_.editing = NO;
   self.navigationItem.rightBarButtonItem = editButtonItem_;
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView{
    return [itemArr_ count];
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView{
    return CGSizeMake(78, 115);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index{
    DownloadItem *downloadItem = [itemArr_ objectAtIndex:index];
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
    
    UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_detailed_picture_bg"]];
    frame.frame = CGRectMake(0, 0, 78, 115);
    [cell.contentView addSubview:frame];
        
    UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(2, 2, 73, 110)];
    [contentImage setImageWithURL:[NSURL URLWithString:downloadItem.imageUrl] ];
    [cell.contentView addSubview:contentImage];
    
    if(downloadItem.type == 1){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(2, 92, 73, 20)];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.5;
        [cell.contentView addSubview:view];
        
        UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 92, 78, 10)];
        if([downloadItem.downloadStatus isEqualToString:@"loading"]){
            progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%", downloadItem.percentage];
        } else if([downloadItem.downloadStatus isEqualToString:@"stop"]){
            progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%", downloadItem.percentage];
        } else if([downloadItem.downloadStatus isEqualToString:@"finish"]){
            progressLabel.text = @"下载完成";
        } else if([downloadItem.downloadStatus isEqualToString:@"wait"]){
            progressLabel.text = [NSString stringWithFormat:@"等待中：%i%%", downloadItem.percentage];
        } else if([downloadItem.downloadStatus isEqualToString:@"fail"]){
            progressLabel.text = @"下载失败";
        }
        progressLabel.textColor = [UIColor whiteColor];
        progressLabel.tag = [downloadItem.itemId intValue];
        progressLabel.textAlignment = NSTextAlignmentCenter;
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.font = [UIFont systemFontOfSize:8];
        [progressLabelArr_ addObject:progressLabel];
        [cell.contentView addSubview:progressLabel];
        
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.frame = CGRectMake(5, 103, 68, 10);
        progressView.tag = [downloadItem.itemId intValue];
        progressView.progress = downloadItem.percentage/100.0;
        progressView.progressTintColor = [UIColor colorWithRed:62/255.0 green:138/255.0 blue:238/255.0 alpha:1];
        [progressArr_ addObject:progressView];
        [cell.contentView addSubview:progressView];
    }
    
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index
{
    [itemArr_ removeObjectAtIndex:index];
    
    //对于错误信息
    NSError *error;
    // 创建文件管理器
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //指向文件目录
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    
    DownloadItem *item = [[DownloadItem allObjects] objectAtIndex:index];
    NSString *itemId = item.itemId;
    //删除从表的内容
    NSString *subquery = [NSString stringWithFormat:@"WHERE item_id = '%@'",itemId];
    NSArray *subItems = [SubdownloadItem findByCriteria:subquery];
    for (SubdownloadItem *subItem in subItems) {
        [subItem deleteObject];
        [DownLoadManager stopAndClear:subItem.subitemId];
        
        NSString *deleteFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",subItem.name]];
        [fileMgr removeItemAtPath:deleteFilePath error:&error];
        
    }
    //停止该下载线程，并从下载队列中删除
    [DownLoadManager stopAndClear:itemId];
    
    //删除 对应的文件
    NSString *fileName = [item.name stringByAppendingString:@".mp4"];
  
   
    for (NSString *nameStr in fileList) {
        if ([nameStr isEqualToString:fileName]) {
            NSString *deleteFilePath = [documentsDirectory stringByAppendingPathComponent:nameStr];
            [fileMgr removeItemAtPath:deleteFilePath error:&error];
            break;
        }
    }
    

    [item deleteObject];
    
    
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position{
     DownloadItem *item = [[DownloadItem allObjects] objectAtIndex:position];
   
    if (item.type == 1) {
        if ([item.downloadStatus isEqualToString:@"finish"]) {
            NSString *fileName = [item.name stringByAppendingString:@".mp4"];
            //对于错误信息
            NSError *error;
            // 创建文件管理器
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            //指向文件目录
            NSString *documentsDirectory= [NSHomeDirectory()
                                           stringByAppendingPathComponent:@"Documents"];
            NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
            
            NSString *playPath = nil;
            for (NSString *str in fileList) {
                if ([str isEqualToString:fileName]) {
                    playPath = [documentsDirectory stringByAppendingPathComponent:str];
                    break;
                }
            }
            if (playPath) {
                MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
                viewController.videoUrl = playPath;
                viewController.prodId = item.itemId;
                viewController.name = item.name;
                viewController.subname = @"";
                viewController.isDownloaded = YES;
                viewController.type = 1;
                [self presentViewController:viewController animated:YES completion:nil];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"未找到影片" delegate:self
                                                      cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        
       else if ([item.downloadStatus isEqualToString:@"wait"] || [item.downloadStatus isEqualToString:@"loading"]) {
            item.downloadStatus = @"stop";
            [item save];
            [DownLoadManager stop:item.itemId];
            [self reloadDataSource];
        }
       else if ([item.downloadStatus isEqualToString:@"stop"] || [item.downloadStatus isEqualToString:@"fail"]){
           item.downloadStatus = @"wait";
           [item save];
           [DownLoadManager continueDownload:item.itemId];
           [self reloadDataSource];
       }
    
    }
    else{
        IphoneSubdownloadViewController *subdownloadViewController = [[IphoneSubdownloadViewController alloc] init];
        subdownloadViewController.prodId = item.itemId;
        subdownloadViewController.imageUrl = [NSURL URLWithString:item.imageUrl];
        subdownloadViewController.title = item.name;
        [self.navigationController pushViewController:subdownloadViewController animated:YES];
    
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
