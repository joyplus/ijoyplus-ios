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
#import "SubdownloadItem.h"
#import "AppDelegate.h"
#import "IphoneAVPlayerViewController.h"
#import "Reachability.h"
#import "CMConstants.h"
#import "SegmentUrl.h"
#import "DatabaseManager.h"
@interface IphoneSubdownloadViewController ()

@end

@implementation IphoneSubdownloadViewController
@synthesize editButtonItem = editButtonItem_;
@synthesize doneButtonItem = doneButtonItem_;
@synthesize prodId = prodId_;
@synthesize itemArr = itemArr_;
@synthesize imageUrl = imageUrl_;
@synthesize progressViewDic = progressViewDic_;
@synthesize progressLabelDic = progressLabelDic_;;
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
    backButton.frame = CGRectMake(0, 0, 49, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton addTarget:self action:@selector(editPressed:) forControlEvents:UIControlEventTouchUpInside];
    editButton.frame = CGRectMake(0, 0, 49, 30);
    [editButton setImage:[UIImage imageNamed:@"download_edit.png"] forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"download_edit_f.png"] forState:UIControlStateHighlighted];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    editButtonItem_ = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = editButtonItem_;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
    doneButton.frame = CGRectMake(0, 0, 49, 30);
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
    
    NSInteger spacing = 5;
    gMGridView_.style = GMGridViewStyleSwap;
    gMGridView_.itemSpacing = spacing;
    gMGridView_.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    gMGridView_.centerGrid = NO;
    gMGridView_.actionDelegate = self;
    gMGridView_.dataSource = self;
    gMGridView_.mainSuperView = self.view;
    
    downLoadManager_ = [AppDelegate instance].downLoadManager;
    downLoadManager_.downLoadMGdelegate = self;
    
}

-(void)initData{
    progressViewDic_ = [NSMutableDictionary dictionaryWithCapacity:5];
    progressLabelDic_ = [NSMutableDictionary dictionaryWithCapacity:5];
    
    NSString *queryString = [NSString stringWithFormat:@"where itemId = '%@'",prodId_];
    NSArray *items = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:queryString];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES comparator:cmptr1];
    itemArr_ = [NSMutableArray arrayWithArray: [items sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]]];
}
    NSComparator cmptr1 = ^(NSString *obj1, NSString * obj2){
        NSString *str1 = [[obj1 componentsSeparatedByString:@"_"]objectAtIndex:1];
        NSString *str2 = [[obj2 componentsSeparatedByString:@"_"]objectAtIndex:1];
        
        if ([str1 integerValue] > [str2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([str1 integerValue] < [str2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
-(void)reloadDataSource{
    [self initData];
    [gMGridView_ reloadData];
}

-(void)downloadBeginwithId:(NSString *)itemId inClass:(NSString *)className{
   
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]){
        int num = [self getTagNum:itemId];
        SubdownloadItem *subDownloadItem = [self getDownloadItemById:itemId];
        subDownloadItem.downloadStatus = @"loading";
        float percent = subDownloadItem.percentage/100.0;
        UIProgressView *progressView = [progressViewDic_ objectForKey:[NSString stringWithFormat:@"%d",num]];
        [progressView setProgress:percent];
        
        UILabel *label = [progressLabelDic_ objectForKey:[NSString stringWithFormat:@"%d",num]];
        label.text = [NSString stringWithFormat:@"下载中：%i%%\n ",subDownloadItem.percentage];
        
    }
    
}


- (void)reFreshProgress:(double)progress withId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]) {
        float value = (float)progress;
        int num = [self getTagNum:itemId];
        UIProgressView *progressView = [progressViewDic_ objectForKey:[NSString stringWithFormat:@"%d",num]];
        [progressView setProgress:value];
        int progressValue = (int)(100*value);
        
        SubdownloadItem *subDownloadItem = [self getDownloadItemById:itemId];
        subDownloadItem.percentage = progressValue;
        
        UILabel *label = [progressLabelDic_ objectForKey:[NSString stringWithFormat:@"%d",num]];
         label.text = [NSString stringWithFormat:@"下载中：%i%%\n ",progressValue];
    }
}

- (void)downloadFailedwithId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]){
        int num = [self getTagNum:itemId];
        SubdownloadItem *subDownloadItem = [self getDownloadItemById:itemId];
        subDownloadItem.downloadStatus = @"fail";
        
        UILabel *label = [progressLabelDic_ objectForKey:[NSString stringWithFormat:@"%d",num]];
        label.text = [NSString stringWithFormat:@"下载失败\n "];
    }
}

-(void)downloadUrlTnvalidWithId:(NSString *)itemId inClass:(NSString *)className{
    
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]){
        [self reloadDataSource];
    }
}

-(void)downloadFinishwithId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneSubdownloadViewController"]){
        int num = [self getTagNum:itemId];
        SubdownloadItem *subDownloadItem = [self getDownloadItemById:itemId];
        subDownloadItem.downloadStatus = @"finish";
        
        UIProgressView *progressView = [progressViewDic_ objectForKey:[NSString stringWithFormat:@"%d",num]];
        [progressView removeFromSuperview];
        UILabel *label = [progressLabelDic_ objectForKey:[NSString stringWithFormat:@"%d",num]];
        [label removeFromSuperview];
    }
    
}
-(void)updateFreeSapceWithTotalSpace:(float)total UsedSpace:(float)used{

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
    return CGSizeMake(100, 140);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index{
    SubdownloadItem *downloadItem = [itemArr_ objectAtIndex:index];
    CGSize size = [self sizeForItemsInGMGridView:gridView];
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        cell.deleteButtonOffset = CGPointMake(-3, -3);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor clearColor];
        cell.contentView = view;
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_detailed_picture_bg"]];
    frame.frame = CGRectMake(15, 15, 71, 104);
    [cell.contentView addSubview:frame];
    
    UIImageView *contentImage = [[UIImageView alloc]initWithFrame:CGRectMake(17, 17, 67, 99)];
    [contentImage setImageWithURL:imageUrl_];
    [cell.contentView addSubview:contentImage];
    
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(11, 123, 78, 15)];
    nameLbl.font = [UIFont systemFontOfSize:13];
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.textAlignment = NSTextAlignmentCenter;
    nameLbl.lineBreakMode = UILineBreakModeTailTruncation;
    nameLbl.numberOfLines = 0;
    if (downloadItem.type == 2) {
     
        NSString *sub_name = [[downloadItem.subitemId componentsSeparatedByString:@"_"] objectAtIndex:1];
        int num = [sub_name intValue];
        nameLbl.text = [NSString stringWithFormat:@"第%d集",num];
    }
    else if (downloadItem.type == 3){
        nameLbl.text =  [[downloadItem.name componentsSeparatedByString:@"_"] lastObject];
    }
    if ([nameLbl.text length]>5) {
        nameLbl.frame = CGRectMake(11, 123, 78, 30);
    }
    
    nameLbl.textColor = [UIColor blackColor];
    [cell.contentView addSubview:nameLbl];
    
    int tag = [self getTagNum:downloadItem.subitemId];
    UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 93, 67, 24)];
    progressLabel.textColor = [UIColor whiteColor];
    progressLabel.tag = tag;
    progressLabel.textAlignment = NSTextAlignmentCenter;
    progressLabel.backgroundColor = [UIColor blackColor];
    progressLabel.font = [UIFont systemFontOfSize:9];
    progressLabel.alpha = 0.6;
    progressLabel.numberOfLines = 0;
    progressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [progressLabelDic_ setObject:progressLabel forKey:[NSString stringWithFormat:@"%d",tag]];

    UIProgressView *progressView = nil;
    if (![downloadItem.downloadStatus isEqualToString:@"finish"] && ![downloadItem.downloadStatus isEqualToString:@"fail_1011"]) {
        
        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.frame = CGRectMake(20, 105, 62, 10);
        progressView.tag = tag;
        progressView.progress = downloadItem.percentage/100.0;
        progressView.progressTintColor = [UIColor colorWithRed:62/255.0 green:138/255.0 blue:238/255.0 alpha:1];
        [progressViewDic_ setObject:progressView forKey:[NSString stringWithFormat:@"%d",tag]];
    }
    
    if([downloadItem.downloadStatus isEqualToString:@"loading"]){
        progressLabel.text = [NSString stringWithFormat:@"下载中：%i%%\n ", downloadItem.percentage];
        [cell.contentView addSubview:progressLabel];
        [cell.contentView addSubview:progressView];
        
    } else if([downloadItem.downloadStatus isEqualToString:@"stop"]){
        progressLabel.text = [NSString stringWithFormat:@"暂停：%i%%\n ", downloadItem.percentage];
        [cell.contentView addSubview:progressLabel];
        [cell.contentView addSubview:progressView];
        
    } else if([downloadItem.downloadStatus isEqualToString:@"finish"]){
        
        progressLabel.text = @"";
        
    } else if([downloadItem.downloadStatus isEqualToString:@"waiting"]){
        progressLabel.text = [NSString stringWithFormat:@"等待中：%i%%\n ", downloadItem.percentage];
        // progressLabel.center = bgview.center;
        [cell.contentView addSubview:progressLabel];
        [cell.contentView addSubview:progressView];
    }
    else if([downloadItem.downloadStatus isEqualToString:@"fail"]){
        progressLabel.text = [NSString stringWithFormat:@"下载失败\n "];
        [cell.contentView addSubview:progressLabel];
        [cell.contentView addSubview:progressView];
        
    }
    else if([downloadItem.downloadStatus isEqualToString:@"fail_1011"]){
        progressLabel.text = [NSString stringWithFormat:@"下载片源失效"];
        //progressLabel.center = bgview.center;
        [cell.contentView addSubview:progressLabel];
    }
    return cell;
}


- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index{
    if (index >= [itemArr_ count]) {
        return;
    }
    
    [itemArr_ removeObjectAtIndex:index];
    NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",prodId_];
  
    NSArray *arr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
    SubdownloadItem *item = [arr objectAtIndex:index];
    NSString *itemId = item.subitemId;
    [DownLoadManager stopAndClear:itemId];
    
    NSString *fileName = [itemId stringByAppendingString:@".mp4"];
    //对于错误信息
    NSError *error;
    // 创建文件管理器
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //指向文件目录
    NSString *documentsDirectory= [NSHomeDirectory()
                                   stringByAppendingPathComponent:@"Documents"];
    
    
    NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    if ([item.fileName hasSuffix:@"m3u8"]) {
        NSString *deleteFilePath = [documentsDirectory stringByAppendingPathComponent:item.itemId];
        [fileMgr removeItemAtPath:deleteFilePath error:&error];
    }
    else{
        for (NSString *nameStr in fileList) {
            if ([nameStr hasPrefix:fileName]) {
                NSString *deleteFilePath = [documentsDirectory stringByAppendingPathComponent:nameStr];
                [fileMgr removeItemAtPath:deleteFilePath error:&error];
                break;
            }
        }
    }
   
    [DatabaseManager performSQLAggregation:[NSString stringWithFormat: @"delete from SegmentUrl WHERE itemId = '%@'",prodId_]];

    [DatabaseManager deleteObject:item];
    
    NSArray *tempArr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];

    if ([tempArr count] == 0){
        NSString *subquery = [NSString stringWithFormat:@"WHERE itemId ='%@'",prodId_];
        NSArray *itemArr = [DatabaseManager findByCriteria:[DownloadItem class] queryString:subquery];
        for (DownloadItem *downloadItem in itemArr) {
            [DatabaseManager deleteObject:downloadItem];
        }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DELETE_ALL_SUBITEMS_MSG" object:nil];
    }

}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position{
    
    if (position >= [itemArr_ count]) {
        return;
    }
    SubdownloadItem *downloadItem = [itemArr_ objectAtIndex:position];
    if ([downloadItem.downloadStatus isEqualToString:@"finish"]) {
        NSString *fileName = [downloadItem.subitemId stringByAppendingString:@".mp4"];
        NSError *error;
        // 创建文件管理器
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        //指向文件目录
        NSString *documentsDirectory= [NSHomeDirectory()
                                       stringByAppendingPathComponent:@"Documents"];
        NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
        
        NSString *playPath = nil;
        if (![downloadItem.downloadType isEqualToString:@"m3u8"]) {
            for (NSString *str in fileList) {
                if ([str isEqualToString:fileName]) {
                    playPath = [documentsDirectory stringByAppendingPathComponent:str];
                    break;
                }
            }
        }
        else{
            [[AppDelegate instance] startHttpServer];
            NSString *idStr = downloadItem.subitemId ;
            NSArray *tempArr =  [idStr componentsSeparatedByString:@"_"];
            playPath =[NSString stringWithFormat:@"%@/%@/%@/%@.m3u8",LOCAL_HTTP_SERVER_URL,downloadItem.itemId,idStr,[tempArr objectAtIndex:1]];
        }
        if (playPath) {
            IphoneAVPlayerViewController *iphoneAVPlayerViewController = [[IphoneAVPlayerViewController alloc] init];
            iphoneAVPlayerViewController.local_file_path = playPath;
            if ([downloadItem.downloadType isEqualToString:@"m3u8"]){
              iphoneAVPlayerViewController.isM3u8 = YES;
              iphoneAVPlayerViewController.playDuration = downloadItem.duration;
              iphoneAVPlayerViewController.lastPlayTime = CMTimeMake(1, NSEC_PER_SEC);
            }
            iphoneAVPlayerViewController.islocalFile = YES;
            if (downloadItem.type == 2) {
                NSString *name = [[downloadItem.name componentsSeparatedByString:@"_"] objectAtIndex:0];
                NSString *sub_name = [[downloadItem.subitemId componentsSeparatedByString:@"_"] objectAtIndex:1];
                int num = [sub_name intValue];
                iphoneAVPlayerViewController.nameStr = [NSString stringWithFormat:@"%@ 第%d集",name,num];
            }
            else if (downloadItem.type == 3){
                iphoneAVPlayerViewController.nameStr =  [[downloadItem.name componentsSeparatedByString:@"_"] lastObject];
            }
            [self presentViewController:iphoneAVPlayerViewController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"未找到影片" delegate:self
                                                  cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
            [alert show];
        }

    }
   else if ([downloadItem.downloadStatus isEqualToString:@"waiting"] || [downloadItem.downloadStatus isEqualToString:@"loading"]) {
       Reachability *hostReach = [Reachability reachabilityForInternetConnection];
       if([hostReach currentReachabilityStatus] == NotReachable){
           
           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络中断，请检查您的网络。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
           [alert show];
           return;
       }
       
        downloadItem.downloadStatus = @"stop";
        //[downloadItem save];
       [DatabaseManager update:downloadItem];
        [DownLoadManager stop:downloadItem.subitemId];
       
       int num = [self getTagNum:downloadItem.subitemId];
       UILabel *label = [progressLabelDic_ objectForKey:[NSString stringWithFormat:@"%d",num]];
       label.text =  [NSString stringWithFormat:@"暂停：%i%%\n ", downloadItem.percentage];
       
       UIProgressView *progressView = [progressViewDic_ objectForKey:[NSString stringWithFormat:@"%d",num]];
       progressView.progress = downloadItem.percentage/100.0;
       
    }
    else if ([downloadItem.downloadStatus isEqualToString:@"stop"]||[downloadItem.downloadStatus isEqualToString:@"fail"]){
        Reachability *hostReach = [Reachability reachabilityForInternetConnection];
        if([hostReach currentReachabilityStatus] == NotReachable){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络中断，请检查您的网络。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        downloadItem.downloadStatus = @"waiting";
        //[downloadItem save];
        [DatabaseManager update:downloadItem];
        int num = [self getTagNum:downloadItem.subitemId];
        UILabel *label = [progressLabelDic_ objectForKey:[NSString stringWithFormat:@"%d",num]];
        label.text =  [NSString stringWithFormat:@"等待中：%i%%\n ", downloadItem.percentage];
        
        UIProgressView *progressView = [progressViewDic_ objectForKey:[NSString stringWithFormat:@"%d",num]];
        progressView.progress = downloadItem.percentage/100.0;
         
       [DownLoadManager continueDownload:downloadItem.subitemId];
    
    }


}

-(SubdownloadItem *)getDownloadItemById:(NSString *)idstr{
    for (SubdownloadItem *item in itemArr_) {
        if ([item.subitemId isEqualToString:idstr]) {
            return item;
        }
    }
    return nil;
}

-(int)getTagNum:(NSString *)str{
  NSString *numStr = [[str componentsSeparatedByString:@"_"] lastObject];
  NSString *idStr = [[str componentsSeparatedByString:@"_"] objectAtIndex:0];
 return  [idStr intValue]*10 +[numStr intValue];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
