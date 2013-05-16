//
//  FeedBackView.h
//  yueshipin
//
//  Created by 08 on 13-4-1.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedBackViewDelegate;

@interface FeedBackView : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSArray         *_arrFeedBackOption;
    UITextField     *_textViewOther;
    UITableView     *_tableView;
    NSMutableArray *selectArr_;
}

@property (nonatomic, weak) id <FeedBackViewDelegate> delegate;
@property (nonatomic, strong)  NSMutableArray *selectArr;

@end
@protocol FeedBackViewDelegate <NSObject>

- (void)feedBackType:(NSString *)types detailReason:(NSString *)reason;

@end