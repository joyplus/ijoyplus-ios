//
//  IphoneShowViewController.m
//  yueshipin
//
//  Created by 08 on 12-12-28.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "IphoneShowDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CacheUtility.h"
#import "CMConstants.h"
#import "MediaPlayerViewController.h"
#import "AppDelegate.h"
#import "ProgramViewController.h"
#import "MBProgressHUD.h"
#import "UIImage+Scale.h"
#import "SendWeiboViewController.h"

@interface IphoneShowDetailViewController ()

@end

@implementation IphoneShowDetailViewController

@synthesize infoDic = infoDic_;
@synthesize videoInfo = videoInfo_;
@synthesize episodesArr = episodesArr_;
@synthesize videoType = videoType_;
@synthesize summary = summary_;
@synthesize scrollView = scrollView_;
@synthesize next = next_;
@synthesize pre = pre_;
@synthesize commentArray = commentArray_;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, 480);
    self.tableView.backgroundView = backGround;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    backButton.backgroundColor = [UIColor clearColor];
    [backButton setImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_return_common.png"]  toSize:CGSizeMake(20, 18)] forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 40, 30);
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setImage:[UIImage scaleFromImage:[UIImage imageNamed:@"top_common_share.png"] toSize:CGSizeMake(19, 18)] forState:UIControlStateNormal];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.title = [self.infoDic objectForKey:@"prod_name"];
    [self loadData];
    [self loadComments];

    favCount_ = [[self.infoDic objectForKey:@"favority_num" ] intValue];
    supportCount_ = [[self.infoDic objectForKey:@"support_num" ] intValue];
}
-(void)share:(id)sender{
    SendWeiboViewController *sendWeiBoViewController = [[SendWeiboViewController alloc] init];
    sendWeiBoViewController.infoDic = videoInfo_;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:sendWeiBoViewController] animated:YES completion:nil];
    
}
-(void)back:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadData{
    MBProgressHUD *tempHUD;
    NSString *key = [NSString stringWithFormat:@"%@%@", @"show", [self.infoDic objectForKey:@"prod_id"]];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    if(cacheResult != nil){
        videoInfo_ = (NSDictionary *)[cacheResult objectForKey:@"show"];
        episodesArr_ = [videoInfo_ objectForKey:@"episodes"];
        NSLog(@"episodes count is %d",[episodesArr_ count]);
        summary_ = [videoInfo_ objectForKey:@"summary"];
        [self.tableView reloadData];
    }
    else{
        if(tempHUD == nil){
            tempHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:tempHUD];
            tempHUD.labelText = @"加载中...";
            tempHUD.opacity = 0.5;
            [tempHUD show:YES];
        }
        
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [self.infoDic objectForKey:@"prod_id"], @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        [[CacheUtility sharedCache] putInCache:key result:result];
        videoInfo_ = (NSDictionary *)[result objectForKey:@"show"];
        episodesArr_ = [videoInfo_ objectForKey:@"episodes"];
        NSLog(@"episodes count is %d",[episodesArr_ count]);
        summary_ = [videoInfo_ objectForKey:@"summary"];
        [tempHUD hide:YES];
        [self.tableView reloadData];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [tempHUD hide:YES];
    }];
    
}

- (void)loadComments
{
    commentArray_ = [NSMutableArray arrayWithCapacity:10];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[self.infoDic objectForKey:@"prod_id"], @"prod_id", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSString *key = [NSString stringWithFormat:@"%@%@", @"show", [self.infoDic objectForKey:@"prod_id"]];
            [[CacheUtility sharedCache] putInCache:key result:result];
            NSArray *tempArray = (NSMutableArray *)[result objectForKey:@"comments"];
            [commentArray_ removeAllObjects];
            if(tempArray != nil && tempArray.count > 0){
                [commentArray_ addObjectsFromArray:tempArray];
            }
            [self.tableView reloadData];
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([commentArray_ count] > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 3;
    }
    else if (section == 1){
        return [commentArray_ count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
     UITableViewCell *cell  = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
//    for (UIView *view in cell.subviews) {
//        [view removeFromSuperview];
//    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 87, 129)];
                [imageView setImageWithURL:[NSURL URLWithString:[self.infoDic objectForKey:@"prod_pic_url"]] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
                [cell addSubview:imageView];
                
                NSString *directors = [self.infoDic objectForKey:@"directors"];
                NSString *actors = [self.infoDic objectForKey:@"stars"];
                NSString *date = [self.infoDic objectForKey:@"publish_date"];
                NSString *area = [self.infoDic objectForKey:@"area"];
                UILabel *actorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 59, 200, 15)];
                actorsLabel.font = [UIFont systemFontOfSize:12];
                actorsLabel.textColor = [UIColor grayColor];
                actorsLabel.backgroundColor = [UIColor clearColor];
                actorsLabel.text = [NSString stringWithFormat:@"主演: %@",actors];
                [cell addSubview:actorsLabel];
                
                NSString *labelText = [NSString stringWithFormat:@"地区: %@\n导演: %@\n年代: %@",area,directors,date];
                UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(116, 74, 200, 60)];
                //infoLabel.backgroundColor = [UIColor redColor];
                infoLabel.font = [UIFont systemFontOfSize:12];
                infoLabel.textColor = [UIColor grayColor];
                infoLabel.backgroundColor = [UIColor clearColor];
                infoLabel.text = labelText;
                infoLabel.lineBreakMode = UILineBreakModeWordWrap;
                infoLabel.numberOfLines = 0;
                [cell addSubview:infoLabel];
                
                UIButton *play = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                play.frame = CGRectMake(115, 28, 87, 27);
                play.tag = 10001;
                //[play setTitle:@"播放视频" forState:UIControlStateNormal];
                [play setImage:[UIImage imageNamed:@"tab2_detailed_common_play_video.png"] forState:UIControlStateNormal];
                [play setImage:[UIImage imageNamed:@"tab2_detailed_common_play_video_s.png"] forState:UIControlStateHighlighted];
                [play addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:play];
                
                UIButton *addFav = [UIButton buttonWithType:UIButtonTypeCustom];
                addFav.frame = CGRectMake(14, 152, 142, 27);
                addFav.tag = 10002;
                [addFav setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_common_favorite&recommend.png"] forState:UIControlStateNormal];
                [addFav setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_common_favorite&recommend_s.png"] forState:UIControlStateHighlighted];
                [addFav setImage:[UIImage scaleFromImage:[UIImage imageNamed:@"tab2_detailed_common_icon_favorite.png"] toSize:CGSizeMake(16, 15)] forState:UIControlStateNormal];
                [addFav setImage:[UIImage scaleFromImage:[UIImage imageNamed:@"tab2_detailed_common_icon_favorite_s.png"] toSize:CGSizeMake(16, 15)] forState:UIControlStateHighlighted];
                [addFav setTitle:[NSString stringWithFormat:@"收藏（%d）",favCount_]  forState:UIControlStateNormal];
                [addFav setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [addFav addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                 addFav.titleLabel.font = [UIFont systemFontOfSize:14];
                [cell addSubview:addFav];
                
                UIButton *support = [UIButton buttonWithType:UIButtonTypeCustom];
                support.frame = CGRectMake(165, 152, 142, 27);
                support.tag = 10003;
                [support setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_common_favorite&recommend.png"] forState:UIControlStateNormal];
                [support setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_common_favorite&recommend_s.png"] forState:UIControlStateHighlighted];
                [support setImage: [UIImage scaleFromImage:[UIImage imageNamed:@"tab2_detailed_common_icon_recommend.png"] toSize:CGSizeMake(16, 15)]forState:UIControlStateNormal];
                [support setImage:[UIImage scaleFromImage:[UIImage imageNamed:@"tab2_detailed_common_icon_recommend_s.png"] toSize:CGSizeMake(16, 15)] forState:UIControlStateHighlighted];
                [support setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [support setTitle:[NSString stringWithFormat:@"顶（%d）",supportCount_] forState:UIControlStateNormal];
                [support addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
                 support.titleLabel.font = [UIFont systemFontOfSize:14];
                [cell addSubview:support];
                
                break;
            }
            case 1:{
                UIImageView *onLine = [[UIImageView alloc] initWithFrame:CGRectMake(14, 10, 50, 13)];
                onLine.image = [UIImage imageNamed:@"tab2_detailed_common_writing2.png"];
                [cell addSubview:onLine];
                
                UIView *view = [self showEpisodesplayView];
               [cell addSubview:view];
                break;
            }
                
            case 2:{
                UIImageView *jianjie = [[UIImageView alloc] initWithFrame:CGRectMake(14, 5, 30, 13)];
                jianjie.image = [UIImage imageNamed:@"tab2_detailed_common_writing3.png"];
                [cell addSubview:jianjie];
                
                UILabel *summary = [[UILabel alloc] initWithFrame:CGRectMake(14, 20, 292, [self heightForString:summary_ fontSize:13 andWidth:271])];
                summary.textColor = [UIColor grayColor];
                summary.text = [NSString stringWithFormat:@"    %@",summary_];
                summary.textAlignment = UITextAlignmentCenter;
                summary.numberOfLines = 0;
                summary.lineBreakMode = UILineBreakModeWordWrap;
                summary.font = [UIFont systemFontOfSize:13];
                [cell addSubview:summary];
                break;
            }
            default:
                break;
        }
    }
    else if (indexPath.section == 1){
            NSDictionary *item = [commentArray_ objectAtIndex:indexPath.row];
            
            UILabel *user =[[UILabel alloc] initWithFrame:CGRectMake(25, 5, 180, 14)];
            user.text = @"网络用户";
            user.font = [UIFont systemFontOfSize:14];
            user.backgroundColor = [UIColor clearColor];
            UILabel *date =[[UILabel alloc] initWithFrame:CGRectMake(210, 5, 90, 14)];
            NSString *dateStr = [item objectForKey:@"create_date"];
            if (dateStr.length > 10) {
                dateStr = [dateStr substringToIndex:10];
            }
            date.text = dateStr;
            date.font = [UIFont systemFontOfSize:14];
            date.textColor = [UIColor grayColor];
            date.backgroundColor = [UIColor clearColor];
            [cell addSubview:user];
            [cell addSubview:date];
            NSString *content = [item objectForKey:@"content"];
            int height = [self heightForString:content fontSize:13 andWidth:271];
            UILabel *comment =[[UILabel alloc]initWithFrame:CGRectMake(25, 20, 270, height)];
            comment.text = content;
            comment.backgroundColor = [UIColor clearColor];
            comment.textColor = [UIColor grayColor];
            comment.numberOfLines = 0;
            comment.lineBreakMode = UILineBreakModeWordWrap;
            comment.font = [UIFont systemFontOfSize:13];
            [cell addSubview:comment];
            
            UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_detailed_common_writing4_fenge.png"]];
            line.frame = CGRectMake(25,height+19, 270, 1);
            [cell addSubview:line]; 

    
    }
    return cell;
}

- (float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    CGSize sizeToFit = [value sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    return sizeToFit.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int row = indexPath.row;
    if (indexPath.section == 0) {
        if (row == 0) {
            return 181;
        }
        else if(row == 1){
            return 155;
        }
        else if(row == 2){
            return [self heightForString:summary_ fontSize:13 andWidth:271]+20;
        }
        
    }
    else if (indexPath.section == 1){
        NSDictionary *item = [commentArray_ objectAtIndex:row];
        NSString *content = [item objectForKey:@"content"];
        return [self heightForString:content fontSize:13 andWidth:271]+20;
    }
    return 0;
    
}

-(void)Play:(int)number{
    NSArray *videoUrlArray = [[episodesArr_ objectAtIndex:number] objectForKey:@"down_urls"];
    if(videoUrlArray.count > 0){
        NSString *videoUrl = nil;
        for(NSDictionary *tempVideo in videoUrlArray){
            if([LETV isEqualToString:[tempVideo objectForKey:@"source"]]){
                videoUrl = [self parseVideoUrl:tempVideo];
                break;
            }
        }
        if(videoUrl == nil){
            videoUrl = [self parseVideoUrl:[videoUrlArray objectAtIndex:0]];
        }
        if(videoUrl == nil){
            [self showPlayWebPage:number];
        } else {
            MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
            viewController.videoUrl = videoUrl;
            viewController.type = 1;
            viewController.name = [videoInfo_ objectForKey:@"name"];
            [self presentViewController:viewController animated:YES completion:nil];
        }
    }else {
        [self showPlayWebPage:number];
    }
}
-(void)action:(id)sender {
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10001:{
            [self Play:1];
            break;
        }
        case 10002:{
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [self.infoDic objectForKey:@"prod_id"], @"prod_id", nil];
            [[AFServiceAPIClient sharedClient] postPath:kPathProgramFavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                NSString *responseCode = [result objectForKey:@"res_code"];
                if([responseCode isEqualToString:kSuccessResCode]){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFav"object:nil];
                    favCount_++;
                    [self.tableView reloadData];
                } else {
                    
                }
                
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            
            
            break;
        }
        case 10003:{
            NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [self.infoDic objectForKey:@"prod_id"], @"prod_id", nil];
            [[AFServiceAPIClient sharedClient] postPath:kPathSupport parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
                NSString *responseCode = [result objectForKey:@"res_code"];
                if([responseCode isEqualToString:kSuccessResCode]){
                    supportCount_ ++;
                    [self.tableView reloadData];
                } else {
                    
                }
            } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
            
            
            break;
        }
            
        default:
            break;
    }
}

- (void)showPlayWebPage:(int)num
{
    ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
    NSDictionary *episode = [episodesArr_ objectAtIndex:num];
    NSArray *videoUrls = [episode objectForKey:@"video_urls"];
    viewController.programUrl = [[videoUrls objectAtIndex:0] objectForKey:@"url"];
    viewController.title = [videoInfo_ objectForKey:@"name"];
    viewController.type = 1;
    viewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController] animated:YES completion:nil];
    
}

- (NSString *)parseVideoUrl:(NSDictionary *)tempVideo
{
    NSString *videoUrl;
    NSArray *urlArray =  [tempVideo objectForKey:@"urls"];
    for(NSDictionary *url in urlArray){
        if([GAO_QING isEqualToString:[url objectForKey:@"type"]]){
            videoUrl = [url objectForKey:@"url"];
            break;
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([BIAO_QING isEqualToString:[url objectForKey:@"type"]]){
                videoUrl = [url objectForKey:@"url"];
                break;
            }
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([LIU_CHANG isEqualToString:[url objectForKey:@"type"]]){
                videoUrl = [url objectForKey:@"url"];
                break;
            }
        }
    }
    if(videoUrl == nil){
        for(NSDictionary *url in urlArray){
            if([CHAO_QING isEqualToString:[url objectForKey:@"type"]]){
                videoUrl = [url objectForKey:@"url"];
                break;
            }
        }
    }
    if(videoUrl == nil){
        if(urlArray.count > 0){
            videoUrl = [[urlArray objectAtIndex:0] objectForKey:@"url"];
        }
    }
    return videoUrl;
}

-(UIView *)showEpisodesplayView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15, 0, 293, 125)];
    int count = [episodesArr_ count];
    
    pageCount_ = (count%4 == 0 ? (count/4):(count/4)+1);
    
    scrollView_= [[UIScrollView alloc] initWithFrame:CGRectMake(25, 33, 240, 122)];
    scrollView_.contentSize = CGSizeMake(320*(count/15), 125);
    scrollView_.scrollEnabled = NO;
    scrollView_.pagingEnabled = YES;
    scrollView_.showsHorizontalScrollIndicator = NO;

    for (int i = 0; i < count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((i/4)*240, (i%4)*29, 240, 27);
        button.tag = i+1;
        NSDictionary *dic = [episodesArr_ objectAtIndex:i];
        
        NSString *title = [NSString stringWithFormat:@"%@", [dic objectForKey:@"name"]];
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         button.titleLabel.font = [UIFont systemFontOfSize:12];
         button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [button setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_variety_online_bg.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_variety_online_bg_s.png"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(episodesPlay:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView_ addSubview:button];
    }
    currentPage_ = 1;
    next_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    next_.frame = CGRectMake( 273, 30, 20, 125);
    [next_ setTitle:@"PRE" forState:UIControlStateNormal];
    [next_ setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_variety_More1.png"] forState:UIControlStateNormal];
    [next_ setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_variety_More1_s.png"] forState:UIControlStateHighlighted];
    [next_ addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [view  addSubview:next_];
    if (pageCount_ == 1) {
        next_.enabled = NO;
    }

    pre_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    pre_.frame = CGRectMake(0, 30, 20, 125);
    if (currentPage_ == 1) {
        pre_.enabled = NO;
    }
    [pre_ setTitle:@"NEXT" forState:UIControlStateNormal];
    [pre_ setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_variety_More2.png"] forState:UIControlStateNormal];
    [pre_ setBackgroundImage:[UIImage imageNamed:@"tab2_detailed_variety_More2_s.png"] forState:UIControlStateHighlighted];
    [pre_ addTarget:self action:@selector(pre:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:pre_];
   
    [view addSubview:scrollView_];
    return view;
    
}

-(void)next:(id)sender{
    currentPage_++;
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.3f];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [self.scrollView setContentOffset:CGPointMake(240.0f*(currentPage_-1), 0.0f) animated:YES];
    
    [UIView commitAnimations];
    if (currentPage_ == pageCount_ ) {
        next_.enabled = NO;
    }
    else{
        next_.enabled = YES;
    
    }
    
    if (currentPage_ == 1 ) {
        pre_.enabled = NO;
    }
    else{
        pre_.enabled = YES;
        
    }
    
}
-(void)pre:(id)sender{
    currentPage_--;
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.3f];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [self.scrollView setContentOffset:CGPointMake(240.0f*(currentPage_-1), 0.0f) animated:YES];
    
    [UIView commitAnimations];
    if (currentPage_ == pageCount_ ) {
        next_.enabled = NO;
    }
    else{
        next_.enabled = YES;
        
    }
    if (currentPage_ == 1 ) {
        pre_.enabled = NO;
    }
    else{
        pre_.enabled = YES;
        
    }
    
}
-(void)episodesPlay:(id)sender{
    int playNum = ((UIButton *)sender).tag;
    
    [self Play:playNum-1];
    
}
@end
