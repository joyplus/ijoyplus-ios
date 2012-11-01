//
//  SearchFilmResultViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-10.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SearchFilmResultViewController.h"
#import "SearchFilmCell.h"
#import "UIImageView+WebCache.h"
#import "SearchVideoCell.h"
#import "PlayDetailViewController.h"
#import "CustomBackButton.h"
#import "CustomCellBlackBackground.h"
#import "CustomCellBackground.h"
#import "CMConstants.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ContainerUtility.h"
#import "DateUtility.h"
#import "NSDate-Utilities.h"
#import "ShowPlayDetailViewController.h"
#import "DramaPlayDetailViewController.h"
#import "VideoPlayDetailViewController.h"
#import "MBProgressHUD.h"

@interface SearchFilmResultViewController (){
    NSMutableArray *itemsArray;
    //    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
    MBProgressHUD *HUD;
    CustomBackButton *backButton;
}
- (void)closeSelf;
@end

@implementation SearchFilmResultViewController

@synthesize keyword;
@synthesize sBar;

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setSBar:nil];
    self.keyword = nil;
    [itemsArray removeAllObjects];
    itemsArray = nil;
    //    _refreshHeaderView = nil;
    pullToRefreshManager_ = nil;
    HUD = nil;
    backButton = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"top_segment_clicked" object:nil];
}

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
    self.title = NSLocalizedString(@"search", nil);
    backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	
    [self.sBar setText:self.keyword];
    self.sBar.delegate = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideProgressBar) name:@"top_segment_clicked" object:nil];

    //    if (_refreshHeaderView == nil) {
    //		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.table.bounds.size.height, self.view.frame.size.width, self.table.bounds.size.height)];
    //        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_up"]];
    //		view.delegate = self;
    //		[self.table addSubview:view];
    //		_refreshHeaderView = view;
    //
    //	}
    //	[_refreshHeaderView refreshLastUpdatedDate];
}


- (void)viewWillAppear:(BOOL)animated
{
    if(itemsArray == nil){
        [self showProgressBar];
    }
    [self getResult];
}

- (void)showProgressBar
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.opacity = 0;
    [HUD show:YES];
}

- (void) hideProgressBar
{
    [HUD hide:YES afterDelay:0.3];
}

- (void)loadTable {
    
    [self.tableView reloadData];
    
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getResult
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.keyword, @"keyword", @"1", @"page_num", @"10", @"page_size", nil];
    [[AFServiceAPIClient sharedClient] postPath:kPathSearch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        itemsArray = [[NSMutableArray alloc]initWithCapacity:10];
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *searchResult = [result objectForKey:@"results"];
            if(searchResult != nil && searchResult.count > 0){
                [itemsArray addObjectsFromArray:searchResult];
            }
            if(pullToRefreshManager_ == nil){
                pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:self.tableView withClient:self];
            }
            [self loadTable];
        } else {
            
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        itemsArray = [[NSMutableArray alloc]initWithCapacity:10];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"top_segment_clicked" object:self userInfo:nil];
    }];
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
    return itemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *searchObject = [itemsArray objectAtIndex:indexPath.row];
    NSString *type = [searchObject objectForKey:@"prod_type"];
    if([type isEqualToString:@"1"] || [type isEqualToString:@"2"]){
        SearchFilmCell *cell = (SearchFilmCell*) [tableView dequeueReusableCellWithIdentifier:@"searchFilmCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
            cell = (SearchFilmCell *)[nib objectAtIndex:0];
            UIView *backgroundView;
            if(indexPath.row % 2 == 0){
                backgroundView = [[CustomCellBlackBackground alloc]init];
            } else {
                backgroundView = [[CustomCellBackground alloc]init];
            }
            [cell setBackgroundView:backgroundView];
        }
        NSString *url = [searchObject objectForKey:@"prod_pic_url"];
        if([StringUtility stringIsEmpty:url]){
            cell.filmImageView.image = [UIImage imageNamed:@"movie_placeholder"];
        } else {
            [cell.filmImageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"movie_placeholder"]];
        }
        cell.filmImageView.layer.borderColor = CMConstants.imageBorderColor.CGColor;
        cell.filmImageView.layer.borderWidth = 1;
        NSString *score = [searchObject objectForKey:@"score"];
        if(![StringUtility stringIsEmpty:score] && ![score isEqualToString:@"0"]){
            cell.scoreLabel.text = [NSString stringWithFormat:@"评分：%@", score];
        } else {
            cell.scoreLabel.text = @"评分：暂无";
        }
        NSString *name = [searchObject objectForKey:@"prod_name"];
        if([StringUtility stringIsEmpty:name]){
            cell.filmTitleLabel.text = @"...";
        } else {
            cell.filmTitleLabel.text = name;
        }
        
        NSString *actor = [searchObject objectForKey:@"star"];
        if([StringUtility stringIsEmpty:actor]){
            cell.filmThirdTitleLabel.text = @"主演：...";
        } else {
            cell.filmThirdTitleLabel.text = [NSString stringWithFormat:@"主演：%@", actor];
        }
        
        NSString *content = [searchObject objectForKey:@"prod_sumary"];
        if([StringUtility stringIsEmpty:content]){
            content = @"介绍暂无";
        }
        content = [NSString stringWithFormat:@"%@%@", @"    ", content];
        CGSize constraint = CGSizeMake(182, 70);
        CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeTailTruncation];
        cell.filmSubitleLabel.frame = CGRectMake(cell.filmSubitleLabel.frame.origin.x, cell.filmSubitleLabel.frame.origin.y, size.width, size.height);
        cell.filmSubitleLabel.text = content;        
        return cell;
    } else {
        SearchVideoCell *cell = (SearchVideoCell*) [tableView dequeueReusableCellWithIdentifier:@"searchVideoCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
            cell = (SearchVideoCell *)[nib objectAtIndex:1];
            UIView *backgroundView;
            if(indexPath.row % 2 == 0){
                backgroundView = [[CustomCellBlackBackground alloc]init];
            } else {
                backgroundView = [[CustomCellBackground alloc]init];
            }
            [cell setBackgroundView:backgroundView];
        }
        NSString *url = [searchObject objectForKey:@"prod_pic_url"];
        if([StringUtility stringIsEmpty:url]){
            cell.videoImageView.image = [UIImage imageNamed:@"movie_placeholder"];
        } else {
            [cell.videoImageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"movie_placeholder"]];
        }
        cell.videoImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.videoImageView.layer.borderWidth = 1;
        NSString *name = [searchObject objectForKey:@"prod_name"];
        if([StringUtility stringIsEmpty:name]){
            cell.videoTitleLabel.text = @"...";
        } else {
            cell.videoTitleLabel.text = name;
        }
        NSString *score = [searchObject objectForKey:@"score"];
        if(![StringUtility stringIsEmpty:score] && ![score isEqualToString:@"0"]){
            cell.scoreLabel.text = [NSString stringWithFormat:@"评分：%@", score];
        } else {
            cell.scoreLabel.text = @"评分：暂无";
        }
        NSString *actor = [searchObject objectForKey:@"star"];
        if([StringUtility stringIsEmpty:actor]){
            cell.videoSubtitleLabel.text = @"主演：...";
        } else {
            cell.videoSubtitleLabel.text = [NSString stringWithFormat:@"主演：%@", actor];
        }
        return cell;
    }
}


//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10,0,self.view.bounds.size.width,24)];
//    customView.backgroundColor = [UIColor blackColor];
//    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bgwithline"]];
//    imageView.frame = customView.frame;
//    [customView addSubview:imageView];
//
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    headerLabel.backgroundColor = [UIColor clearColor];
//    headerLabel.font = [UIFont boldSystemFontOfSize:12];
//    NSMutableDictionary *item = [itemsArray objectAtIndex:section];
//    NSEnumerator *keys = item.keyEnumerator;
//    NSString *key = [keys nextObject];
//    headerLabel.text =  [NSString stringWithFormat:NSLocalizedString(key, nil), self.keyword, nil];
//    headerLabel.textColor = [UIColor lightGrayColor];
//    [headerLabel sizeToFit];
//    headerLabel.center = CGPointMake(headerLabel.frame.size.width/2 + 10, customView.frame.size.height/2);
//    [customView addSubview:headerLabel];
//    return customView;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *searchObject = [itemsArray objectAtIndex:indexPath.row];
    NSString *type = [searchObject objectForKey:@"prod_type"];
    if([type isEqualToString:@"1"] || [type isEqualToString:@"2"]){
        return 140;
    } else {
        return 110;
    }
    
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.sBar resignFirstResponder];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *searchObject = [itemsArray objectAtIndex:indexPath.row];
    NSString *type = [searchObject objectForKey:@"prod_type"];
    PlayDetailViewController *viewController;
    if([type isEqualToString:@"1"]){
        viewController = [[PlayDetailViewController alloc]initWithStretchImage];
    } else if([type isEqualToString:@"2"]){
        viewController = [[DramaPlayDetailViewController alloc]initWithStretchImage];
    } else if([type isEqualToString:@"3"]){
        viewController = [[ShowPlayDetailViewController alloc]initWithStretchImage];
    } else if([type isEqualToString:@"4"]){
        viewController = [[VideoPlayDetailViewController alloc]initWithStretchImage];
    }
    viewController.programId = [searchObject valueForKey:@"prod_id"];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self addKeyToLocalHistory:self.sBar.text];
    [searchBar resignFirstResponder];
    self.keyword = self.sBar.text;
    [itemsArray removeAllObjects];
    [self showProgressBar];
    [self getResult];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

- (void)addKeyToLocalHistory:(NSString *)key
{
    NSArray *array = (NSArray *)[[ContainerUtility sharedInstance] attributeForKey:@"search_history"];
    NSMutableArray *historyArray = [[NSMutableArray alloc]initWithCapacity:LOCAL_KEYS_NUMBER];
    for(NSDictionary *item in array){
        NSMutableDictionary *temp = [[NSMutableDictionary alloc]init];
        [temp setValue:[item objectForKey:@"content"] forKey:@"content"];
        [temp setValue:[item objectForKey:@"last_search_date"] forKey:@"last_search_date"];
        [historyArray addObject:temp];
    }
    NSMutableDictionary *newItem;
    for(NSMutableDictionary *item in historyArray){
        NSString *content = [item objectForKey:@"content"];
        if([content isEqualToString:key]){
            newItem = item;
            break;
        }
    }
    NSString *currentDateString = [DateUtility formatDateWithString:[NSDate date] formatString: @"yyyy-MM-dd HH:mm:ss"];
    if(newItem != nil){
        [newItem setValue:currentDateString forKey:@"last_search_date"];
    } else {
        newItem = [[NSMutableDictionary alloc]initWithCapacity:2];
        [newItem setValue:key forKey:@"content"];
        [newItem setValue:currentDateString forKey:@"last_search_date"];
        if(historyArray.count >= LOCAL_KEYS_NUMBER){
            NSDate *minDate = [NSDate date];
            NSMutableDictionary *minItem;
            for(NSMutableDictionary *item in historyArray){
                NSString *dateString = [item objectForKey:@"last_search_date"];
                NSDate *date = [DateUtility dateFromFormatString:dateString formatString: @"yyyy-MM-dd HH:mm:ss"];
                if([date isEarlierThanDate:minDate]){
                    minDate = date;
                    minItem = item;
                }
            }
            [historyArray removeObject:minItem];
        }
        [historyArray addObject:newItem];
    }
    [[ContainerUtility sharedInstance]setAttribute:historyArray forKey:@"search_history"];
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
    //    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
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
    //    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    [pullToRefreshManager_ tableViewReleased];
}

/**
 * Tells client that can reload table.
 * After reloading is completed must call [pullToRefreshMediator_ tableViewReloadFinished]
 */
- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    reloads_++;
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:self.keyword, @"keyword", [NSNumber numberWithInt:reloads_+1], @"page_num", @"10", @"page_size", nil];
    [[AFServiceAPIClient sharedClient] getPath:kPathSearch parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
        NSString *responseCode = [result objectForKey:@"res_code"];
        if(responseCode == nil){
            NSArray *searchResult = [result objectForKey:@"results"];
            if(searchResult != nil && searchResult.count > 0){
                [itemsArray addObjectsFromArray:searchResult];
            }
            searchResult = nil;
            [self performSelector:@selector(loadTable) withObject:nil afterDelay:2.0f];
        } else {
            
        }
    } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
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
    //	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
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
