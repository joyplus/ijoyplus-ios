#import <Foundation/Foundation.h>
#import "MyProfileCell.h"
#import "MNMBottomPullToRefreshManager.h"
#import "UIGenericViewController.h"

/**
 * View controller with the demo table
 */
@interface ShowTableViewController : UIGenericViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *table;

@end