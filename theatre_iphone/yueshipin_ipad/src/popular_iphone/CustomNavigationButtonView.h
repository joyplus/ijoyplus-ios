//
//  CustomNavigationButton.h
//  yueshipin
//
//  Created by 08 on 13-2-1.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"
@interface CustomNavigationButtonView : UIView {
	UILabel* buttonLabel_;
	UIButton* button_;
    UIImageView *messageImage_;
    UILabel *numLabel_;
    NSInteger warningNumber_;
}
@property (nonatomic,retain) UILabel* buttonLabel;
@property (nonatomic,retain) UIButton* button;
@property (nonatomic,assign) NSInteger warningNumber;
@property (nonatomic,strong) JSBadgeView* badgeView;
- (void)initUI:(UINavigationController*)navigationController withText:(NSString*)text;
@end

