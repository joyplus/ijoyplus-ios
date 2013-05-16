//
//  ListDetailViewCell.h
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListDetailViewCell : UITableViewCell{

    UIImageView *imageview_;
    UILabel *label_;
    UILabel *actors_;
    UILabel *area_;
    UIButton *support_;
    UIButton *addFav_;
    UILabel *score_;
}

@property (strong, nonatomic)UIImageView *imageview;
@property (strong, nonatomic)UILabel *label;
@property (strong, nonatomic)UILabel *actors;
@property (strong, nonatomic)UILabel *area;
@property (strong, nonatomic)UIButton *support;
@property (strong, nonatomic)UIButton *addFav;
@property (strong, nonatomic)UILabel *score;
@end
