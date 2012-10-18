#import <Foundation/Foundation.h>
#import "MyProfileCell.h"
#import "MNMBottomPullToRefreshManager.h"
#import "EGORefreshTableHeaderView.h"
#import "UIGenericViewController.h"

/**
 * View controller with the demo table
 */
@interface MyselfViewController : UIGenericViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, EGORefreshTableHeaderDelegate, MNMBottomPullToRefreshManagerClient, UIGestureRecognizerDelegate> {
}
@property (nonatomic, readwrite, retain) IBOutlet UITableView *table;

@end