//
//  AllListViewCell.h
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllListViewCell : UITableViewCell{
    UIImageView *imageView_;
    UILabel *label_;
    NSArray *listArr_;

}
@property (strong, nonatomic)UIImageView *imageView;
@property (strong, nonatomic)UILabel *label;
@property (strong, nonatomic)NSArray *listArr;
@end
