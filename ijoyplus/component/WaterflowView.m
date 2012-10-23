//
//  WaterflowView.m
//  WaterFlowDisplay
//
//  Created by B.H. Liu on 12-3-29.
//  Copyright (c) 2012年 Appublisher. All rights reserved.
//

#import "WaterflowView.h"
#import "EGORefreshTableHeaderView.h"
#import "AppDelegate.h"
#import "CMConstants.h"
#import "ContainerUtility.h"
#import "MNMBottomPullToRefreshManager.h"

#define REFRESHINGVIEW_HEIGHT 480

@interface WaterflowView() <EGORefreshTableHeaderDelegate, MNMBottomPullToRefreshManagerClient>{
    CGPoint previousOffSet;
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    NSUInteger reloads_;
}
- (void)initialize;
- (void)recycleCellIntoReusableQueue:(WaterFlowCell*)cell;
- (void)pageScroll;
- (void)cellSelected:(NSNotification*)notification;

@property(nonatomic, readwrite) BOOL isRefreshing;
@end

@implementation WaterflowView
@synthesize cellHeight=_cellHeight,visibleCells=_visibleCells,reusableCells=_reusedCells;
@synthesize flowdelegate;
@synthesize flowdatasource;
@synthesize refreshHeaderView=_refreshHeaderView,isRefreshing=_isRefreshing;
@synthesize cellSelectedNotificationName;
@synthesize mergeRow;
@synthesize mergeCell;
@synthesize parentControllerName;
@synthesize currentPage;
@synthesize defaultScrollViewHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
        self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f,  -REFRESHINGVIEW_HEIGHT, self.frame.size.width,REFRESHINGVIEW_HEIGHT)];
        [self addSubview:self.refreshHeaderView];
        self.refreshHeaderView.delegate = self;
        self.refreshHeaderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_up2"]];
        self.isRefreshing = NO;
        [self.refreshHeaderView refreshLastUpdatedDate];
        
        currentPage = 1;
        [self initialize];
        pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:self withClient:self];
        [pullToRefreshManager_ tableViewReloadFinished];
    }
    return self;
}

- (id)initWithFrameWithoutHeader:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
//        self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f,  -REFRESHINGVIEW_HEIGHT, self.frame.size.width,REFRESHINGVIEW_HEIGHT)];
//        [self addSubview:self.refreshHeaderView];
//        self.refreshHeaderView.delegate = self;
//        self.refreshHeaderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back_up"]];
//        self.isRefreshing = NO;
//        [self.refreshHeaderView refreshLastUpdatedDate];
        
        currentPage = 1;
        [self initialize];
        pullToRefreshManager_ = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:480.0f tableView:self withClient:self];
        [pullToRefreshManager_ tableViewReloadFinished];
    }
    return self;
}

- (void)setCellSelectedNotificationName:(NSString *)notificationName
{
    cellSelectedNotificationName = notificationName;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cellSelected:)
                                                 name:self.cellSelectedNotificationName
                                               object:nil];
}

- (void)removeCellObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:self.cellSelectedNotificationName
                                                  object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:self.cellSelectedNotificationName
                                                  object:nil];
    
    self.cellHeight = nil;
    self.visibleCells = nil;
    self.reusableCells = nil;
    self.flowdatasource = nil;
    self.flowdelegate = nil;
    self.cellSelectedNotificationName = nil;
    self.parentControllerName = nil;
    self.refreshHeaderView = nil;
    pullToRefreshManager_ =nil;
}

#pragma mark-
#pragma mark- process notification
- (void)cellSelected:(NSNotification *)notification
{
    if ([self.flowdelegate respondsToSelector:@selector(flowView:didSelectRowAtIndexPath:)])
    {
        [self.flowdelegate flowView:self didSelectRowAtIndexPath:((WaterFlowCell*)notification.object).indexPath];
    }
}

#pragma mark-
#pragma mark - manage and reuse cells
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    if (!identifier || identifier == 0 ) return nil;
    
    NSArray *cellsWithIndentifier = [NSArray arrayWithArray:[self.reusableCells objectForKey:identifier]];
    if (cellsWithIndentifier &&  cellsWithIndentifier.count > 0)
    {
        WaterFlowCell *cell = [cellsWithIndentifier lastObject];
        cell.cellSelectedNotificationName = self.cellSelectedNotificationName;
        [[self.reusableCells objectForKey:identifier] removeLastObject];
        return cell;
    }
    return nil;
}

- (void)recycleCellIntoReusableQueue:(WaterFlowCell *)cell
{
    if(!self.reusableCells)
    {
        self.reusableCells = [NSMutableDictionary dictionary];
        
        NSMutableArray *array = [NSMutableArray arrayWithObject:cell];
        [self.reusableCells setObject:array forKey:cell.reuseIdentifier];
    }
    
    else 
    {
        if (![self.reusableCells objectForKey:cell.reuseIdentifier])
        {
            NSMutableArray *array = [NSMutableArray arrayWithObject:cell];
            [self.reusableCells setObject:array forKey:cell.reuseIdentifier];
        }
        else 
        {
            [[self.reusableCells objectForKey:cell.reuseIdentifier] addObject:cell];
        }
    }

}

#pragma mark-
#pragma mark- methods
- (void)initialize
{    
    numberOfColumns = [self.flowdatasource numberOfColumnsInFlowView:self];
    
    self.reusableCells = [NSMutableDictionary dictionary];
    self.cellHeight = [NSMutableArray arrayWithCapacity:numberOfColumns];
    self.visibleCells = [NSMutableArray arrayWithCapacity:numberOfColumns];
    
    CGFloat scrollHeight = 0.f;
    
    ////put height of cells per column into an array, then add this array into self.cellHeight
    for (int i = 0; i< numberOfColumns; i++)
    {
        [self.visibleCells addObject:[NSMutableArray array]]; 
        
        NSMutableArray *cellHeightInOneColume = [NSMutableArray array];
        NSInteger rows = [self.flowdatasource flowView:self numberOfRowsInColumn:i] * currentPage;
        
        CGFloat columHeight = 0.f;
        for (int j =0; j < rows; j++)
        {
            CGFloat height = [self.flowdelegate flowView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            columHeight += height;
            [cellHeightInOneColume addObject:[NSNumber numberWithFloat:columHeight]];
        }
        
        [self.cellHeight addObject:cellHeightInOneColume];
        scrollHeight = (columHeight >= scrollHeight)?columHeight:scrollHeight;
    }
    if(self.defaultScrollViewHeight != 0){
        scrollHeight = self.defaultScrollViewHeight;
        self.defaultScrollViewHeight = 0;
    }
    if(scrollHeight < 480){
        scrollHeight = 480;
    }
    
    self.contentSize = CGSizeMake(self.frame.size.width, scrollHeight);
       
    [self pageScroll];
    [self showNavigationBarAnimation];
    
}

- (void)reloadData
{
    //remove and recycle all visible cells
    for (int i = 0; i < numberOfColumns; i++)
    {
        NSMutableArray *array = [self.visibleCells objectAtIndex:i];
        for (id cell in array)
        {
            [self recycleCellIntoReusableQueue:(WaterFlowCell*)cell];
            [cell removeFromSuperview];
        }
    }
    
    if (self.isRefreshing)
    {
        self.isRefreshing = NO;
        [self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
    }

    [self initialize];
    [pullToRefreshManager_ tableViewReloadFinished];
}

- (void)MNMBottomPullToRefreshManagerClientReloadTable {
    reloads_++;
    currentPage ++;
    [self.flowdelegate flowView:self willLoadData:currentPage];
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:2.0f];
}

- (void)pageScroll
{
    //CGPoint offset = self.contentOffset;
    
    
    for (int i = 0 ; i< numberOfColumns; i++)
    {
        float origin_x = i * (self.frame.size.width / numberOfColumns);
		float width = self.frame.size.width / numberOfColumns;
                
        WaterFlowCell *cell = nil;
        
        if ([self.visibleCells objectAtIndex:i] == nil || ((NSArray*)[self.visibleCells objectAtIndex:i]).count == 0) //everytime reloadData is called and no cells in visibleCellArray
        {
            int rowToDisplay = 0;
			for( int j = 0; j < [[self.cellHeight objectAtIndex:i] count] - 1; j++)  //calculate which row to display in this column
			{
				float everyCellHeight = [[[self.cellHeight objectAtIndex:i] objectAtIndex:j] floatValue];
				if(everyCellHeight < self.contentOffset.y)
				{
					rowToDisplay ++;
				}
			}
			            
			float origin_y = 0;
			float height = 0;
			if(rowToDisplay == 0)  
			{
				origin_y = 0;
				height = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay] floatValue];
			}
			else if(rowToDisplay < [[self.cellHeight objectAtIndex:i] count]) 
            {
				origin_y = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay - 1] floatValue];
				height  = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay ] floatValue] - origin_y;
			}
			
			cell = [self.flowdatasource flowView:self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowToDisplay inSection:i]];
			cell.indexPath = [NSIndexPath indexPathForRow: rowToDisplay inSection:i];
			cell.frame = CGRectMake(origin_x, origin_y, width, height);
			[[self.visibleCells objectAtIndex:i] insertObject:cell atIndex:0];
            if(self.mergeCell && cell.indexPath.row == self.mergeRow){
            if(i == 0){
                    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 320, cell.frame.size.height);
                } else{
                    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 0, cell.frame.size.height);
                }
            }
			[self addSubview:cell];
       }
        else   //there are cells in visibelCellArray
        {
            cell = [[self.visibleCells objectAtIndex:i] objectAtIndex:0];
        }
        
        //base on this cell at rowToDisplay and process the other cells
        //1. add cell above this basic cell if there's margin between basic cell and top
        while ( cell && ((cell.frame.origin.y - self.contentOffset.y) > 0.0001)) 
        {
            float origin_y = 0;
			float height = 0;
            int rowToDisplay = cell.indexPath.row;
            
            if(rowToDisplay == 0) 
            {
                cell = nil;
                break;
            }
            else if (rowToDisplay == 1)
            {
                origin_y = 0;
                height = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay  -1] floatValue];
            }
            else if (cell.indexPath.row < [[self.cellHeight objectAtIndex:i] count])
            {
                origin_y = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay -2] floatValue];
                height = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay - 1] floatValue] - origin_y;
            }
            
            cell = [self.flowdatasource flowView:self cellForRowAtIndexPath:[NSIndexPath indexPathForRow: rowToDisplay > 0 ? (rowToDisplay  - 1) : 0 inSection:i]];
            cell.indexPath = [NSIndexPath indexPathForRow: rowToDisplay > 0 ? (rowToDisplay - 1) : 0 inSection:i];
            cell.frame = CGRectMake(origin_x,origin_y , width, height);
            [[self.visibleCells objectAtIndex:i] insertObject:cell atIndex:0];
            if(self.mergeCell && cell.indexPath.row == self.mergeRow){
                if(i == 0){
                    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 320, cell.frame.size.height);
                } else{
                    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 0, cell.frame.size.height);
                }
            }
            [self addSubview:cell];
        }
        //2. remove cell above this basic cell if there's no margin between basic cell and top
        while (cell &&  ((cell.frame.origin.y + cell.frame.size.height  - self.contentOffset.y) <  0.0001)) 
		{
			[cell removeFromSuperview];
			[self recycleCellIntoReusableQueue:cell];
			[[self.visibleCells objectAtIndex:i] removeObject:cell];
			
			if(((NSMutableArray*)[self.visibleCells objectAtIndex:i]).count > 0)
			{
				cell = [[self.visibleCells objectAtIndex:i] objectAtIndex:0];
			}
			else 
            {
				cell = nil;
			}
		}
        //3. add cells below this basic cell if there's margin between basic cell and bottom
        cell = [[self.visibleCells objectAtIndex:i] lastObject];
        while (cell &&  ((cell.frame.origin.y + cell.frame.size.height - self.frame.size.height - self.contentOffset.y) <  0.0001)) 
		{
            //NSLog(@"self.offset %@, self.frame %@, cell.frame %@, cell.indexpath %@",NSStringFromCGPoint(self.contentOffset),NSStringFromCGRect(self.frame),NSStringFromCGRect(cell.frame),cell.indexPath);
            float origin_y = 0;
			float height = 0;
            int rowToDisplay = cell.indexPath.row;
            
            if(rowToDisplay == [[self.cellHeight objectAtIndex:i] count] - 1)
			{
//				origin_y = 0;
				cell = nil;
				break;;
			}
            else 
            {
                origin_y = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay] floatValue];
                height = [[[self.cellHeight objectAtIndex:i] objectAtIndex:rowToDisplay + 1] floatValue] -  origin_y;
            }
            
            cell = [self.flowdatasource flowView:self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowToDisplay + 1 inSection:i]];
            cell.indexPath = [NSIndexPath indexPathForRow:rowToDisplay + 1 inSection:i];
            cell.frame = CGRectMake(origin_x, origin_y, width, height);
            [[self.visibleCells objectAtIndex:i] addObject:cell];
            if(self.mergeCell && cell.indexPath.row == self.mergeRow){
                if(i == 0){
                    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 320, cell.frame.size.height);
                } else{
                    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 0, cell.frame.size.height);
                }
            }
            [self addSubview:cell];
        }
        //4. remove cells below this basic cell if there's no margin between basic cell and bottom
        while (cell &&  ((cell.frame.origin.y - self.frame.size.height - self.contentOffset.y) > 0.0001)) 
		{
			[cell removeFromSuperview];
			[self recycleCellIntoReusableQueue:cell];
			[[self.visibleCells objectAtIndex:i] removeObject:cell];
			
			if(((NSMutableArray*)[self.visibleCells objectAtIndex:i]).count > 0)
			{
				cell = [[self.visibleCells objectAtIndex:i] lastObject];
			}
			else 
            {
				cell = nil;
			}
		}
    }
}

#pragma mark-
#pragma mark- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self pageScroll];
    
    [self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    static float newx = 0;
    static float oldIx = 0;
    newx= scrollView.contentOffset.y ;
    if (newx != oldIx ) {
        if (newx > oldIx && newx > 0) {
            [self hideNavigationBarAnimation];
        }else if(newx < oldIx){
            [self showNavigationBarAnimation];
        }
        oldIx = newx;
    }
    
    [pullToRefreshManager_ tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    [pullToRefreshManager_ tableViewReleased];
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
// 
//    if (bottomEdge >= scrollView.contentSize.height ) 
//    {
//        if (self.loadingmore) return;
//        
//        NSLog(@"load more");
//        self.loadingmore = YES;
//        self.loadFooterView.showActivityIndicator = YES;
//        
//        currentPage ++;
//        if ([self.flowdelegate respondsToSelector:@selector(flowView:willLoadData:)])
//        {
//            [self.flowdelegate flowView:self willLoadData:currentPage];  //在delegate中对flowview进行reloadData
//        }
//        [self performSelector:@selector(reloadData) withObject:self afterDelay:1.0f]; //make a delay to show loading process for a while
//    }
}

- (void)hideNavigationBarAnimation
{
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [UIView beginAnimations:@"FadeOutNav" context:NULL];
//    [UIView setAnimationDuration:2.0];
//    [(UINavigationController *)appDelegate.window.rootViewController setNavigationBarHidden:YES animated:YES];
//    [UIView commitAnimations];
}

- (void)showNavigationBarAnimation
{
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [UIView beginAnimations:@"FadeOutNav" context:NULL];
//    [UIView setAnimationDuration:2.0];
//    [(UINavigationController *)appDelegate.window.rootViewController setNavigationBarHidden:NO animated:YES];
//    [UIView commitAnimations];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    self.isRefreshing = YES;
    
    currentPage = 1;
    [self.flowdelegate flowView:self refreshData:currentPage];
    [self performSelector:@selector(reloadData) withObject:self afterDelay:1.0f];  //make a delay to show loading process for a while
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return self.isRefreshing; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
    NSDate *lastUpdateDate = (NSDate *)[[ContainerUtility sharedInstance]attributeForKey: [NSString stringWithFormat:@"%@%@", self.parentControllerName, @"lastUpdateDate"]];
    if(lastUpdateDate == nil){
        [[ContainerUtility sharedInstance]setAttribute:[NSDate date] forKey:[NSString stringWithFormat:@"%@%@", self.parentControllerName, @"lastUpdateDate"]];
        return [NSDate date]; // should return date data source was last changed
    } else {
        return [NSDate date];
    }
	
}

@end

//===================================================================
//
//*************************WaterflowCell*****************************
//
//===================================================================
@implementation WaterFlowCell
@synthesize indexPath = _indexPath;
@synthesize reuseIdentifier = _reuseIdentifier;
@synthesize cellSelectedNotificationName = _cellSelectedNotificationName;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super init])
	{
		self.reuseIdentifier = reuseIdentifier;
	}
	
	return self;
}

- (void)dealloc
{
    self.indexPath = nil;
    self.reuseIdentifier = nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:self.cellSelectedNotificationName
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:self.indexPath forKey:@"IndexPath"]];
    
}

@end