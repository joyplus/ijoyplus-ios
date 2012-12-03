#import "DeviceListViewController.h"

@protocol DeviceListViewDelegate;
@interface DeviceListView : UIView
{
    UILabel *_title;
    DeviceListViewController *tableViewController;
    UIImageView *_footerImage;
}

@property (nonatomic, assign) id<DeviceListViewDelegate> delegate;

// The options is a NSArray, contain some NSDictionaries, the NSDictionary contain 2 keys, one is "img", another is "text".
- (id)initWithTitle:(NSString *)aTitle;
// If animated is YES, PopListView will be appeared with FadeIn effect.
- (void)showInView:(UIView *)aView animated:(BOOL)animated;
@end

@protocol DeviceListViewDelegate <NSObject>
- (void)leveyPopListViewDidCancel;
@end