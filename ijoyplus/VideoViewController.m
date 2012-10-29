#import "VideoViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "VideoPlayDetailViewController.h"
#import "CMConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "ContainerUtility.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "CacheUtility.h"
#import "UIUtility.h"

@interface VideoViewController(){
    WaterflowView *flowView;
    NSMutableArray *videoArray;
    int pageSize;
}
- (void)addContentView;
@end

@implementation VideoViewController

- (void)didReceiveMemoryWarning
{
    NSLog(@"receive memory warning in %@", self.class);
}

- (void)viewDidUnload
{
    flowView = nil;
    videoArray = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    pageSize = 15;
    [self addContentView];
    id cacheResult = [[CacheUtility sharedCache] loadFromCache:@"VideoViewController"];
    [self parseData:cacheResult];
    [flowView reloadData];
    if([[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"1", @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathVideo parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            [self parseData:result];
            [flowView reloadData];
            [[CacheUtility sharedCache] putInCache:@"VideoViewController" result:result];
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            videoArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
        }];
    }
}

- (void)parseData:(id)result
{
    videoArray = [[NSMutableArray alloc]initWithCapacity:pageSize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    NSString *responseCode = [result objectForKey:@"res_code"];
    if(responseCode == nil){
        NSArray *videos = [result objectForKey:@"video"];
        if(videos.count > 0){
            [videoArray addObjectsFromArray:videos];
        }
    } else {
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if(videoArray == nil){
        [self showProgressBar];
    }
}

- (void)addContentView
{
    if(flowView != nil){
        [flowView removeFromSuperview];
    }
    flowView = [[WaterflowView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height -135)];
    flowView.parentControllerName = @"VideoViewController";
    flowView.defaultScrollViewHeight = (VIDEO_LOGO_HEIGHT + MOVE_NAME_LABEL_HEIGHT) * (pageSize/3);
    [flowView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    flowView.cellSelectedNotificationName = @"videoSelected";
    [flowView showsVerticalScrollIndicator];
    flowView.flowdatasource = self;
    flowView.flowdelegate = self;
    [self.view addSubview:flowView];
    [flowView reloadData];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark-
#pragma mark- WaterflowDataSource

- (NSInteger)numberOfColumnsInFlowView:(WaterflowView *)flowView
{
    return NUMBER_OF_COLUMNS;
}

- (NSInteger)flowView:(WaterflowView *)flowView numberOfRowsInColumn:(NSInteger)column
{
    return 5;
}

- (WaterFlowCell*)flowView:(WaterflowView *)flowView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row * 3 + indexPath.section >= videoArray.count){
        return nil;
    }
    static NSString *CellIdentifier = @"Cell";
    WaterFlowCell *cell = [flowView_ dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil){
		cell  = [[WaterFlowCell alloc] initWithReuseIdentifier:CellIdentifier];
        cell.cellSelectedNotificationName = flowView.cellSelectedNotificationName;
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        imageView.layer.shadowOffset = CGSizeMake(1, 1);
        imageView.layer.shadowOpacity = 1;
        imageView.tag = 3001;
        [cell addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = CMConstants.titleFont;
        titleLabel.tag = 3002;
        [cell addSubview:titleLabel];
    }
    UIImageView *imageView  = (UIImageView *)[cell viewWithTag:3001];
    if(indexPath.section == 0){
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, 0, VIDEO_LOGO_WIDTH, VIDEO_LOGO_HEIGHT);
    } else if(indexPath.section == NUMBER_OF_COLUMNS - 1){
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, VIDEO_LOGO_WIDTH, VIDEO_LOGO_HEIGHT);
    } else {
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, VIDEO_LOGO_WIDTH, VIDEO_LOGO_HEIGHT);
    }
    NSDictionary *movie = [videoArray objectAtIndex:indexPath.row * 3 + indexPath.section];
    NSString *url = [movie valueForKey:@"prod_pic_url"];
    if([StringUtility stringIsEmpty:url]){
        imageView.image = [UIImage imageNamed:@"video_placeholder"];
    } else {
        [imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"video_placeholder"]];
    }

    UILabel *titleLabel = (UILabel *)[cell viewWithTag:3002];
    titleLabel.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, VIDEO_LOGO_HEIGHT, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT);
    NSString *name = [movie valueForKey:@"prod_name"];
    if([StringUtility stringIsEmpty:name]){
        titleLabel.text = @"...";
    } else {
        titleLabel.text = name;
    }
    return cell;
    
}

#pragma mark-
#pragma mark- WaterflowDelegate
-(CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row * 3 + indexPath.section >= videoArray.count){
        return 0;
    }
	return VIDEO_LOGO_HEIGHT + MOVE_NAME_LABEL_HEIGHT;
    
}

- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navController = (UINavigationController *)appDelegate.window.rootViewController;
    VideoPlayDetailViewController *viewController = [[VideoPlayDetailViewController alloc]initWithStretchImage];
    NSDictionary *movie = [videoArray objectAtIndex:indexPath.row * 3 + indexPath.section];
    viewController.programId = [movie objectForKey:@"prod_id"];
    //    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    [navController pushViewController:viewController animated:YES];
}

- (void)flowView:(WaterflowView *)_flowView willLoadData:(int)page
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%i", page], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathVideo parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *videos = [result objectForKey:@"video"];
            if(videos.count > 0){
                [videoArray addObjectsFromArray:videos];
            }
        } else {
            
        }
        [flowView performSelector:@selector(reloadData) withObject:nil afterDelay:2.0];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)flowView:(WaterflowView *)_flowView refreshData:(int)page
{
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [videoArray removeAllObjects];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%i", 1], @"page_num", [NSNumber numberWithInt:pageSize], @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathVideo parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *videos = [result objectForKey:@"video"];
            if(videos.count > 0){
                [videoArray addObjectsFromArray:videos];
            }
        } else {
            
        }
        [flowView performSelector:@selector(reloadData) withObject:nil afterDelay:2.0];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
         [flowView performSelector:@selector(reloadData) withObject:nil afterDelay:2.0];
    }];
}
@end
