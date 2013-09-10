//
//  YueSouViewCell.h
//  yueshipin
//
//  Created by huokun on 13-9-9.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KEY_FIRST_NUMBER        (@"key_fNum")
#define KEY_FIRST_NAME          (@"key_fName")
#define KEY_SECOND_NUMBER       (@"key_sNum")
#define KEY_SECOND_NAME         (@"key_sName")

@protocol YueSouViewCellDelegate <NSObject>

- (void)searchWithKeyWord:(NSString *)key;

@end

@interface YueSouViewCell : UITableViewCell
@property (nonatomic, weak) id <YueSouViewCellDelegate>delegate;
- (void)setViewInfo:(NSDictionary *)info;
@end
