//
//  IphoneSubdownloadViewController.m
//  yueshipin
//
//  Created by 08 on 13-1-22.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "IphoneSubdownloadViewController.h"
#import "UIImageView+WebCache.h"
#import "DownLoadManager.h"
#import "McDownload.h"
#import "SubdownloadItem.h"
#import "AppDelegate.h"
#import "MyMediaPlayerViewController.h"
@interface IphoneSubdownloadViewController ()

@end

@implementation IphoneSubdownloadViewController
@synthesize editButtonItem = editButtonItem_;
@synthesize doneButtonItem = doneButtonItem_;
@synthesize prodId = prodId_;
@synthesize itemArr = itemArr_;
@synthesize imageUrl = imageUrl_;
@synthesize progressArr = progressArr_;
@synthesize progressLabelArr = progressLabelArr_;
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
    editButton.frame = CGRectMake(0, 0, 37, 30);
    [editButton setImage:[UIImage imageNamed:@"download_edit.png"] forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"download_edit_s.png"] forState:UIControlStateHighlighted];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    editButtonItem_ = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = editButtonItem_;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
    doneButton.frame = CGRectMake(0, 0, 37, 30);
    [doneButton setImage:[UIImage imageNamed:@"download_done.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"download_done_s.png"] forState:UIControlStateHighlighted];
    [doneButton setTitle:@"done" forState:UIControlStateNormal];
    doneButtonItem_ = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    
    //初始化数据
    [self initData];
    
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 0, 320, kCurrentWindowHeight)];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gmGridView];
    gMGridView_ = gmGridView;
    
    NSInteger spacing = 25;
    gMGridView_.style = GMGridViewStyleSwap;
    gMGridView_.itemSpacing = spacing;
    gMGridView_.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    gMGridView_.centerGrid = NO;
    gMGridView_.actionDelegate = self;
    gMGridView_.dataSource = self;
    gMGridView_.mainSuperView = self.view;
    
    downLoadManager_ = [AppDelegate instance].downLoadManager;
    downLoadManager_.downLoadMGdelegate = self;
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}
-(void)initData{
    progressArr_ = [NSMutableArray arrayWithCapacity:5];
    progressLabelArr_ = [NSMutableArray arrayWithCapacity:5];
    itemArr_ = [NSMutableArray arrayWithCapacity:5];
    NSArray *items = [SubdownloadItem allObjects];
    for (SubdownloadItem *item in items) {
        if ([item.subitemId hasPrefix:prodId_]) {
            [itemArr_ addObject:item];
        }
    }
}
-(void)reloadDataSource{
    [self initData];
    [gMGridView_ reloadData];
}

-(void)downloadBeginwithId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]){
        NSArray *arr = [itemId componentsSeparatedByString:@"_"];
        int num = [[arr objectAtIndex:0] intValue]*10+[[arr objectAtIndex:1] intValue];
        for (UILabel *label in progressLabelArr_) {
            if (label.tag == num) {
                label.text = [NSString stringWithFormat:@"正在下载：0%%"];
                break;
                
            }
            
        }
    }
    
}


- (void)reFreshProgress:(double)progress withId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]) {
        float value = (float)progress;
        NSArray *arr = [itemId componentsSeparatedByString:@"_"];
        int num = [[arr objectAtIndex:0] intValue]*10+[[arr objectAtIndex:1] intValue];
        for (UIProgressView *progress in progressArr_) {
            if (progress.tag == num) {
                [progress setProgress:value];
                break;
            }
        }
        int progressValue = (int)(100*value);
        for (UILabel *label in progressLabelArr_) {
            if (label.tag == num) {
                if (progressValue == 100) {
                   // label.text = [NSString stringWithFormat:@"下载完成"];
                }
                else{
                    label.text = [NSString stringWithFormat:@"正在下载：%i%%",progressValue];
                }
                break;
            }
        }

    }
    
}
- (void)downloadFailedwithId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]){
        for (UILabel *label in progressLabelArr_){
            if (label.tag == [itemId intValue]){
               // label.text = @"暂停下载";
                break;
            }
        }
    }
}
-(void)downloadFinishwithId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]){
        
        [gMGridView_ reloadData];
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
    return CGSizeMake(70, 124);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index{
    SubdownloadItem *downloadItem = [itemArr_ objectAtIndex:index];
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
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_detailed_picture_bg"]];
    frame.frame = CGRectMake(0, 0, 71, 104);
    [cell.contentView addSubview:frame];
    
    UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(2, 2, 67, 99)];
    [contentImage setImageWithURL:imageUrl_];
    [cell.contentView addSubview:contentImage];
    
    NSString *numStr = [[downloadItem.subitemId componentsSeparatedByString:@"_"] lastObject];
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(2, 108, 67, 15)];
    nameLbl.font = [UIFont systemFontOfSize:13];
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.textAlignment = NSTextAlignmentCenter;
    nameLbl.text = [NSString stringWithFormat:@"第%@集",numStr];;
    nameLbl.textColor = [UIColor blackColor];
    [cell.contentView addSubview:nameLbl];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(2, 82, 67, 20)];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.5;
    
    
    UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 82, 67, 10)];
    progressLabel.textColor = [UIColor whiteColor];
    progressLabel.tag = 10*[downloadItem.itemId intValue]+[numStr intValue];
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.backgroundColor = [UIColor clearColor];
    progressLabel.font = [UIFont systemFontOfSize:8];
    [progressLabelArr_ addObject:progressLabel];
    
    
    if([downloadItem.downloadStatus isEqualToString:@"loading"]){
        progressLabel.text = [NSString stringWithFormat:@"正在下载：%i%%",downloadItem.percentage];
    } else if([downloadItem.downloadStatus isEqualToString:@"stop"]){
        progressLabel.text = [NSString stringWithFormat:@"暂停下载：%i%%", downloadItem.percentage];
    } else if([downloadItem.downloadStatus isEqualToString:@"finish"]){
        progressLabel.text = @"";
    } else if([downloadItem.downloadStatus isEqualToString:@"wait"]){
        progressLabel.text = [NSString stringWithFormat:@"等待下载：%i%%", downloadItem.percentage];
    } else if([downloadItem.downloadStatus isEqualToString:@"fail"]){
        progressLabel.text = [NSString stringWithFormat:@"正在下载：%i%%",downloadItem.percentage];
    }
    
    if(![downloadItem.downloadStatus isEqualToString:@"finish"]){
        [cell.contentView addSubview:view];
        [cell.contentView addSubview:progressLabel];
        
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.frame = CGRectMake(5, 92, 62, 10);
        progressView.tag = 10*[downloadItem.itemId intValue]+[numStr intValue];
        progressView.progress = downloadItem.percentage/100.0;
        progressView.progressTintColor = [UIColor colorWithRed:62/255.0 green:138/255.0 blue:238/255.0 alpha:1];
        [progressArr_ addObject:progressView];
        [cell.contentView addSubview:progressView];
    }
    
    
 
    return cell;
}


- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index{
    [itemArr_ removeObjectAtIndex:index];
    NSString *query = [NSString stringWithFormat:@"WHERE item_id ='%@'",prodId_];
    NSArray *arr = [SubdownloadItem findByCriteria:query];
    SubdownloadItem *item = [arr objectAtIndex:index];
    NSString *itemId = item.subitemId;
    [DownLoadManager stopAndClear:itemId];
    
    NSString *fileName = [item.name stringByAppendingString:@".mp4"];
    //对于错误信息
    NSError *error;
    // 创建文件管理器
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //指向文件目录
    NSString *documentsDirectory= [NSHomeDirectory()
                                   stringByAppendingPathComponent:@"Documents"];
    NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    for (NSString *nameStr in fileList) {
        if ([nameStr isEqualToString:fileName]) {
            NSString *deleteFilePath = [documentsDirectory stringByAppendingPathComponent:nameStr];
            [fileMgr removeItemAtPath:deleteFilePath error:&error];
            break;
        }
    }

    [item deleteObject];
    
     NSArray *tempArr = [SubdownloadItem findByCriteria:query];
    
    if ([tempArr count] == 0) {
        NSString *subquery = [NSString stringWithFormat:@"WHERE item_id ='%@'",prodId_];
        NSArray *itemArr = [DownloadItem findByCriteria:subquery];
        for (DownloadItem *downloadItem in itemArr) {
            [downloadItem deleteObject];
        }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DELETE_ALL_SUBITEMS_MSG" object:nil];
    }

}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position{
    
    SubdownloadItem *downloadItem = [itemArr_ objectAtIndex:position];
    if ([downloadItem.downloadStatus isEqualToString:@"finish"]) {
        NSString *fileName = [downloadItem.name stringByAppendingString:@".mp4"];
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
//            MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
//            viewController.videoUrl = playPath;
//            viewController.prodId = prodId_;
//            viewController.name = self.title;
//            viewController.subname = [[downloadItem.subitemId componentsSeparatedByString:@"_"] lastObject];
//            viewController.isDownloaded = YES;
//            viewController.type = downloadItem.type;
//            [self presentViewController:viewController animated:YES completion:nil];
            MyMediaPlayerViewController *viewController = [[MyMediaPlayerViewController alloc]init];
            viewController.isDownloaded = YES;
            viewController.closeAll = YES;
            NSMutableArray *urlsArray = [[NSMutableArray alloc]initWithCapacity:1];
            [urlsArray addObject:playPath];
            viewController.videoUrls = urlsArray;
            viewController.prodId = downloadItem.itemId;
            viewController.type = downloadItem.type;
            viewController.name = self.title;
            viewController.subname = downloadItem.name;
            viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"未找到影片" delegate:self
                                                  cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
            [alert show];
        }

    }
   else if ([downloadItem.downloadStatus isEqualToString:@"wait"] || [downloadItem.downloadStatus isEqualToString:@"loading"]) {
        downloadItem.downloadStatus = @"stop";
        [downloadItem save];
        [DownLoadManager stop:downloadItem.subitemId];
        [self reloadDataSource];
    }
    else if ([downloadItem.downloadStatus isEqualToString:@"stop"]||[downloadItem.downloadStatus isEqualToString:@"fail"]){
        downloadItem.downloadStatus = @"wait";
        [downloadItem save];
        [DownLoadManager continueDownload:downloadItem.subitemId];
        [self reloadDataSource];
    }


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
