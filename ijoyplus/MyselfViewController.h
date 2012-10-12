#import <Foundation/Foundation.h>
#import "MyProfileCell.h"
#import "MNMBottomPullToRefreshManager.h"
#import "EGORefreshTableHeaderView.h"

/**
 * View controller with the demo table
 */
@interface MyselfViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, EGORefreshTableHeaderDelegate, MNMBottomPullToRefreshManagerClient, UIGestureRecognizerDelegate> {
}
@property (nonatomic, readwrite, retain) IBOutlet UITableView *table;

@end