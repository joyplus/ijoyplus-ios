#import "MyselfViewController.h"

@interface MyselfViewController(){
    NSMutableArray *itemsArray;
}

- (void)notificatonCenter;
- (void)settings;
- (void)loadTable;

@end

@implementation MyselfViewController

@synthesize table;
@synthesize myProfileCell;

#pragma mark -
#pragma mark Memory management

/**
 * Deallocates used memory
 */
- (void)dealloc {
    self.table = nil;
    pullToRefreshManager_ = nil;
}

#pragma mark -
#pragma mark View cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"app_name", nil);
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"notification_center", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(notificatonCenter)];
    self.navigationItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"settings", nil) style:UIBarButtonSystemItemSearch target:self action:@selector(settings)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}
- (void)viewDidUnload {
    [self setMyProfileCell:nil];
    [super viewDidUnload];
    
    self.table = nil;
    pullToRefreshManager_ = nil;
}

#pragma mark -
#pragma mark Aux view method
- (void)loadTable {
    
    [self.table reloadData];
    
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)notificatonCenter
{
    
}
- (void)settings
{
    
}

#pragma mark -
#pragma mark UITableView methods


- (void)viewWillAppear:(BOOL)animated
{
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return itemsArray.count + 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section > 2){
        NSMutableDictionary *item = [itemsArray objectAtIndex:section - 3];
        NSEnumerator *keys = item.keyEnumerator;
        NSString *key = [keys nextObject];
        NSMutableArray *array = [item objectForKey:key];
        return array.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        self.myProfileCell.usernameLabel.text = @"Joy+";
        return self.myProfileCell;
    } else if(indexPath.section == 1){
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"aaa"];
        cell.textLabel.text = @"aaa";
        return cell;
    } else if(indexPath.section == 2){
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bbb"];
        cell.textLabel.text = @"aaa";
        return cell;
    } else {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:   CellIdentifier];
        }
        NSMutableDictionary *item = [itemsArray objectAtIndex:indexPath.section - 3];
        NSEnumerator *keys = item.keyEnumerator;
        NSMutableArray *items = [item objectForKey:[keys nextObject]];
        cell.textLabel.text = [items objectAtIndex:indexPath.row];
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 240;
    } else if(indexPath.section == 1){
        return 80;
    } else if(indexPath.section == 2){
        return 80;
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 0;
    } else{
        return 24;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return nil;
    } else{
        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,24)];
        customView.backgroundColor = [UIColor blackColor];
    
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:12];
        if(section == 1){
            headerLabel.text =  NSLocalizedString(@"my_followed", nil);
        } else if(section == 2){
            headerLabel.text =  NSLocalizedString(@"my_fans", nil);
        } else {
            NSMutableDictionary *item = [itemsArray objectAtIndex:section - 3];
            NSEnumerator *keys = item.keyEnumerator;
            NSString *key = [keys nextObject];
            headerLabel.text =  key;
        }
        headerLabel.textColor = [UIColor whiteColor];
        [headerLabel sizeToFit];
        headerLabel.center = CGPointMake(headerLabel.frame.size.width/2 + 10, customView.frame.size.height/2);
        [customView addSubview:headerLabel];
        return customView;
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

@end