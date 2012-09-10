#import <Foundation/Foundation.h>
#import "MNMBottomPullToRefreshManager.h"
#import "MyProfileWithImageCell.h"

/**
 * View controller with the demo table
 */
@interface MyselfViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, MNMBottomPullToRefreshManagerClient> {
@private
    /**
     * Pull to refresh manager
     */
    MNMBottomPullToRefreshManager *pullToRefreshManager_;
    
    /**
     * Reloads (for testing purposes)
     */
    NSUInteger reloads_;
}

/**
 * Provides readwrite access to the table_. Exported to IB
 */
@property (nonatomic, readwrite, retain) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet MyProfileWithImageCell *myProfileCell;

@end