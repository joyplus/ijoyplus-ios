#import "MyselfViewController.h"
#import "MyProfileCell.h"
#import "CMConstants.h"
#import "UIImageView+WebCache.h"
#import "TTTTimeIntervalFormatter.h"


@interface MyselfViewController(){
    NSMutableArray *itemsArray;
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

- (void)loadTable;

@end

@implementation MyselfViewController

@synthesize table;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.table setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
//    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"notification_center", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(notificatonCenter)];
//    self.navigationItem.leftBarButtonItem = leftButton;
//    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"settings", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(settings)];
//    self.navigationItem.rightBarButtonItem = rightButton;
    NSMutableArray *items1 = [[NSMutableArray alloc]initWithCapacity:20];
    [items1 addObject:@"First"];
    [items1 addObject:@"Second"];
    [items1 addObject:@"Third"];
    
    NSMutableArray *items2 = [[NSMutableArray alloc]initWithCapacity:20];
    [items2 addObject:@"1"];
    [items2 addObject:@"2"];
    [items2 addObject:@"3"];
    
    NSMutableArray *items3 = [[NSMutableArray alloc]initWithCapacity:20];
    [items3 addObject:@"壹"];
    
    NSMutableDictionary *itemDic1 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic1 setValue:items1 forKey:@"2012-09-03"];
    
    NSMutableDictionary *itemDic2 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic2 setValue:items2 forKey:@"2012-09-04"];
    
    NSMutableDictionary *itemDic3 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic3 setValue:items3 forKey:@"2012-09-05"];
    
    //    NSMutableDictionary *itemDic4 = [[NSMutableDictionary alloc]initWithCapacity:10];
    //    [itemDic4 setValue:items1 forKey:@"2012-09-06"];
    //
    //    NSMutableDictionary *itemDic5 = [[NSMutableDictionary alloc]initWithCapacity:10];
    //    [itemDic5 setValue:items1 forKey:@"2012-09-07"];
    
    itemsArray = [[NSMutableArray alloc]initWithCapacity:10];
    [itemsArray addObject:itemDic1];
    [itemsArray addObject:itemDic2];
    [itemsArray addObject:itemDic3];
    //    [itemsArray addObject:itemDic4];
    //    [itemsArray addObject:itemDic5];
    
    pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:table withClient:self];
    [self loadTable];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.table.bounds.size.height, self.view.frame.size.width, self.table.bounds.size.height)];
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_up"]];
		view.delegate = self;
		[self.table addSubview:view];
		_refreshHeaderView = view;
		
	}
	[_refreshHeaderView refreshLastUpdatedDate];
    
}

- (void)viewDidUnload {
    itemsArray = nil;
    self.table = nil;
    _refreshHeaderView = nil;
    pullToRefreshManager_ = nil;
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Aux view method
- (void)loadTable {
    
    [self.table reloadData];
    
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return itemsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableDictionary *item = [itemsArray objectAtIndex:section];
    NSEnumerator *keys = item.keyEnumerator;
    NSString *key = [keys nextObject];
    NSMutableArray *array = [item objectForKey:key];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyCellFactory" owner:self options:nil];
    MyProfileCell *myCell = (MyProfileCell *)[nib objectAtIndex:0];

    NSMutableDictionary *item = [itemsArray objectAtIndex:indexPath.section];
    NSEnumerator *keys = item.keyEnumerator;
    NSMutableArray *items = [item objectForKey:[keys nextObject]];
    [myCell.avatarImageView setImageWithURL:[NSURL URLWithString:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    myCell.avatarImageView.layer.cornerRadius = 25;
    myCell.avatarImageView.layer.masksToBounds = YES;
    myCell.titleLabel.text = [items objectAtIndex:indexPath.row];
    myCell.subtitleLabel.text = @"我看过电影名";
    myCell.titleLabel.text = [items objectAtIndex:indexPath.row];
    [myCell.filmImageView setImageWithURL:[NSURL URLWithString:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    myCell.filmImageView.layer.borderWidth = 1;
    myCell.filmImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    myCell.filmImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    myCell.filmImageView.layer.shadowOffset = CGSizeMake(1, 1);
    myCell.filmImageView.layer.shadowOpacity = 1;
    
    TTTTimeIntervalFormatter *timeFormatter = [[TTTTimeIntervalFormatter alloc]init];
    NSString *timeDiff = [timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:[NSDate date]];
    myCell.thirdTitleLabel.text = timeDiff;
    return myCell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int imageHeight = 135;
    return imageHeight + 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,24)];
    customView.backgroundColor = [UIColor blackColor];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    NSMutableDictionary *item = [itemsArray objectAtIndex:section];
    NSEnumerator *keys = item.keyEnumerator;
    NSString *key = [keys nextObject];
    headerLabel.text =  key;
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel sizeToFit];
    headerLabel.center = CGPointMake(headerLabel.frame.size.width/2 + 10, customView.frame.size.height/2);
    [customView addSubview:headerLabel];
    return customView;
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
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
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
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    [pullToRefreshManager_ tableViewReleased];
}

/**
 * Tells client that can reload table.
 * After reloading is completed must call [pullToRefreshMediator_ tableViewReloadFinished]
 */
- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    
    // Test loading
    
    reloads_++;
    NSMutableArray *items1 = [[NSMutableArray alloc]initWithCapacity:20];
    [items1 addObject:@"First"];
    [items1 addObject:@"Second"];
    [items1 addObject:@"Third"];
    
    NSMutableArray *items2 = [[NSMutableArray alloc]initWithCapacity:20];
    [items2 addObject:@"1"];
    [items2 addObject:@"2"];
    [items2 addObject:@"3"];
    
    NSMutableArray *items3 = [[NSMutableArray alloc]initWithCapacity:20];
    [items3 addObject:@"壹"];
    
    NSMutableDictionary *itemDic1 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic1 setValue:items1 forKey:@"2012-09-06"];
    
    NSMutableDictionary *itemDic2 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic2 setValue:items2 forKey:@"2012-09-07"];
    
    NSMutableDictionary *itemDic3 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic3 setValue:items3 forKey:@"2012-09-08"];
    
    [itemsArray addObject:itemDic1];
    [itemsArray addObject:itemDic2];
    [itemsArray addObject:itemDic3];
    [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.table];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


@end