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
}

@property (strong, nonatomic)UIImageView *imageview;
@property (strong, nonatomic)UILabel *label;
@end
