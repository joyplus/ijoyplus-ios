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
#import "SegmentUrl.h"
#import "IphoneSubdownloadViewController.h"
#import "AppDelegate.h"
#import "IphoneAVPlayerViewController.h"
#import "Reachability.h"
#import "CMConstants.h"
#import "DatabaseManager.h"
#import "CacheUtility.h"

@interface IphoneDownloadViewController ()
{
    NSInteger delItemIndex;
    GMGridView * delItem;
}
- (void)deleteItemWithIndex:(NSInteger)index;
@end

@implementation IphoneDownloadViewController
@synthesize editButtonItem = editButtonItem_;
@synthesize doneButtonItem = doneButtonItem_;
@synthesize itemArr = itemArr_;
@synthesize progressViewDic = progressViewDic_;
@synthesize diskUsedProgress = diskUsedProgress_;
@synthesize progressLabelDic = progressLabelDic_;
@synthesize downLoadManager = downLoadManager_;
@synthesize noItemView = noItemView_;
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
    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(220, 0, 80, 50)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor=[UIColor whiteColor];
    [titleText setFont:[UIFont boldSystemFontOfSize:20.0]];
    [titleText setText:@"本地视频"];
    titleText.shadowColor = [UIColor colorWithRed:121.0/255 green:64.0/255 blue:0 alpha:1];
    titleText.center = self.navigationItem.titleView.center;
    self.navigationItem.titleView=titleText;
    
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:backGround];
    
    self.navigationItem.hidesBackButton = YES;
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton addTarget:self action:@selector(editPressed:) forControlEvents:UIControlEventTouchUpInside];
    editButton.frame = CGRectMake(0, 0, 55, 44);
    [editButton setImage:[UIImage imageNamed:@"download_edit.png"]
                forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"download_edit_f.png"]
                forState:UIControlStateHighlighted];
    editButtonItem_ = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
    doneButton.frame = CGRectMake(0, 0, 55, 44);
    [doneButton setImage:[UIImage imageNamed:@"download_done.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"download_done_s.png"] forState:UIControlStateHighlighted];
    doneButtonItem_ = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(0, 0, 320, kCurrentWindowHeight-30)];
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
    
    noItemView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wuxiazai"]];
    noItemView_.frame = CGRectMake(0, 0, 175, 12);
    noItemView_.center = CGPointMake(160, 160);
    [self.view addSubview:noItemView_];
    
    delItemIndex = NSNotFound;
    
    UIView * spaceBackground = [[UIView alloc] initWithFrame:CGRectMake(0, kCurrentWindowHeight - 140 + 27, 320, 20)];
    spaceBackground.backgroundColor = [UIColor colorWithRed:170.0f/255.0f green:170.0f/255.0f blue:161.0f/255.0f alpha:0.6f];
    
    float freePresent = [self getFreeDiskspacePercent];
    
    innerView = [[UIView alloc] initWithFrame:CGRectMake(0, 1, 320 * freePresent, 18)];
    innerView.backgroundColor = [CMConstants yellowColor];//[UIColor colorWithRed:247/255.0 green:100/255.0 blue:136/255.0 alpha:1];
    innerView.tag = 12345;
    [spaceBackground addSubview:innerView];
    
    [self.view addSubview:spaceBackground];
    
    spaceInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    spaceInfoLabel.text = [NSString stringWithFormat:@"共:%0.2fGB/ 剩余%0.2fGB",totalSpace_,totalFreeSpace_];
    spaceInfoLabel.textAlignment = NSTextAlignmentCenter;
    spaceInfoLabel.backgroundColor = [UIColor clearColor];
    spaceInfoLabel.font = [UIFont systemFontOfSize:10];
    spaceInfoLabel.textColor = [UIColor whiteColor];
    spaceInfoLabel.tag = 12346;
    [spaceBackground addSubview:spaceInfoLabel];
    
    downLoadManager_ = [AppDelegate instance].downLoadManager;
    downLoadManager_.downLoadMGdelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:@"DELETE_ALL_SUBITEMS_MSG" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDiskSpace) name:APPLICATION_DID_BECOME_ACTIVE_NOTIFICATION object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self updateDiskSpace];
    
    [self initData];
    //重新将downLoadManager的代理指向self;
    downLoadManager_.downLoadMGdelegate = self;
    [gMGridView_ reloadData];
    if (0 != itemArr_.count)
    {
        self.navigationItem.rightBarButtonItem = editButtonItem_;
        if (noItemView_) {
            noItemView_.hidden = YES;
        }
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
        noItemView_.hidden = NO;
        
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    for (id obj in itemArr_)
    {
        if (![obj isKindOfClass:[SubdownloadItem class]])
        {
            [DatabaseManager update:obj];
        }
    }
    gMGridView_.editing = NO;
}

-(void)initData{
    progressViewDic_ = [NSMutableDictionary dictionaryWithCapacity:5];
    progressLabelDic_ = [NSMutableDictionary dictionaryWithCapacity:5];
    
    isItunesFile = NO;
    
    if (![[AppDelegate instance].showVideoSwitch isEqualToString:@"0"]){
        isItunesFile = YES;
        itemArr_ = [NSMutableArray arrayWithArray:[self getItunesSyncItems]];
    }
    else{
       itemArr_ = [NSMutableArray arrayWithArray:[DatabaseManager allObjects:[DownloadItem class]]];
    }
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
            tempDbObj.downloadStatus = @"finish";
            tempDbObj.type = 1;
            tempDbObj.percentage = 100;
            tempDbObj.downloadType = @"mp4";
            [arr addObject:tempDbObj];
        }
    }
    return arr;
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

-(void)updateDiskSpace{
    
    innerView.frame = CGRectMake(0, 1, 320 * [self getFreeDiskspacePercent], 18);
    spaceInfoLabel.text = [NSString stringWithFormat:@"共:%0.2fGB/ 剩余%0.2fGB",totalSpace_,totalFreeSpace_];
}
-(void)downloadBeginwithId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneDownloadViewController"]){
        DownloadItem *item = [self getDownloadItemById:itemId];
        float percent = item.percentage/100.0;
        item.downloadStatus = @"loading";
        UIProgressView *progressView = [progressViewDic_ objectForKey:itemId];
        [progressView setProgress:percent];
        UILabel *label = [progressLabelDic_ objectForKey:itemId];
        label.text = [NSString stringWithFormat:@"下载中：%i%%\n ",item.percentage];
    }
}
- (void)reFreshProgress:(DownloadItem *)dlItem withId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneDownloadViewController"]) {
        DownloadItem *item = [self getDownloadItemById:itemId];
        if ([item.downloadStatus isEqualToString:@"loading"]) {
            float value = (float)(dlItem.percentage/100.0f);
            UIProgressView *progressView = [progressViewDic_ objectForKey:itemId];
            [progressView setProgress:value];
            
            int progressValue = (int)(100*value);
            
            item.percentage = progressValue;
            item.m3u8DownloadInfo = dlItem.m3u8DownloadInfo;
            
            UILabel *label = [progressLabelDic_ objectForKey:itemId];
            label.text = [NSString stringWithFormat:@"下载中：%i%%\n ",progressValue];
            
        }
    }
}

-(void)downloadFinishwithId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneDownloadViewController"]){
        DownloadItem *item = [self getDownloadItemById:itemId];
        item.downloadStatus = @"finish";
        item.percentage = 100;
        
        UIProgressView *progressView = [progressViewDic_ objectForKey:itemId];
        [progressView removeFromSuperview];
        UILabel *label = [progressLabelDic_ objectForKey:itemId];
        [label removeFromSuperview];
    }
    
}

- (void)downloadFailedwithId:(NSString *)itemId inClass:(NSString *)className{
    if ([className isEqualToString:@"IphoneDownloadViewController"]){
        UILabel *label = [progressLabelDic_ objectForKey:itemId];
        label.text = [NSString stringWithFormat:@"下载失败\n "];
        DownloadItem *item = [self getDownloadItemById:itemId];
        item.downloadStatus = @"fail";
    }
}
-(void)downloadUrlTnvalidWithId:(NSString *)itemId inClass:(NSString *)className{
    
    if ([className isEqualToString:@"IphoneDownloadViewController"]){
        [self reloadDataSource];
    }
}
-(void)reFreshUI{
    [self reloadDataSource];
}
-(void)updateFreeSapceWithTotalSpace:(float)total UsedSpace:(float)used{
    UIView *view = [self.view viewWithTag:12345];
    float freePresent = used /total ;
    view.frame = CGRectMake(0, 1, 320 * freePresent, 18);
    UILabel *label = (UILabel *)[self.view viewWithTag:12346];
    label.text = [NSString stringWithFormat:@"共:%0.2fGB/ 剩余%0.2fGB",total,(total-used)];
    
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
    if (0 != itemArr_.count)
    {
        self.navigationItem.rightBarButtonItem = editButtonItem_;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView{
    return [itemArr_ count];
}

- (CGSize)sizeForItemsInGMGridView:(GMGridView *)gridView{
    return CGSizeMake(100, 140);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index{
    DownloadItem *downloadItem = [itemArr_ objectAtIndex:index];
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
    [contentImage setImageWithURL:[NSURL URLWithString:downloadItem.imageUrl] ];
    [cell.contentView addSubview:contentImage];
    
    UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(17, 123, 67, 21)];
    nameLbl.font = [UIFont systemFontOfSize:13];
    nameLbl.backgroundColor = [UIColor clearColor];
    nameLbl.text = downloadItem.name;
    nameLbl.textColor = [UIColor blackColor];
    nameLbl.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:nameLbl];
    
    if(downloadItem.type == 1){
        UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 93, 67, 24)];
        progressLabel.textColor = [UIColor whiteColor];
        progressLabel.tag = [downloadItem.itemId intValue];
        progressLabel.textAlignment = NSTextAlignmentCenter;
        progressLabel.backgroundColor = [UIColor blackColor];
        progressLabel.font = [UIFont systemFontOfSize:9];
        progressLabel.alpha = 0.6;
        progressLabel.numberOfLines = 0;
        progressLabel.lineBreakMode = NSLineBreakByWordWrapping;
        //[progressLabel drawTextInRect:CGRectMake(17, 93, 67, 15)];
        [progressLabelDic_ setObject:progressLabel forKey:downloadItem.itemId];
        
        UIProgressView *progressView = nil;
        if (![downloadItem.downloadStatus isEqualToString:@"finish"] && ![downloadItem.downloadStatus isEqualToString:@"fail_1011"]) {
            
            progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            progressView.frame = CGRectMake(20, 105, 62, 10);
            progressView.tag = [downloadItem.itemId intValue];
            progressView.progress = downloadItem.percentage/100.0;
            progressView.progressTintColor = [UIColor colorWithRed:62/255.0 green:138/255.0 blue:238/255.0 alpha:1];
            [progressViewDic_ setObject:progressView forKey:downloadItem.itemId];
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
            [cell.contentView addSubview:progressLabel];
        }
        
    }
    else{
        NSString *query = [NSString stringWithFormat:@"WHERE itemId ='%@'",downloadItem.itemId];
        NSArray *arr = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:query];
        UILabel *labeltotal = [[UILabel alloc] initWithFrame:CGRectMake(17, 97, 67, 20)];
        labeltotal.text = [NSString stringWithFormat:@"共%d集",[arr count]];
        labeltotal.textColor = [UIColor whiteColor];
        labeltotal.textAlignment = NSTextAlignmentCenter;
        labeltotal.backgroundColor = [UIColor blackColor];
        labeltotal.alpha = 0.6;
        labeltotal.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:labeltotal];
        
    }
    
    return cell;
}

- (void)GMGridView:(GMGridView *)gridView deleteItemAtIndex:(NSInteger)index
{
    if (index >= [itemArr_ count]) {
        return;
    }
    
    delItemIndex = index;
    delItem = gridView;
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"是否确认删除所选视频"
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                           otherButtonTitles:@"确定", nil];
    [alert show];
    
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position{
    if (position >= [itemArr_ count]) {
        return;
    }
    
    //DownloadItem *item = [[DatabaseManager allObjects:[DownloadItem class]] objectAtIndex:position];
    DownloadItem *item = [itemArr_ objectAtIndex:position];
    if (item.type == 1) {
        
        if ([item.downloadStatus isEqualToString:@"finish"]) {
            
            //对于错误信息
            NSError *error;
            // 创建文件管理器
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            //指向文件目录
            NSString *documentsDirectory= [NSHomeDirectory()
                                           stringByAppendingPathComponent:@"Documents"];
            NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
            
            NSString *playPath = nil;
            
            if (![item.downloadType isEqualToString:@"m3u8"]) {
                if (!isItunesFile) {
                    NSString *fileName = [item.itemId stringByAppendingString:@".mp4"];
                    for (NSString *str in fileList) {
                        if ([str isEqualToString:fileName]) {
                            playPath = [documentsDirectory stringByAppendingPathComponent:str];
                            break;
                        }
                    }
                }
                else{
                  playPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",item.fileName]];
                }
                
            }
            else{
                [[AppDelegate instance] startHttpServer];
                NSString *subPath = [NSString stringWithFormat:@"%@_%@",item.itemId,@"1"];
                playPath =[NSString stringWithFormat:@"%@/%@/%@/1.m3u8",LOCAL_HTTP_SERVER_URL, item.itemId,subPath];
            }
            
            if (playPath) {
                IphoneAVPlayerViewController *iphoneAVPlayerViewController = [[IphoneAVPlayerViewController alloc] init];
                iphoneAVPlayerViewController.local_file_path = playPath;
                if ([item.downloadType isEqualToString:@"m3u8"]){
                    iphoneAVPlayerViewController.isM3u8 = YES;
                    iphoneAVPlayerViewController.playDuration = item.duration;
                    
                    
                }
                NSString *str = [NSString stringWithFormat:@"%@_1",item.itemId];
                NSNumber *cacheResult = [[CacheUtility sharedCache] loadFromCache:str];
                iphoneAVPlayerViewController.lastPlayTime = CMTimeMakeWithSeconds(cacheResult.floatValue + 1, NSEC_PER_SEC);
                
                iphoneAVPlayerViewController.islocalFile = YES;
                iphoneAVPlayerViewController.nameStr = item.name;
                iphoneAVPlayerViewController.prodId = item.itemId;
                iphoneAVPlayerViewController.playNum = 0;
                iphoneAVPlayerViewController.videoType = 1;
                [self presentViewController:iphoneAVPlayerViewController animated:YES completion:nil];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"未找到影片" delegate:self
                                                      cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        
        else if ([item.downloadStatus isEqualToString:@"waiting"]
                 || [item.downloadStatus isEqualToString:@"loading"])
        {
            if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络中断，请检查您的网络。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            
            item.downloadStatus = @"stop";
            
            [DownLoadManager stop:item.itemId];
            
            [DatabaseManager update:item];
            
            UILabel *label = [progressLabelDic_ objectForKey:item.itemId];
            label.text =  [NSString stringWithFormat:@"暂停：%i%%\n ", item.percentage];
            UIProgressView *progressView = [progressViewDic_ objectForKey:item.itemId];
            progressView.progress = item.percentage/100.0;
            
        }
        else if ([item.downloadStatus isEqualToString:@"stop"] || [item.downloadStatus isEqualToString:@"fail"]){
            //Reachability *hostReach = [Reachability reachabilityForInternetConnection];
            if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络中断，请检查您的网络。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
            
            if ([item.downloadStatus isEqualToString:@"fail"]
                && [item.downloadType isEqualToString:@"m3u8"])
            {
                [DatabaseManager performSQLAggregation:[NSString stringWithFormat: @"delete from SegmentUrl WHERE itemId like '%@%%'", item.itemId]];
                NSError *error;
                NSFileManager *fileMgr = [NSFileManager defaultManager];
                NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                NSString *deletePath = [documentsDirectory stringByAppendingPathComponent:item.itemId];
                [fileMgr removeItemAtPath:deletePath error:&error];
                
                
                item.percentage = 0;
                item.m3u8DownloadInfo = [NSMutableArray array];
            }
            
            item.downloadStatus = @"waiting";
            [DatabaseManager update:item];
            UILabel *label = [progressLabelDic_ objectForKey:item.itemId];
            label.text = [NSString stringWithFormat:@"等待中：%i%%\n ", item.percentage];
            
            UIProgressView *progressView = [progressViewDic_ objectForKey:item.itemId];
            progressView.progress = item.percentage/100.0;
            
            [DownLoadManager continueDownload:item.itemId];
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
-(DownloadItem *)getDownloadItemById:(NSString *)idstr{
    for (DownloadItem *item in itemArr_) {
        if ([item.itemId isEqualToString:idstr]) {
            return item;
        }
    }
    return nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deleteItemWithIndex:(NSInteger)index
{
   
    //对于错误信息
    NSError *error;
    // 创建文件管理器
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //指向文件目录
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    
    DownloadItem *item = [itemArr_ objectAtIndex:index];
    NSString *itemId = item.itemId;
    NSString *subquery = [NSString stringWithFormat:@"WHERE itemId = '%@'",itemId];
    if ([item.downloadType isEqualToString:@"m3u8"]) {   //m3u8 直接删除对应的文件夹
        //NSArray *arr = [SegmentUrl findByCriteria:subquery];
        [DatabaseManager performSQLAggregation:[NSString stringWithFormat: @"delete from SegmentUrl WHERE itemId = %@", itemId]];
        NSString *deletePath = [documentsDirectory stringByAppendingPathComponent:itemId];
        [fileMgr removeItemAtPath:deletePath error:&error];
        [DownLoadManager stop:itemId];
        [DownLoadManager stopAndClear:itemId];
        
    }
    else{
        
        //删除从表的内容
        NSArray *subItems = [DatabaseManager findByCriteria:[SubdownloadItem class] queryString:subquery];
        //NSArray *subItems = [SubdownloadItem findByCriteria:subquery];
        for (SubdownloadItem *subItem in subItems) {
            [DownLoadManager stopAndClear:subItem.subitemId];
        }
        [DatabaseManager performSQLAggregation:[NSString stringWithFormat: @"delete from SegmentUrl WHERE itemId like '%@%%'", itemId]];
        [DatabaseManager performSQLAggregation:[NSString stringWithFormat: @"delete from SubdownloadItem WHERE itemId = '%@'", itemId]];
        
        
        
        //停止该下载线程，并从下载队列中删除
        [DownLoadManager stopAndClear:itemId];
        
        //删除 对应的文件
        if (!isItunesFile) {
            for (NSString *nameStr in fileList) {
                if (/*[nameStr hasPrefix:fileName] || [nameStr hasPrefix:subfileName]||*/[nameStr hasPrefix:itemId]) {
                    NSString *deleteFilePath = [documentsDirectory stringByAppendingPathComponent:nameStr];
                    [fileMgr removeItemAtPath:deleteFilePath error:&error];
                }
            }
        }
        else{
            NSString *deleteFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",item.fileName]];
            [fileMgr removeItemAtPath:deleteFilePath error:&error];
        }
    
        
    }
    
    [itemArr_ removeObjectAtIndex:index];
    [DownLoadManager stopAndClear:itemId];
    [DatabaseManager deleteObject:item];
    [[DownLoadManager defaultDownLoadManager]waringPlus];
    
    [self updateDiskSpace];
}

-(void)DownLoadManagerUpdateIsDownloadingNumberwithId:(NSString *)itemId
                                               number:(int)num
                                              inClass:(NSString*)className
{
    
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
