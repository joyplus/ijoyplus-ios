#import <Foundation/Foundation.h>
#import "MNMBottomPullToRefreshManager.h"
#import "MyProfileCell.h"
#import "EGORefreshTableHeaderView.h"

/**
 * View controller with the demo table
 */
@interface MyselfViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, EGORefreshTableHeaderDelegate, MNMBottomPullToRefreshManagerClient> {
}

/**
 * Provides readwrite access to the table_. Exported to IB
 */
@property (nonatomic, readwrite, retain) IBOutlet UITableView *table;

@end