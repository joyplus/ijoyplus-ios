//
//  FeedbackTableViewCell.h
//  UMeng Analysis
//
//  Created by liuyu on 9/18/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface L_FeedbackTableViewCell : UITableViewCell {
    
    UIImageView *messageBackgroundView;
    UIImageView *avatarImageView_;
    UILabel *dateLabel_;
}
@property (nonatomic, strong)UIImageView *avatarImageView;
@property (nonatomic, strong)UILabel *dateLabel;
@end
