//
//  RespForWXDetailViewController.m
//  yueshipin
//
//  Created by 08 on 13-4-2.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "RespForWXDetailViewController.h"
#import "CommonHeader.h"
@interface RespForWXDetailViewController ()

- (void)reqData;
- (NSString *)parseDownloadUrl:(NSDictionary *)tempVideo;
- (void)setViewWithData:(id)result;

@end

@implementation RespForWXDetailViewController
@synthesize dicDataSource = _dicDataSource;
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.dicDataSource = nil;
    _dicVideoInfo = nil;
    
    _labName = nil;
    _labActors = nil;
    _labDirectors = nil;
    _labArea = nil;
    _labReleaseDate = nil;
    _imgViewPoster = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"悅视频";
    
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, kFullWindowHeight-64);
    
    [self.view addSubview:backGround];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 49, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.navigationItem.hidesBackButton = YES;
    
    
    UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detailFrame.png"]];
    frame.frame = CGRectMake(14, 14, 90, 133);
    [self.view addSubview:frame];
    
    _imgViewPoster = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 85, 126)];
    
    [self.view addSubview:_imgViewPoster];
    
    
    _labName = [[UILabel alloc] initWithFrame:CGRectMake(116, 16, 200, 30)];
    _labName.font = [UIFont systemFontOfSize:18];
    _labName.textColor = [UIColor grayColor];
    _labName.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_labName];
    
    
    _labActors = [[UILabel alloc] initWithFrame:CGRectMake(116, 49, 200, 15)];
    _labActors.font = [UIFont systemFontOfSize:12];
    _labActors.textColor = [UIColor grayColor];
    _labActors.backgroundColor = [UIColor clearColor];
    
    
    
    _labArea = [[UILabel alloc] initWithFrame:CGRectMake(116, 85, 200, 15)];
    _labArea.font = [UIFont systemFontOfSize:12];
    _labArea.textColor = [UIColor grayColor];
    _labArea.backgroundColor = [UIColor clearColor];
    
    
    _labDirectors = [[UILabel alloc] initWithFrame:CGRectMake(116, 67, 200, 15)];
    _labDirectors.font = [UIFont systemFontOfSize:12];
    _labDirectors.textColor = [UIColor grayColor];
    _labDirectors.backgroundColor = [UIColor clearColor];
    
    
    _labReleaseDate = [[UILabel alloc] initWithFrame:CGRectMake(116, 103, 200, 15)];
    _labReleaseDate.font = [UIFont systemFontOfSize:12];
    _labReleaseDate.textColor = [UIColor grayColor];
    _labReleaseDate.backgroundColor = [UIColor clearColor];

    
    [self.view addSubview:_labActors];
    [self.view addSubview:_labArea];
    [self.view addSubview:_labDirectors];
    [self.view addSubview:_labReleaseDate];;
    
    
    
    UIImageView * shareWXBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shareWX_bg.png"]];
    shareWXBG.frame = CGRectMake(0, (backGround.frame.size.height - 54), 320, 54);
    [self.view addSubview:shareWXBG];
    
    UIButton * shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(0, 0, 134, 40);
    shareBtn.center = shareWXBG.center;
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"fenxiang_weixin.png"] forState:UIControlStateNormal];
    [shareBtn setBackgroundImage:[UIImage imageNamed:@"fenxiang_weixin_s.png"] forState:UIControlStateHighlighted];
    [shareBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reqData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reqData
{
    MBProgressHUD *tempHUD;
    
    NSString *itemId = [self.dicDataSource objectForKey:@"prod_id"];
    if (itemId == nil)
    {
        itemId = [self.dicDataSource objectForKey:@"content_id"];
    }
    if (itemId == nil)
    {
        itemId = [self.dicDataSource objectForKey:@"id"];
    }
    
    //prodId_ = itemId;
    NSString *key = [NSString stringWithFormat:@"%@%@", @"movie",itemId];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    
    if (nil != cacheResult)
    {
        [self setViewWithData:cacheResult];
    }
    else
    {
        if(tempHUD == nil){
            tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:tempHUD];
            tempHUD.labelText = @"加载中...";
            tempHUD.opacity = 0.5;
            [tempHUD show:YES];
        }
        
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: itemId, @"prod_id", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result)
        {
            [[CacheUtility sharedCache] putInCache:key result:result];
            [self setViewWithData:result];
            [tempHUD hide:YES];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error)
         {
            [tempHUD hide:YES];
        }];
    }
    
}

- (void)setViewWithData:(id)result
{
    NSString * type = [_dicDataSource objectForKey:@"prod_type"];
    
    if (nil == type)
    {
        type = [_dicDataSource objectForKey:@"content_type"];
    }
    
    if ([type isEqualToString:@"1"])
    {
        _dicVideoInfo = (NSDictionary *)[result objectForKey:@"movie"];
    }
    else if ([type isEqualToString:@"2"] || [type isEqualToString:@"131"])
    {
        _dicVideoInfo = (NSDictionary *)[result objectForKey:@"tv"];
    }
    else if ([type isEqualToString:@"3"])
    {
        _dicVideoInfo = (NSDictionary *)[result objectForKey:@"show"];
    }
    else
    {
        _dicDataSource = nil;
    }
    
    //Poster
    NSString *imageUrl = [_dicVideoInfo objectForKey:@"prod_pic_url"];
    if (imageUrl == nil) {
        imageUrl = [_dicVideoInfo objectForKey:@"content_pic_url"];
    }
    if (imageUrl == nil) {
        imageUrl = [_dicVideoInfo objectForKey:@"poster"];
    }
    [_imgViewPoster setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    
    //Title
    NSString *titleStr = [_dicVideoInfo objectForKey:@"prod_name"];
    if (titleStr == nil) {
        titleStr = [_dicVideoInfo objectForKey:@"content_name"];
    }
    if (titleStr == nil) {
        titleStr = [_dicVideoInfo objectForKey:@"name"];
    }
    
    _labName.text = [NSString stringWithFormat:@"%@",titleStr];
    
    //Actors & Direcctors
    NSString *directors = [_dicVideoInfo objectForKey:@"directors"];
    if (directors == nil) {
        directors = [_dicVideoInfo objectForKey:@"director"];
    }
    if (directors == nil) {
        directors = @" ";
    }
    
    NSString *actors = [_dicVideoInfo objectForKey:@"stars"];
    if (actors == nil) {
        actors = [_dicVideoInfo objectForKey:@"star"];
    }
    if (actors == nil) {
        actors = @" ";
    }
    
    NSString *date = [_dicVideoInfo objectForKey:@"publish_date"];
    if (date == nil) {
        date = @" ";
    }
    NSString *area = [_dicVideoInfo objectForKey:@"area"];
    if (area == nil) {
        area = @" ";
    }
    
    _labActors.text = [NSString stringWithFormat:@"主演: %@",actors];
    _labReleaseDate.text = [NSString stringWithFormat:@"年代: %@",date];
    _labDirectors.text = [NSString stringWithFormat:@"导演: %@",directors];
    _labArea.text = [NSString stringWithFormat:@"地区: %@",area];
    
    
    
    NSString * summary_ = [_dicVideoInfo objectForKey:@"summary"];
    
    if (nil != summary_)
    {
        UIImageView *jianjie = [[UIImageView alloc] initWithFrame:CGRectMake(14, 162, 30, 13)];
        jianjie.image = [UIImage imageNamed:@"tab2_detailed_common_writing3.png"];
        [self.view addSubview:jianjie];
        
        CGSize contentSize = [summary_ sizeWithFont:[UIFont systemFontOfSize:13]
                                  constrainedToSize:CGSizeMake(264, CGFLOAT_MAX)];
        
        CGFloat height = contentSize.height > 150 ? 150 : contentSize.height;
        
        UIImageView * summaryBg_ = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"summryBg.png"] stretchableImageWithLeftCapWidth:50 topCapHeight:50 ]];
        summaryBg_.frame = CGRectMake(14, 177, 292, height);
        
        UILabel * summaryLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(28, 177, 264,height)];
        summaryLabel_.textColor = [UIColor grayColor];
        summaryLabel_.backgroundColor = [UIColor clearColor];
        summaryLabel_.numberOfLines = 0;
        summaryLabel_.lineBreakMode = UILineBreakModeWordWrap;
        summaryLabel_.font = [UIFont systemFontOfSize:13];
        
        [self.view addSubview:summaryBg_];
        
        summaryLabel_.text = [NSString stringWithFormat:@"    %@",summary_];
        
        [self.view addSubview:summaryLabel_];
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

- (void)back:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(back)])
    {
        [delegate back];
    }
}

- (void)share:(id)sender
{
    NSArray * episodesArr_ = [_dicVideoInfo objectForKey:@"episodes"];
    
    NSArray *videoUrlArray = [[episodesArr_ objectAtIndex:0] objectForKey:@"down_urls"];
    
    NSString * downloadUrl = nil;
    if(videoUrlArray.count > 0)
    {
        for(NSDictionary *tempVideo in videoUrlArray)
        {
            if([LETV isEqualToString:[tempVideo objectForKey:@"source"]]){
                downloadUrl = [self parseDownloadUrl:tempVideo];
                break;
            }
        }
        if(downloadUrl == nil){
            downloadUrl = [self parseDownloadUrl:[videoUrlArray objectAtIndex:0]];
        }
    }
    
    NSString * title = [_dicVideoInfo objectForKey:@"name"];
    NSString * description = [_dicVideoInfo objectForKey:@"summary"];
    NSString * thumb = [_dicVideoInfo objectForKey:@"poster"];
    
    NSDictionary * shareData = [NSDictionary dictionaryWithObjectsAndKeys:downloadUrl,@"videoURL",title,@"name",description ,@"description",thumb,@"thumb",nil];
    
    [self.navigationController popViewControllerAnimated:NO];
    if (delegate && [delegate respondsToSelector:@selector(RespVideoContent:)])
    {
        [delegate RespVideoContent:shareData];
    }
}
    

@end
