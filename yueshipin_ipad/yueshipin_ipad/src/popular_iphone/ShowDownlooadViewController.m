//
//  ShowDownlooadViewController.m
//  yueshipin
//
//  Created by 08 on 13-1-25.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ShowDownlooadViewController.h"
#import "UIImage+Scale.h"
#import "CMConstants.h"
#import "SubdownloadItem.h"
#import "CommonMotheds.h"
#import "DownLoadManager.h"
@interface ShowDownlooadViewController ()

@end

@implementation ShowDownlooadViewController
@synthesize listArr = listArr_;
@synthesize tableList = tableList_;
@synthesize prodId = prodId_;
@synthesize imageviewUrl = imageviewUrl_;
@synthesize EpisodeIdArr = EpisodeIdArr_;

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_bg_common.png"] forBarMetrics:UIBarMetricsDefault];
    
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
    
    UIImageView *titleIMG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_download_show.png"]];
    titleIMG.frame = CGRectMake(15, 12, 77, 17);
    [self.view addSubview:titleIMG];
    
    
    
    EpisodeIdArr_ = [NSMutableArray arrayWithCapacity:5];
    for (SubdownloadItem *item in [self readDataFromDB]) {
        NSString *episodeId = [[item.name componentsSeparatedByString:@"_"] lastObject];
        [EpisodeIdArr_ addObject:episodeId];
    }
    
    UIImageView *tableBg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 29, 310,kCurrentWindowHeight-73)];
    UIImage *bgImg = [UIImage imageNamed:@"list_bg.png"];
    tableBg.image = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    [self.view addSubview:tableBg];
    
    tableList_ = [[UITableView alloc] initWithFrame:CGRectMake(0, 34, 320, kCurrentWindowHeight-78) style:UITableViewStylePlain];
    tableList_.dataSource = self;
    tableList_.delegate = self;
    tableList_.backgroundColor = [UIColor clearColor];
    tableList_.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableList_];
}
-(void)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [listArr_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *itemDic = [listArr_ objectAtIndex:indexPath.row];
    NSString *cellTitle = [NSString stringWithFormat:@"%@", [itemDic objectForKey:@"name"]];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(16, 2.5, 290, 35);
    btn.tag = indexPath.row;
    BOOL isDownload = NO;
    for (NSString *str in EpisodeIdArr_) {
        if ([str intValue] == indexPath.row) {
            isDownload = YES;
            break;
        }
    }
    if (isDownload) {
        btn.selected = YES;
    }
    if (![self isDownloadUrlEnable:indexPath.row]) {
        btn.enabled = NO;
    }
    [btn setBackgroundImage:[UIImage imageNamed:@"show_undownload.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"show_download_pressed.png"] forState:UIControlStateHighlighted];
    [btn setBackgroundImage:[UIImage imageNamed:@"show_download.png"] forState:UIControlStateSelected];
    [btn setBackgroundImage:[UIImage imageNamed:@"show_disable.png"] forState:UIControlStateDisabled];
     btn.adjustsImageWhenHighlighted = NO;
    btn.titleLabel.frame = CGRectMake(0, 0, 250, 30);
    btn.titleLabel.center = btn.center;
    btn.titleLabel.backgroundColor = [UIColor clearColor];
    [btn setTitle:cellTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor colorWithRed:196/255.0 green:196/255.0 blue:196/255.0 alpha:1] forState:UIControlStateDisabled];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(5, 20, 5, 70)];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:btn];
 
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;

}

-(void)selectButton:(UIButton *)btn{
    if (btn.selected) {
        return;
    }
    btn.selected = YES;
    int downloadNum = btn.tag;
    [self selectToDownLoad:downloadNum];

}
-(void)selectToDownLoad:(int)num{
    if (![CommonMotheds isNetworkEnbled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络异常，请检查网络。" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    NSArray *videoUrlArray = [[listArr_ objectAtIndex:num] objectForKey:@"down_urls"];
    if(videoUrlArray.count > 0){
        NSString *videoUrl = nil;
        for(NSDictionary *tempVideo in videoUrlArray){
            if([LETV isEqualToString:[tempVideo objectForKey:@"source"]]){
                videoUrl = [self parseDownloadUrl:tempVideo];
                break;
            }
        }
        if(videoUrl == nil){
            videoUrl = [self parseDownloadUrl:[videoUrlArray objectAtIndex:0]];
        }
        if (videoUrl == nil || [videoUrl isEqualToString:@""]) {
            NSLog(@"Get the download url is failed");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"暂无下载地址" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        NSString *sub_name = [[listArr_ objectAtIndex:num] objectForKey:@"name"];
        NSString *name = [NSString stringWithFormat:@"%@_%@",self.title,sub_name];
        if (name == nil || [name isEqualToString:@""]) {
            NSLog(@"Get the download name is failed");
            return;
        }
        NSString *prod_Id = prodId_;
        if (prod_Id == nil || [prod_Id isEqualToString:@""]) {
            NSLog(@"Get the download prodId is failed");
            return;
        }
        NSArray *infoArr = [NSArray arrayWithObjects:prod_Id,name,imageviewUrl_,@"3",[NSString stringWithFormat:@"%d",num], nil];
        
        CheckDownloadUrls *check = [[CheckDownloadUrls alloc] init];
        check.downloadInfoArr = infoArr;
        [check checkDownloadUrls:[EpisodeIdArr_ objectAtIndex:num]];
    }
}

-(BOOL)isDownloadUrlEnable:(int)num{
    NSString *downloadUrl = nil;
    NSArray *videoUrlArray = [[listArr_ objectAtIndex:num] objectForKey:@"down_urls"];
    if(videoUrlArray.count > 0){
        for(NSDictionary *tempVideo in videoUrlArray){
            if([LETV isEqualToString:[tempVideo objectForKey:@"source"]]){
                downloadUrl = [self parseDownloadUrl:tempVideo];
                break;
            }
        }
        if(downloadUrl == nil){
            downloadUrl = [self parseDownloadUrl:[videoUrlArray objectAtIndex:0]];
        }
    }
    if (downloadUrl == nil) {
        return NO;
    }
    else{
        return YES;
    }
    
}

- (NSString *)parseDownloadUrl:(NSDictionary *)tempVideo
{
    NSString *videoUrl;
    NSArray *urlArray =  [tempVideo objectForKey:@"urls"];
    for(NSDictionary *url in urlArray){
        if([GAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"mp4" isEqualToString:[url objectForKey:@"file"]]){
            videoUrl = [url objectForKey:@"url"];
            
            break;
        }
        if([GAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"m3u8" isEqualToString:[url objectForKey:@"file"]]){
            videoUrl = [url objectForKey:@"url"];
            
            break;
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([BIAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"mp4" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
               
                break;
            }
            if([BIAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"m3u8" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
                
                break;
            }
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([LIU_CHANG isEqualToString:[[url objectForKey:@"type"] lowercaseString]]&&[@"mp4" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
                
                break;
            }
            if([LIU_CHANG isEqualToString:[[url objectForKey:@"type"] lowercaseString]]&&[@"m3u8" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
                
                break;
            }
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([CHAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"mp4" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
                
                break;
            }
            if([CHAO_QING isEqualToString:[url objectForKey:@"type"]]&&[@"m3u8" isEqualToString:[url objectForKey:@"file"]]){
                videoUrl = [url objectForKey:@"url"];
                
                break;
            }
        }
    }
    
    
    if(videoUrl == nil){
        if(urlArray.count > 0){
            for(NSDictionary *url in urlArray){
                if ([[url objectForKey:@"file"] isEqualToString:@"mp4"]) {
                    videoUrl = [url objectForKey:@"url"];
                   
                }
                if ([[url objectForKey:@"file"] isEqualToString:@"m3u8"]) {
                    videoUrl = [url objectForKey:@"url"];
                   
                }
                
            }
        }
    }
    return videoUrl;
    
    
}

-(NSArray *)readDataFromDB{
    NSString *subquery = [NSString stringWithFormat:@"WHERE item_id = '%@'",prodId_];
    NSArray *tempArr = [SubdownloadItem findByCriteria:subquery];
    return tempArr;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
