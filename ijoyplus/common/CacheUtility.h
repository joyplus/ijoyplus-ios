#import "WBEngine.h"

@interface CacheUtility : NSObject

+ (id)sharedCache;

- (void)clear;
- (void)setSinaFriends:(NSArray *)friends;
- (NSArray *)sinaFriends;
- (void)setSinaWeiboEngineer:(WBEngine *)engineer;
- (WBEngine *)getSinaWeiboEngineer;
@end
