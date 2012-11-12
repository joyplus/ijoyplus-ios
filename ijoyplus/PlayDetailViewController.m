//
//  PlayDetailViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-10-17.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "PlayDetailViewController.h"
#import "PlayCell.h"
#import "CommentCell.h"
#import "UIImageView+WebCache.h"
#import "CMConstants.h"
#import "DateUtility.h"
#import "TTTTimeIntervalFormatter.h"
#import "CommentListViewController.h"
#import "ContainerUtility.h"
#import "HomeViewController.h"
#import "CommentViewController.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ProgramViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "NoRecordCell.h"
#import "UIUtility.h"
#import "CustomBackButton.h"
#import "MBProgressHUD.h"
#import "RecommandViewController.h"
#import "SendCommentViewController.h"
#import "PostViewController.h"
#import "CacheUtility.h"
#import "BlockAlertView.h"
#import "MediaPlayerViewController.h"
#import "LoginViewController.h"
#import "SFHFKeychainUtils.h"
#import "WBEngine.h"


#define ROW_HEIGHT 40

@interface PlayDetailViewController (){

}

@end

@implementation PlayDetailViewController
@synthesize programId;
@synthesize userId;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"receive memory warning in %@", self.class);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _imageView = nil;
    _imageScroller = nil;
    _tableView = nil;
    [commentArray removeAllObjects];
    commentArray = nil;
    playCell = nil;
    video = nil;
    pullToRefreshManager_ = nil;
    playImageView = nil;
    playButton = nil;
    bottomToolbar = nil;
    pictureCell = nil;
    userId = nil;
    name = nil;
    dramaCell = nil;
    episodeArray = nil;
}

- (id)initWithStretchImage {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        WindowHeight = 180.0;
        ImageHeight  = 420.0;
        _imageScroller  = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _imageScroller.backgroundColor                  = [UIColor clearColor];
        _imageScroller.showsHorizontalScrollIndicator   = NO;
        _imageScroller.showsVerticalScrollIndicator     = NO;
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"u0_normal"]];
        [_imageScroller addSubview:_imageView];
        playImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        playImageView.image = [UIImage imageNamed:@"play"];
        playImageView.center = _imageView.center;
        [_imageView addSubview:playImageView];
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.backgroundColor              = [UIColor clearColor];
        _tableView.dataSource                   = self;
        _tableView.delegate                     = self;
        _tableView.separatorStyle               = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_imageScroller];
        [self.view addSubview:_tableView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    videoType = @"1";
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.title = NSLocalizedString(@"app_name", nil);
    CustomBackButton *backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"share", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(share)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    pageSize = 10;
    reload = 2;
    
    dramaCell = [[DramaCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dramaCell"];
    dramaCell.frame = CGRectZero;
    dramaCell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showProgressBar];
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
    }
    [self initPictureCell];
    [self initPlayCell];
    [self getProgramView];
    [self initToolBar];
    CGRect bounds = self.view.bounds;
    
    _imageScroller.frame        = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    _tableView.backgroundView   = nil;
    _tableView.frame            = CGRectMake(0, 0, bounds.size.width, bounds.size.height - 44);
    
    [self layoutImage];
    [self updateOffsets];
}

#pragma mark - Parallax effect

- (void)updateOffsets {
    CGFloat yOffset   = _tableView.contentOffset.y;
    CGFloat threshold = ImageHeight - WindowHeight;
    
    if (yOffset > -threshold && yOffset < 0) {
        _imageScroller.contentOffset = CGPointMake(0.0, floorf(yOffset / 2.0));
    } else if (yOffset < 0) {
        _imageScroller.contentOffset = CGPointMake(0.0, yOffset + floorf(threshold / 2.0));
    } else {
        _imageScroller.contentOffset = CGPointMake(0.0, yOffset);
    }
}

#pragma mark - View Layout
- (void)layoutImage {
    CGFloat imageWidth   = _imageScroller.frame.size.width;
    CGFloat imageYOffset = floorf((WindowHeight  - ImageHeight) / 2.0);
    CGFloat imageXOffset = 0.0;
    
    _imageView.frame             = CGRectMake(imageXOffset, imageYOffset, imageWidth, ImageHeight);
    playImageView.center = CGPointMake(_imageView.center.x, _imageView.center.y + abs(imageYOffset)) ;
    _imageScroller.contentSize   = CGSizeMake(imageWidth, self.view.bounds.size.height);
    _imageScroller.contentOffset = CGPointMake(0.0, 0.0);
}

- (void)getProgramView
{
    commentArray = [[NSMutableArray alloc]initWithCapacity:10];
    NSString *key = [NSString stringWithFormat:@"%@%@", @"movie", self.programId];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
    if(cacheResult != nil){
        [self parseData:cacheResult];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.programId, @"prod_id",
                                    nil];
        
        [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
            [UIUtility showSystemError:self.view];
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    }
}

- (void)parseData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSString *key = [NSString stringWithFormat:@"%@%@", @"movie", self.programId];
        [[CacheUtility sharedCache] putInCache:key result:result];
        video = (NSDictionary *)[result objectForKey:@"movie"];
        [self setPlayCellValue];
        [self initMovieEpisodeCell];
        NSArray *tempArray = (NSMutableArray *)[result objectForKey:@"comments"];
        [commentArray removeAllObjects];
        if(tempArray != nil && tempArray.count > 0){
            [commentArray addObjectsFromArray:tempArray];
        }
        if(pullToRefreshManager_ == nil && commentArray.count > 0){
            pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:_tableView withClient:self];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        [UIUtility showSystemError:self.view];
    }
    [self loadTable];
}

- (void)loadTable {
    [_tableView reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)setPlayCellValue
{
    name = [video objectForKey:@"name"];
    CGSize constraint = CGSizeMake(300, 20000.0f);
    CGSize size = [name sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    playCell.filmTitleLabel.text = name;
    [playCell.filmTitleLabel setNumberOfLines:0];
    [playCell.publicLabel sizeToFit];
    if(size.height < 30){
        playCell.publicLabel.textAlignment = UITextAlignmentRight;
        playCell.introuctionBtn.frame = CGRectMake(260, playCell.scoreImageView.frame.origin.y, 47, 30);
    } else {
        playCell.publicLabel.textAlignment = UITextAlignmentLeft;
        playCell.frame = CGRectMake(0, 0, self.view.frame.size.width, size.height + 3 * ROW_HEIGHT + 20);
        [playCell.filmTitleLabel setFrame:CGRectMake(playCell.filmTitleLabel.frame.origin.x, playCell.filmImageView.frame.origin.y + 10, size.width, size.height)];
        playCell.publicLabel.frame = CGRectMake(10, size.height + 20, 260, playCell.publicLabel.frame.size.height);
        playCell.scoreImageView.frame = CGRectMake(playCell.publicLabel.frame.origin.x, playCell.publicLabel.frame.origin.y + ROW_HEIGHT - 10, playCell.scoreImageView.frame.size.width, playCell.scoreImageView.frame.size.height);
        playCell.scoreLabel.frame = CGRectMake(playCell.publicLabel.frame.origin.x, playCell.publicLabel.frame.origin.y + ROW_HEIGHT - 10, playCell.scoreLabel.frame.size.width, playCell.scoreLabel.frame.size.height);
        playCell.introuctionBtn.frame = CGRectMake(260, playCell.scoreImageView.frame.origin.y, 47, 30);
        
        playCell.watchedImageView.frame = CGRectMake(playCell.watchedImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.watchedImageView.frame.size.width, playCell.watchedImageView.frame.size.height);
        playCell.watchedLabel.frame = CGRectMake(playCell.watchedLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.watchedLabel.frame.size.width, playCell.watchedLabel.frame.size.height);
        playCell.likeImageView.frame = CGRectMake(playCell.likeImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.likeImageView.frame.size.width, playCell.likeImageView.frame.size.height);
        playCell.likeLabel.frame = CGRectMake(playCell.likeLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.likeLabel.frame.size.width, playCell.likeLabel.frame.size.height);
        playCell.collectionImageView.frame = CGRectMake(playCell.collectionImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.collectionImageView.frame.size.width, playCell.collectionImageView.frame.size.height);
        playCell.collectionLabel.frame = CGRectMake(playCell.collectionLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.collectionLabel.frame.size.width, playCell.collectionLabel.frame.size.height);
        
    }
    [_imageView setImageWithURL:[NSURL URLWithString:[video objectForKey:@"poster"]] placeholderImage:[UIImage imageNamed:@"u0_normal"]];
    NSString *score = [video objectForKey:@"score"];
    if(![StringUtility stringIsEmpty:score] && ![score isEqualToString:@"0"]){
        playCell.scoreLabel.text = score;
    } else {
        playCell.scoreLabel.text = @"未评分";
    }
    playCell.watchedLabel.text = [NSString stringWithFormat:@"%@", [video objectForKey:@"watch_num"]];
    playCell.collectionLabel.text = [NSString stringWithFormat:@"%@", [video objectForKey:@"favority_num"]];
    playCell.likeLabel.text = [NSString stringWithFormat:@"%@", [video objectForKey:@"like_num"]];
}

- (void)initPlayCell
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
    playCell = (PlayCell *)[nib objectAtIndex:4];
    playCell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    playCell.filmImageView.frame = CGRectZero;
    //    [playCell.introuctionBtn setTitle: NSLocalizedString(@"introduction", nil) forState:UIControlStateNormal];
    [playCell.introuctionBtn addTarget:self action:@selector(showIntroduction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initPictureCell{
    static NSString *windowReuseIdentifier = @"scratchImageCell";
    pictureCell = [_tableView dequeueReusableCellWithIdentifier:windowReuseIdentifier];
    if (!pictureCell) {
        pictureCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:windowReuseIdentifier];
        pictureCell.backgroundColor             = [UIColor clearColor];
        pictureCell.contentView.backgroundColor = [UIColor clearColor];
        pictureCell.selectionStyle              = UITableViewCellSelectionStyleNone;
        playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setFrame:playImageView.frame];
        playButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [playButton addTarget:self action:@selector(playVideo)forControlEvents:UIControlEventTouchUpInside];
        playButton.center = pictureCell.center;
        [pictureCell.contentView addSubview:playButton];
    }
}

- (void)initMovieEpisodeCell
{
    episodeArray = [video objectForKey:@"episodes"];
    if(episodeArray.count > 1){
        dramaCell.frame = CGRectMake(0, 0, self.view.frame.size.width, ceil(episodeArray.count / 5.0) * 30 + 5);
        for (int i = 0; i < episodeArray.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.tag = i+1;
            [btn setFrame:CGRectMake(10 + (i % 5) * 61, 5 + floor(i / 5.0) * 30, 59, 25)];
            [btn setTitle:[NSString stringWithFormat:@"%@", [[episodeArray objectAtIndex:i] objectForKey:@"name"]] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
            [UIUtility addTextShadow:btn.titleLabel];
            btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
            UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
            [btn setBackgroundImage:[[UIImage imageNamed:@"unfocus"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIUtility createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(moviePlay:)forControlEvents:UIControlEventTouchUpInside];
            [dramaCell.contentView addSubview:btn];
        }
    }
}

- (void)moviePlay:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    [self playVideo:btn.tag];
}

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section < 3){
        return 1;
    } else {
        if(commentArray == nil || commentArray.count == 0){
            return 1;
        } else {
            return commentArray.count;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return pictureCell;
    } else if (indexPath.section ==1) {
        return playCell;
    } else if (indexPath.section == 2){
        return dramaCell;
    } else {
            if(commentArray == nil || commentArray.count == 0){
                NoRecordCell *cell = [self displayNoRecordCell:tableView];
                cell.textField.text = @"暂无评论";
                return cell;
            } else {
                CommentCell *cell = [self displayCommentCell:tableView cellForRowAtIndexPath:indexPath commentArray:commentArray cellIdentifier:@"commentCell"];
                return cell;
            }
        }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section > 2 && commentArray.count > 0){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        CommentViewController *viewController = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
        viewController.threadId = [[commentArray objectAtIndex:indexPath.row] valueForKey:@"id"];
        viewController.title = @"评论回复";
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return WindowHeight;
    } else if(indexPath.section == 1){
        return playCell.frame.size.height;
    } else if(indexPath.section == 2){
        return dramaCell.frame.size.height;
    } else {
        return [self caculateCommentCellHeight:indexPath.row dataArray:commentArray];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 0;
    } else if(section == 2 && episodeArray.count <= 1){
        return 0;
    } else {
        return 24;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return nil;
    }
    if(section == 2 && episodeArray.count <= 1){
        return nil;
    }
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 24)];
    customView.backgroundColor = [UIColor blackColor];
    
    // create the label objects
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,self.view.bounds.size.width-10, 24)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    if(section == 2){
        headerLabel.text =  @"电影列表";
    } else {
        headerLabel.text =  NSLocalizedString(@"user_comment", nil);
    }
    headerLabel.textColor = [UIColor whiteColor];
    [customView addSubview:headerLabel];
    
    return customView;
}

- (CommentCell *)displayCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath commentArray:(NSArray *)dataArray cellIdentifier:(NSString *)cellIdentifier
{
    CommentCell *cell = (CommentCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
        cell = (CommentCell *)[nib objectAtIndex:2];
    }
    //    cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    NSMutableDictionary *commentDic = [commentArray objectAtIndex:indexPath.row];
    NSString *ownerPicUrl = [commentDic valueForKey:@"owner_pic_url"];
    if([StringUtility stringIsEmpty:ownerPicUrl]){
        cell.avatarImageView.image = [UIImage imageNamed:@"u2_normal"];
    } else {
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:ownerPicUrl] placeholderImage:[UIImage imageNamed:@"u2_normal"]];
    }
    cell.avatarImageView.layer.cornerRadius = 25;
    cell.avatarImageView.layer.masksToBounds = YES;
    cell.titleLabel.text = [commentDic objectForKey:@"owner_name"];
    
    CGSize size = CGSizeZero;
    CGSize constraint = CGSizeMake(cell.titleLabel.frame.size.width, 20000.0f);
    if([StringUtility stringIsEmpty:[commentDic objectForKey:@"content"]]){
        cell.subtitleLabel.text = @"";
    } else {
        cell.subtitleLabel.text = [commentDic objectForKey:@"content"];
        size = [[commentDic objectForKey:@"content"] sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    }
    [cell.subtitleLabel setNumberOfLines:0];
    [cell.subtitleLabel setFrame:CGRectMake(cell.subtitleLabel.frame.origin.x, cell.subtitleLabel.frame.origin.y, size.width, size.height)];
    
    NSInteger yPosition = cell.subtitleLabel.frame.origin.y + size.height + 10;
    cell.thirdTitleLabel.frame = CGRectMake(cell.thirdTitleLabel.frame.origin.x, yPosition, cell.thirdTitleLabel.frame.size.width, cell.thirdTitleLabel.frame.size.height);
    
    TTTTimeIntervalFormatter *timeFormatter = [[TTTTimeIntervalFormatter alloc]init];
    NSString *createDate = [commentDic valueForKey:@"create_date"];
    NSDate *commentDate = [DateUtility dateFromFormatString:createDate formatString: @"yyyy-MM-dd HH:mm:ss"];
    NSString *timeDiff = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:commentDate];
    cell.thirdTitleLabel.text = timeDiff;
    
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
    if([num boolValue]){
        [cell.replyBtn setHidden:NO];
        cell.replyBtn.frame = CGRectMake(cell.thirdTitleLabel.frame.origin.x + 210, yPosition, 40, 20);
        [cell.replyBtn setTitle:NSLocalizedString(@"reply", nil) forState:UIControlStateNormal];
        [cell.replyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [cell.replyBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        cell.replyBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
        UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [cell.replyBtn setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateNormal];
        [cell.replyBtn setBackgroundImage:[UIImage imageNamed:@"background"] forState:UIControlStateHighlighted];
        [cell.replyBtn addTarget:self action:@selector(replyBtnClicked:)forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.replyBtn setHidden:YES];
    }
    [cell.avatarBtn addTarget:self action:@selector(avatarClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (NoRecordCell *)displayNoRecordCell:(UITableView *)tableView
{
    NoRecordCell *cell = (NoRecordCell*) [tableView dequeueReusableCellWithIdentifier:@"noRecordCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommonCellFactory" owner:self options:nil];
        cell = (NoRecordCell *)[nib objectAtIndex:0];
    }
    return cell;
}


- (CGFloat)caculateCommentCellHeight:(NSInteger)row dataArray:(NSArray *)dataArray
{
    if(dataArray == nil || dataArray.count == 0){
        return 44;
    } else {
        NSDictionary *commentDic = [dataArray objectAtIndex:row];
        NSString *content = [commentDic objectForKey:@"content"];
        if([StringUtility stringIsEmpty:content]){
            return 80;
        }
        CGSize constraint = CGSizeMake(232, 20000.0f);
        CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        return 80 + size.height;
    }
}

#pragma mark -
#pragma mark MNMBottomPullToRefreshManagerClient

/**
 * This is the same delegate method as UIScrollView but requiered on MNMBottomPullToRefreshManagerClient protocol
 * to warn about its implementation. Here you have to call [MNMBottomPullToRefreshManager tableViewScrolled]
 *
 * Tells the delegate when the user scrolls the content view within the receiver.
 *
 * @param scrollView: The scroll-view object in which the scrolling occurred.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateOffsets];
    [pullToRefreshManager_ tableViewScrolled];
}

/**
 * This is the same delegate method as UIScrollView but requiered on MNMBottomPullToRefreshClient protocol
 * to warn about its implementation. Here you have to call [MNMBottomPullToRefreshManager tableViewReleased]
 *
 * Tells the delegate when dragging ended in the scroll view.
 *
 * @param scrollView: The scroll-view object that finished scrolling the content view.
 * @param decelerate: YES if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [pullToRefreshManager_ tableViewReleased];
}

/**
 * Tells client that can reload table.
 * After reloading is completed must call [pullToRefreshMediator_ tableViewReloadFinished]
 */
- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.programId, @"prod_id", [NSNumber numberWithInt:reload], @"page_num",[NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathProgramComments parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *comArray = (NSMutableArray *)[result objectForKey:@"comments"];
            if(comArray != nil && comArray.count > 0){
                [commentArray addObjectsFromArray:comArray];
                reload++;
            }
        } else {
        }
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
    }];
    
}

- (void)showIntroduction{
    NSString *summary = [video objectForKey:@"summary"];
    IntroductionView *lplv = [[IntroductionView alloc] initWithTitle:name content:summary];
    lplv.frame = CGRectMake(0, 0, lplv.frame.size.width, lplv.frame.size.height * 0.8);
    lplv.center = CGPointMake(160, 210 + _tableView.contentOffset.y);
    lplv.delegate = self;
    [lplv showInView:self.view animated:YES];
    _tableView.scrollEnabled = NO;
}

- (void)leveyPopListViewDidCancel
{
    _tableView.scrollEnabled = YES;
}

- (void)avatarClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [_tableView convertPoint:point fromView:btn.superview];
    NSIndexPath* indexpath = [_tableView indexPathForRowAtPoint:point];
    
    HomeViewController *viewController = [[HomeViewController alloc]initWithNibName:@"HomeViewController" bundle:nil];
    viewController.userid = [[commentArray objectAtIndex:indexpath.row] valueForKey:@"owner_id"];
    if(![viewController.userid isEqualToString:@"0"]){
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)replyBtnClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [_tableView convertPoint:point fromView:btn.superview];
    NSIndexPath* indexpath = [_tableView indexPathForRowAtPoint:point];
    
    CommentViewController *viewController = [[CommentViewController alloc]initWithNibName:@"CommentViewController" bundle:nil];
    viewController.threadId = [[commentArray objectAtIndex:indexpath.row] valueForKey:@"id"];
    viewController.title = @"评论回复";
    viewController.openKeyBoard = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)playVideo
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [self playVideo:1];
}

- (void)playVideo:(NSInteger)num
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isWifiReachable)]){
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"" message:@"播放视频会消耗大量流量，您确定要在非WiFi环境下播放吗？"];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel", nil) block:nil];
        [alert setDestructiveButtonWithTitle:@"确定" block:^{
            [self willPlayVideo:num];
        }];
        [alert show];
    } else {
        [self willPlayVideo:num];
    }
}

- (void)willPlayVideo:(NSInteger)num
{
    NSArray *videoUrlArray = [[episodeArray objectAtIndex:num-1] objectForKey:@"down_urls"];
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
            [self showPlayWebPage];
        } else {
            MediaPlayerViewController *viewController = [[MediaPlayerViewController alloc]initWithNibName:@"MediaPlayerViewController" bundle:nil];
            viewController.videoUrl = videoUrl;
            [self presentModalViewController:viewController animated:YES];
        }
    }else {
        [self showPlayWebPage];
    }
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

- (void)showPlayWebPage
{
    ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
    NSArray *urlArray = [video objectForKey:@"video_urls"];
    viewController.programUrl = [[urlArray objectAtIndex:0] objectForKey:@"url"];
    viewController.title = [video objectForKey:@"name"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)initToolBar
{
    bottomToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - NAVIGATION_BAR_HEIGHT, self.view.frame.size.width, TAB_BAR_HEIGHT)];
    UIImage *toobarImage = [UIUtility createImageWithColor:[UIColor blackColor]];
    [bottomToolbar setBackgroundImage:toobarImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn1 setFrame:CGRectMake(0, 0, 78, TAB_BAR_HEIGHT)];
    [btn1 setTitle:NSLocalizedString(@"recommand_toolbar", nil) forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn1.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [UIUtility addTextShadow:btn1.titleLabel];
    btn1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [btn1 setBackgroundImage:[UIImage imageNamed:@"tab1"] forState:UIControlStateNormal];
    [btn1 setBackgroundImage:[UIUtility createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
    [btn1 addTarget:self action:@selector(recommand)forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn2 setFrame:CGRectMake(btn1.frame.origin.x + 80, 0, 78, TAB_BAR_HEIGHT)];
    [btn2 setTitle:NSLocalizedString(@"watch_toolbar", nil) forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn2.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [UIUtility addTextShadow:btn2.titleLabel];
    btn2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [btn2 setBackgroundImage:[UIImage imageNamed:@"tab2"] forState:UIControlStateNormal];
    [btn2 setBackgroundImage:[UIUtility createImageWithColor:[UIColor blackColor]]forState:UIControlStateHighlighted];
    [btn2 addTarget:self action:@selector(watch)forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:btn2];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn3 setFrame:CGRectMake(btn2.frame.origin.x + 80, 0, 78, TAB_BAR_HEIGHT)];
    [btn3 setTitle:NSLocalizedString(@"collect_toolbar", nil) forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn3.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [UIUtility addTextShadow:btn2.titleLabel];
    btn3.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [btn3 setBackgroundImage:[UIImage imageNamed:@"tab3"] forState:UIControlStateNormal];
    [btn3 setBackgroundImage:[UIUtility createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
    [btn3 addTarget:self action:@selector(collection)forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:btn3];
    
    UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn4 setFrame:CGRectMake(btn3.frame.origin.x + 80, 0, 78, TAB_BAR_HEIGHT)];
    [btn4 setTitle:NSLocalizedString(@"comment_toolbar", nil) forState:UIControlStateNormal];
    [btn4 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn4.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [UIUtility addTextShadow:btn2.titleLabel];
    btn4.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|
    UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [btn4 setBackgroundImage:[UIImage imageNamed:@"tab4"] forState:UIControlStateNormal];
    [btn4 setBackgroundImage:[UIUtility createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
    [btn4 addTarget:self action:@selector(comment)forControlEvents:UIControlEventTouchUpInside];
    bottomToolbar.layer.zPosition = 1;
    [bottomToolbar addSubview:btn4];
    
    [self.view addSubview:bottomToolbar];
}

- (void)loginScreen
{
    [[WBEngine sharedClient] logOut];
    NSString *username = (NSString *)[[ContainerUtility sharedInstance] attributeForKey:kUserName];
    [SFHFKeychainUtils deleteItemForUsername:username andServiceName:kUserLoginService error:nil];
    [[CacheUtility sharedCache] clear];
    [[ContainerUtility sharedInstance] clear];
    LoginViewController *viewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)share
{
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
    if(![num boolValue]){
        [self loginScreen];
    } else {
        PostViewController *viewController = [[PostViewController alloc]initWithNibName:@"PostViewController" bundle:nil];
        viewController.program = video;
        viewController.type = videoType;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)recommand
{
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
    if(![num boolValue]){
        [self loginScreen];
    } else {
        RecommandViewController *viewController = [[RecommandViewController alloc]initWithNibName:@"RecommandViewController" bundle:nil];
        viewController.program = video;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)watch
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
    if(![num boolValue]){
        [self loginScreen];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.programId, @"prod_id",
                                    nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathProgramWatch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.dimBackground = YES;
            if([responseCode isEqualToString:kSuccessResCode]){
                HUD.labelText = NSLocalizedString(@"mark_success", nil);
                playCell.watchedLabel.text = [NSString stringWithFormat:@"%i", [playCell.watchedLabel.text intValue] + 1 ];
            } else {
                HUD.labelText = @"已看过。";
            }
            [HUD show:YES];
            [HUD hide:YES afterDelay:1];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

- (void)collection
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
    if(![num boolValue]){
        [self loginScreen];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.programId, @"prod_id",
                                    nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathProgramFavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.dimBackground = YES;
            if([responseCode isEqualToString:kSuccessResCode]){
                HUD.labelText = NSLocalizedString(@"collection_success", nil);
                playCell.collectionLabel.text = [NSString stringWithFormat:@"%i", [playCell.collectionLabel.text intValue] + 1 ];
            } else {
                HUD.labelText = @"已收藏！";
            }
            [HUD show:YES];
            [HUD hide:YES afterDelay:1];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

- (void)comment
{
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
    if(![num boolValue]){
        [self loginScreen];
    } else {
        SendCommentViewController *viewController = [[SendCommentViewController alloc]initWithNibName:@"SendCommentViewController" bundle:nil];
        viewController.program = video;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)closeSelf
{
    UIViewController *viewController = [self.navigationController popViewControllerAnimated:YES];
    if(viewController == nil){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (CommentCell *)displayFriendCommentCell:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath commentArray:(NSArray *)dataArray cellIdentifier:(NSString *)cellIdentifier
{
    CommentCell *cell = (CommentCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
        cell = (CommentCell *)[nib objectAtIndex:2];
    }
    return cell;
}

- (LoadMoreCell *)displayLoadMoreCell:(UITableView *)tableView
{
    LoadMoreCell *cell = (LoadMoreCell*) [tableView dequeueReusableCellWithIdentifier:@"loadMoreCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendCellFactory" owner:self options:nil];
        cell = (LoadMoreCell *)[nib objectAtIndex:0];
    }
    return cell;
}

- (void)postInitialization:(NSDictionary *)result;
{
    //interface for sub-class
}

@end
