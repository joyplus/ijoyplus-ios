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
    UILabel *support_;
    UILabel *addFav_;
}

@property (strong, nonatomic)UIImageView *imageview;
@property (strong, nonatomic)UILabel *label;
@property (strong, nonatomic)UILabel *actors;
@property (strong, nonatomic)UILabel *area;
@property (strong, nonatomic)UILabel *support;
@property (strong, nonatomic)UILabel *addFav;
@end
