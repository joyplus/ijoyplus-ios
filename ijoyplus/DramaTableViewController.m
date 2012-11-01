#import "DramaTableViewController.h"
#import "MyProfileCell.h"
#import "CMConstants.h"
#import "UIImageView+WebCache.h"
#import "TTTTimeIntervalFormatter.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "DateUtility.h"
#import "HomeViewController.h"
#import "ShowPlayDetailViewController.h"
#import "DramaPlayDetailViewController.h"
#import "VideoPlayDetailViewController.h"
#import "PlayDetailViewController.h"
#import "CacheUtility.h"
#import "UIUtility.h"
#import "Reachability.h"

@interface DramaTableViewController(){
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    NSMutableArray *videoArray;
    int pageSize;
}

@end

@implementation DramaTableViewController

@synthesize table;

- (void)viewDidUnload {
    [super viewDidUnload];
    self.table = nil;
    pullToRefreshManager_ = nil;
    videoArray = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.table setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];   
    pageSize = 30;
}

- (void)parseData:(id)result
{
    videoArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        [[CacheUtility sharedCache] putInCache:@"DramaViewController" result:result];
        NSArray *videos = [result objectForKey:@"tv"];
        if(videos.count > 0){
            [videoArray addObjectsFromArray:videos];
            [self.table reloadData];
            reloads_ ++;
        }
    } else {
        [UIUtility showSystemError:self.view];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(videoArray == nil && HUD == nil && [[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [self showProgressBar];
    }
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"DramaViewController"];
    if(cacheResult != nil){
        [self parseData:cacheResult];
    }
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathTV parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            videoArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    }
    //    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:table withClient:self];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if(videoArray.count % 3 == 0){
//        return videoArray.count / 3;
//    } else {
//        return floor(videoArray.count / 3) + 1;
//    }
    return floor(videoArray.count / 3);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int num = 3;
    if(videoArray.count < (indexPath.row+1) * 3){
        num = videoArray.count - indexPath.row * 3;
    }
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        for(int i = 0; i < num; i++){
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
            imageView.layer.borderWidth = 1;
            imageView.layer.borderColor = CMConstants.imageBorderColor.CGColor;
            imageView.layer.shadowColor = [UIColor blackColor].CGColor;
            imageView.layer.shadowOffset = CGSizeMake(1, 1);
            imageView.layer.shadowOpacity = 1;
            imageView.tag = 1000 + (i+1);
            [cell addSubview:imageView];
            
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            titleLabel.textAlignment = UITextAlignmentCenter;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.font = CMConstants.titleFont;
            titleLabel.tag = 2000 + (i+2);
            [cell addSubview:titleLabel];
            
            if(i == 0){
                imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
                titleLabel.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, MOVIE_LOGO_HEIGHT, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT);
            } else if(i == 1){
                imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH + MOVIE_LOGO_WIDTH_GAP*1.5, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
                titleLabel.frame = CGRectMake(MOVIE_LOGO_WIDTH + MOVIE_LOGO_WIDTH_GAP*1.5, MOVIE_LOGO_HEIGHT, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT);
            } else {
                imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH*2 + MOVIE_LOGO_WIDTH_GAP*2, 0, MOVIE_LOGO_WIDTH, MOVIE_LOGO_HEIGHT);
                titleLabel.frame = CGRectMake(MOVIE_LOGO_WIDTH*2 + MOVIE_LOGO_WIDTH_GAP*2, MOVIE_LOGO_HEIGHT, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT);
            }
            
            UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [imageBtn setFrame:imageView.frame];
            imageBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
            [imageBtn addTarget:self action:@selector(filmImageClicked:)forControlEvents:UIControlEventTouchUpInside];
            imageBtn.tag = 3000 + i;
            [cell addSubview:imageBtn];
        }
    }
    
    for(int i = 0; i < num; i++){
        NSDictionary *movie = [videoArray objectAtIndex:indexPath.row * 3 + i];
        UIImageView *imageView  = (UIImageView *)[cell viewWithTag:1000 + (i+1)];
        NSString *url = [movie valueForKey:@"prod_pic_url"];
        if([StringUtility stringIsEmpty:url]){
            imageView.image = [UIImage imageNamed:@"movie_placeholder"];
        } else {
            [imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"movie_placeholder"]];
        }
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:2000 + (i+2)];
        NSString *name = [movie valueForKey:@"prod_name"];
        if([StringUtility stringIsEmpty:name]){
            titleLabel.text = @"...";
        } else {
            titleLabel.text = name;
        }
    }
    return cell;
}

- (void)filmImageClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGPoint point = btn.center;
    point = [self.table convertPoint:point fromView:btn.superview];
    NSIndexPath* indexPath = [self.table indexPathForRowAtPoint:point];
    int index = indexPath.row * 3 + btn.tag - 3000;
    DramaPlayDetailViewController *viewController = [[DramaPlayDetailViewController alloc] initWithStretchImage];
    NSDictionary *movie = [videoArray objectAtIndex:index];
    viewController.programId = [movie objectForKey:@"prod_id"];
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MOVIE_LOGO_HEIGHT + MOVE_NAME_LABEL_HEIGHT;
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
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
        return;
    }
}

@end