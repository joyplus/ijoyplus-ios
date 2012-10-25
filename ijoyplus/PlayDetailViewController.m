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

#define ROW_HEIGHT 40

@implementation PlayDetailViewController
@synthesize programId;
@synthesize userId;
- (void)viewDidUnload
{
    _imageView = nil;
    _imageScroller = nil;
    _tableView = nil;
    commentArray = nil;
    playCell = nil;
    movie = nil;
    pullToRefreshManager_ = nil;
    playImageView = nil;
    playButton = nil;
    bottomToolbar = nil;
    pictureCell = nil;
    userId = nil;
    name = nil;
    [super viewDidUnload];
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
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSString *key = [NSString stringWithFormat:@"%@%@", @"movie", self.programId];
        id cacheResult = [[CacheUtility sharedCache] loadFromCache:key];
        [self parseData:cacheResult];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kAppKey, @"app_key",
                                    self.programId, @"prod_id",
                                    nil];
        
        [[AFServiceAPIClient sharedClient] getPath:kPathProgramView parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *key = [NSString stringWithFormat:@"%@%@", @"movie", self.programId];
            [[CacheUtility sharedCache] putInCache:key result:result];
            [self parseData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

- (void)parseData:(id)result
{
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        movie = (NSDictionary *)[result objectForKey:@"movie"];
        [self setPlayCellValue];
        NSArray *tempArray = (NSMutableArray *)[result objectForKey:@"comments"];
        if(tempArray != nil && tempArray.count > 0){
            [commentArray addObjectsFromArray:tempArray];
        }
        if(pullToRefreshManager_ == nil && commentArray.count > 0){
            pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:_tableView withClient:self];
        }
        [self loadTable];
    } else {
        
    }
}

- (void)loadTable {
    [_tableView reloadData];
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)setPlayCellValue
{
    name = [movie objectForKey:@"name"];
    CGSize constraint = CGSizeMake(300, 20000.0f);
    CGSize size = [name sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    playCell.filmTitleLabel.text = name;
    [playCell.filmTitleLabel setNumberOfLines:0];
    [playCell.publicLabel sizeToFit];
    if(size.height < 30){
        playCell.publicLabel.textAlignment = UITextAlignmentRight;
    } else {
        playCell.publicLabel.textAlignment = UITextAlignmentLeft;
        playCell.frame = CGRectMake(0, 0, self.view.frame.size.width, size.height + 3 * ROW_HEIGHT + 20);
        [playCell.filmTitleLabel setFrame:CGRectMake(playCell.filmTitleLabel.frame.origin.x, playCell.filmImageView.frame.origin.y + 10, size.width, size.height)];
        playCell.publicLabel.frame = CGRectMake(10, size.height + 20, 260, playCell.publicLabel.frame.size.height);
        playCell.introuctionBtn.center = CGPointMake(playCell.introuctionBtn.center.x, playCell.publicLabel.center.y);
        playCell.scoreImageView.frame = CGRectMake(playCell.publicLabel.frame.origin.x, playCell.publicLabel.frame.origin.y + ROW_HEIGHT - 10, playCell.scoreImageView.frame.size.width, playCell.scoreImageView.frame.size.height);
        playCell.scoreLabel.frame = CGRectMake(playCell.publicLabel.frame.origin.x, playCell.publicLabel.frame.origin.y + ROW_HEIGHT - 10, playCell.scoreLabel.frame.size.width, playCell.scoreLabel.frame.size.height);
        
        playCell.watchedImageView.frame = CGRectMake(playCell.watchedImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.watchedImageView.frame.size.width, playCell.watchedImageView.frame.size.height);
        playCell.watchedLabel.frame = CGRectMake(playCell.watchedLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.watchedLabel.frame.size.width, playCell.watchedLabel.frame.size.height);
        playCell.likeImageView.frame = CGRectMake(playCell.likeImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.likeImageView.frame.size.width, playCell.likeImageView.frame.size.height);
        playCell.likeLabel.frame = CGRectMake(playCell.likeLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.likeLabel.frame.size.width, playCell.likeLabel.frame.size.height);
        playCell.collectionImageView.frame = CGRectMake(playCell.collectionImageView.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.collectionImageView.frame.size.width, playCell.collectionImageView.frame.size.height);
        playCell.collectionLabel.frame = CGRectMake(playCell.collectionLabel.frame.origin.x, playCell.scoreImageView.frame.origin.y + ROW_HEIGHT, playCell.collectionLabel.frame.size.width, playCell.collectionLabel.frame.size.height);
        
    }
    [_imageView setImageWithURL:[NSURL URLWithString:[movie objectForKey:@"poster"]] placeholderImage:[UIImage imageNamed:@"u0_normal"]];
    NSString *score = [movie objectForKey:@"score"];
    if(![StringUtility stringIsEmpty:score] && ![score isEqualToString:@"0"]){
        playCell.scoreLabel.text = score;
    } else {
        playCell.scoreLabel.text = @"未评分";
    }
    playCell.watchedLabel.text = [movie objectForKey:@"watch_num"];
    playCell.collectionLabel.text = [movie objectForKey:@"favority_num"];
    playCell.likeLabel.text = [movie objectForKey:@"like_num"];
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

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 || section == 1){
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
    } else {
        if (indexPath.section ==1) {
            return playCell;
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section > 1 && commentArray.count > 0){
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
    } else {
        return [self caculateCommentCellHeight:indexPath.row dataArray:commentArray];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 0;
    } else {
        return 24;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return nil;
    }
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, 24)];
    customView.backgroundColor = [UIColor blackColor];
    
    // create the label objects
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,self.view.bounds.size.width-10, 24)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    headerLabel.text =  NSLocalizedString(@"user_comment", nil);
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
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:kAppKey, @"app_key", self.programId, @"prod_id", [NSNumber numberWithInt:reload], @"page_num",[NSNumber numberWithInt:pageSize], @"page_size", nil];
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
    NSString *summary = [movie objectForKey:@"summary"];
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
    [self.navigationController pushViewController:viewController animated:YES];
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
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isWifiReachable)]){
        BlockAlertView *alert = [BlockAlertView alertWithTitle:@"" message:@"播放视频会消耗大量流量，您确定要在非WiFi环境下播放吗？"];
        [alert setCancelButtonWithTitle:NSLocalizedString(@"cancel", nil) block:nil];
        [alert setDestructiveButtonWithTitle:@"确定" block:^{
            [self showPlayWebPage];
        }];
        [alert show];
    } else {
        [self showPlayWebPage];
    }
    

}

- (void)showPlayWebPage
{
    ProgramViewController *viewController = [[ProgramViewController alloc]initWithNibName:@"ProgramViewController" bundle:nil];
    NSArray *urlArray = [movie objectForKey:@"video_urls"];
    viewController.programUrl = [[urlArray objectAtIndex:0] objectForKey:@"url"];
    viewController.title = [movie objectForKey:@"name"];
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

- (void)share
{
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
    if(![num boolValue]){
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"请登陆！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    } else {
        PostViewController *viewController = [[PostViewController alloc]initWithNibName:@"PostViewController" bundle:nil];
        viewController.programId = self.programId;
        viewController.programName = name;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)recommand
{
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
    if(![num boolValue]){
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"请登陆！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    } else {
        RecommandViewController *viewController = [[RecommandViewController alloc]initWithNibName:@"RecommandViewController" bundle:nil];
        viewController.programId = self.programId;
        viewController.programName = name;
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
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"请登陆！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kAppKey, @"app_key",
                                    self.programId, @"prod_id",
                                    nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathProgramWatch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                [self.navigationController.view addSubview:HUD];
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = NSLocalizedString(@"mark_success", nil);
                HUD.dimBackground = YES;
                [HUD show:YES];
                [HUD hide:YES afterDelay:1];
                [self getProgramView];
            } else {
                
            }
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
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"请登陆！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    } else {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kAppKey, @"app_key",
                                    self.programId, @"prod_id",
                                    nil];
        [[AFServiceAPIClient sharedClient] postPath:kPathProgramFavority parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if([responseCode isEqualToString:kSuccessResCode]){
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
                [self.navigationController.view addSubview:HUD];
                HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.labelText = NSLocalizedString(@"collection_success", nil);
                HUD.dimBackground = YES;
                [HUD show:YES];
                [HUD hide:YES afterDelay:1];
                [self getProgramView];
            } else {
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}

- (void)comment
{
    NSNumber *num = (NSNumber *)[[ContainerUtility sharedInstance]attributeForKey:kUserLoggedIn];
    if(![num boolValue]){
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"请登陆！";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1.5];
    } else {
        SendCommentViewController *viewController = [[SendCommentViewController alloc]initWithNibName:@"SendCommentViewController" bundle:nil];
        viewController.programId = self.programId;
        viewController.programName = name;
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
