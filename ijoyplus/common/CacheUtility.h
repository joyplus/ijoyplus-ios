

@interface CacheUtility : NSObject

+ (id)sharedCache;

- (void)clear;
- (void)setSinaFriends:(NSArray *)friends;
- (NSArray *)sinaFriends;
- (NSString *)sinaUID;
- (void)setSinaUID:(NSString *)uid;
- (id)loadFromCache:(NSString *)cacheKey;
- (void)putInCache:(NSString *)cacheKey result:(id)result;
@end
