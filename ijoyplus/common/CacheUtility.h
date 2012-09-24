@interface CacheUtility : NSObject

+ (id)sharedCache;

- (void)clear;
- (void)setSinaFriends:(NSArray *)friends;
- (NSArray *)sinaFriends;
@end
