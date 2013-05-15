//
//  ChannelViewController.m
//  theatreiphone
//
//  Created by Rong on 13-5-13.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "ChannelViewController.h"
#import "SearchPreViewController.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "FiltrateCell.h"
#import "UIImageView+WebCache.h"
#import "TVDetailViewController.h"
#import "IphoneMovieDetailViewController.h"
#import "IphoneShowDetailViewController.h"
@implementation ChannelViewController
@synthesize titleButton = titleButton_;
@synthesize segV = _segV;
@synthesize videoTypeSeg = _videoTypeSeg;
@synthesize filtrateView = _filtrateView;
@synthesize tableList = _tableList;
@synthesize dataArr = _dataArr;
@synthesize parameters = _parameters;
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
    UIImageView *backGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_common.png"]];
    backGround.frame = CGRectMake(0, 0, 320, kFullWindowHeight);
    [self.view addSubview:backGround];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 55, 44);
    rightButton.backgroundColor = [UIColor clearColor];
    [rightButton setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"search_f.png"] forState:UIControlStateHighlighted];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    self.navigationItem.hidesBackButton = YES;
    
    titleButton_ = [UIButton buttonWithType:UIButtonTypeCustom];
    titleButton_.frame = CGRectMake(0, 0, 90, 60);
    titleButton_.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [titleButton_ setTitle:@"电影" forState:UIControlStateNormal];
    [titleButton_ setTitle:@"电影" forState:UIControlStateHighlighted];
    [titleButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [titleButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    titleButton_.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [titleButton_ setTitleShadowColor:[UIColor colorWithRed:121.0/255 green:64.0/255 blue:0 alpha:1]forState:UIControlStateNormal];
    [titleButton_ setTitleShadowColor:[UIColor colorWithRed:121.0/255 green:64.0/255 blue:0 alpha:1]forState:UIControlStateHighlighted];
    [titleButton_ setTitleShadowColor:[UIColor colorWithRed:121.0/255 green:64.0/255 blue:0 alpha:1]forState:UIControlStateSelected];
    [titleButton_ addTarget:self action:@selector(showSegmentControl:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleButton_;
    
    _segV = [[SegmentControlView alloc] initWithFrame:CGRectMake(0, 0, 320, 42)];
    _segV.delegate = self;
    [self.view addSubview:_segV];
    
    _videoTypeSeg = [[VideoTypeSegment alloc] initWithFrame:CGRectMake(0, 0, 320, 65)];
    _videoTypeSeg.delegate = self;
    _videoTypeSeg.hidden = YES;
    [self.view addSubview: _videoTypeSeg];
    
    _filtrateView = [[FiltrateView alloc] initWithFrame:CGRectMake(0, 42, 320, 108)];
    _filtrateView.delegate = self;
    _filtrateView.hidden = YES;
    [self.view addSubview:_filtrateView];
    
    _tableList = [[UITableView alloc] initWithFrame:CGRectMake(0, 42, 320, kCurrentWindowHeight -44-42-48) style:UITableViewStylePlain];
    _tableList.dataSource = self;
    _tableList.delegate = self;
    _tableList.backgroundColor = [UIColor clearColor];
    _tableList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableList];
    
    [self initDefaultParameters];
}

-(void)initDefaultParameters{
    videoType_ = TYPE_MOVIE;
    _parameters = [NSMutableDictionary dictionaryWithCapacity:5];
    [_parameters setObject:@"1" forKey:@"page_num"];
    [_parameters setObject:[NSNumber numberWithInt:videoType_] forKey:@"type"];
    [_parameters setObject:[NSNumber numberWithInt:12] forKey:@"page_size"];
    [_parameters setObject:@"" forKey:@"sub_type"];
    [_parameters setObject:@"" forKey:@"area"];
    [_parameters setObject:@"" forKey:@"year"];
    [self sendHttpRequest:_parameters];
}
-(void)search:(id)sender{
    SearchPreViewController *searchViewCotroller = [[SearchPreViewController alloc] init];
    searchViewCotroller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewCotroller animated:YES];
    
}

#pragma mark -
#pragma mark - videoTypeSegmentDelegate
-(void)videoTypeSegmentDidSelectedAtIndex:(int)index{
    typeSelectIndex_ = index;
    _videoTypeSeg.hidden = YES;
    switch (index) {
        case 0:
            [_segV setSegmentControl:TYPE_MOVIE];
            videoType_ = TYPE_MOVIE;
            [titleButton_ setTitle:@"电影" forState:UIControlStateNormal];
            [titleButton_ setTitle:@"电影" forState:UIControlStateHighlighted];
            break;
        case 1:
            [_segV setSegmentControl:TYPE_TV];
            videoType_ = TYPE_TV;
            [titleButton_ setTitle:@"电视剧" forState:UIControlStateNormal];
            [titleButton_ setTitle:@"电视剧" forState:UIControlStateHighlighted];
            break;
        case 2:
            [_segV setSegmentControl:TYPE_COMIC];
            videoType_ = TYPE_COMIC;
            [titleButton_ setTitle:@"动漫" forState:UIControlStateNormal];
            [titleButton_ setTitle:@"动漫" forState:UIControlStateHighlighted];
            break;
        case 3:
            [_segV setSegmentControl:TYPE_SHOW];
            videoType_ = TYPE_SHOW;
            [titleButton_ setTitle:@"综艺" forState:UIControlStateNormal];
            [titleButton_ setTitle:@"综艺" forState:UIControlStateHighlighted];
            break;
        default:
            break;
    }
    [_parameters setObject:[NSNumber numberWithInt:videoType_] forKey:@"type"];
    [_parameters setObject:@"" forKey:@"sub_type"];
    [_parameters setObject:@"" forKey:@"area"];
    [_parameters setObject:@"" forKey:@"year"];
    [self sendHttpRequest:_parameters];
}

#pragma mark -
#pragma mark - SegmentDelegate
-(void)segmentDidSelectedLabelStr:(NSString *)str withKey:(NSString *)key{
    if ([key isEqualToString:@"sub_type"]) {
        [_parameters setObject:str forKey:@"sub_type"];
        [_parameters setObject:@"" forKey:@"area"];
    }
    else if([key  isEqualToString:@"area"]){
        [_parameters setObject:str forKey:@"area"];
        [_parameters setObject:@"" forKey:@"sub_type"];
    }
    [_parameters setObject:@"" forKey:@"year"];
    [self sendHttpRequest:_parameters];
   _filtrateView.hidden = YES;
}

-(void)moreSelectWithType:(int)type{;
    _filtrateView.hidden = NO;
    [_filtrateView setViewWithType:type];
    [self.view bringSubviewToFront:_filtrateView];
}


#pragma mark -
#pragma mark - FiltrateDelegate
-(void)filtrateWithVideoType:(int)type parameters:(NSMutableDictionary *)parameters{
    [parameters setObject:@"1" forKey:@"page_num"];
    [parameters setObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [parameters setObject:[NSNumber numberWithInt:12] forKey:@"page_size"];
    [self sendHttpRequest:parameters];
}


#pragma mark -
#pragma mark - UITableViewDelegate&DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    int count = [_dataArr count];
    return (count%3 == 0) ? (count/3):(count/3+1);
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"CellIdentifier";
    FiltrateCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FiltrateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delagate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    int row = indexPath.row;
    int location = 3*row;
    int count = [_dataArr count];
    int length = 0;
    if (location+2 >= [_dataArr count]) {
        length = count%3;
    }
    else{
        length = 3;
    }
    NSRange range = NSMakeRange(location, length);
    NSArray *oneRowItems = [_dataArr subarrayWithRange:range];
    for (int i = 0; i < [oneRowItems count]; i++) {
        NSDictionary *item = [oneRowItems objectAtIndex:i];
        NSString *pic_url = [item objectForKey:@"prod_pic_url"];
        switch (i) {
            case 0:{
                [cell.firstImageView setImageWithURL:[NSURL URLWithString:pic_url]];
                cell.firstLabel.text = [item objectForKey:@"prod_name"];
                break;
            }
            case 1:{
                [cell.secondImageView setImageWithURL:[NSURL URLWithString:pic_url]];
                cell.secondLabel.text = [item objectForKey:@"prod_name"];
                break;
            }
            case 2:{
                [cell.thirdImageView setImageWithURL:[NSURL URLWithString:pic_url]];
                cell.thirdLabel.text = [item objectForKey:@"prod_name"];
                break;
            }
            default:
                break;
        }
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 145;
}

#pragma mark -
#pragma mark - FiltrateCellDelegate

-(void)didSelectAtCell:(FiltrateCell *)cell inPosition:(int)position{
    NSIndexPath *indexPath = [_tableList indexPathForCell:cell];
    int row = indexPath.row;
    NSDictionary *item = [_dataArr objectAtIndex:row*3+position];
    NSString *type = [item objectForKey:@"prod_type"];
    if ([type isEqualToString:@"2"]||[type isEqualToString:@"131"]) {
        TVDetailViewController *detailViewController = [[TVDetailViewController alloc] init];
        detailViewController.infoDic = item;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else if ([type isEqualToString:@"1"]){
        IphoneMovieDetailViewController *detailViewController = [[IphoneMovieDetailViewController alloc] init];
        detailViewController.infoDic = item;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    else if ([type isEqualToString:@"3"]){
        IphoneShowDetailViewController *detailViewController = [[IphoneShowDetailViewController alloc] init];
        detailViewController.infoDic = item;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    
}

-(void)sendHttpRequest:(NSDictionary *)parameters{
    
    [[AFServiceAPIClient sharedClient] getPath:kPathFilter parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSLog(@"success");
        [self analyzeData:result];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}

-(void)analyzeData:(id)result{
    if (_dataArr == nil) {
        _dataArr = [NSMutableArray arrayWithCapacity:5];
    }
    else{
        [_dataArr removeAllObjects];
    }
    
    NSArray *itemsArr = [result objectForKey:@"results"];
    [_dataArr addObjectsFromArray:itemsArr];
    
    [_tableList reloadData];
}



-(void)showSegmentControl:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        _videoTypeSeg.hidden = NO;
        [self.view bringSubviewToFront:_videoTypeSeg];
    }
    else{
        _videoTypeSeg.hidden = YES;
    }
    [_videoTypeSeg setSelectAtIndex:typeSelectIndex_];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
