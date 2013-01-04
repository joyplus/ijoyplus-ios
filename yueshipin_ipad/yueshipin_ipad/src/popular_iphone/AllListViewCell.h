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
    UILabel *label1_;
    UILabel *label2_;
    UILabel *label3_;
    UILabel *label4_;
    UILabel *label5_;
    UIImageView *typeImageView_;

}
@property (strong, nonatomic)UIImageView *imageView;
@property (strong, nonatomic)UILabel *label;
@property (strong, nonatomic)NSArray *listArr;
@property (strong, nonatomic)UILabel *label1;
@property (strong, nonatomic)UILabel *label2;
@property (strong, nonatomic)UILabel *label3;
@property (strong, nonatomic)UILabel *label4;
@property (strong, nonatomic)UILabel *label5;
@property (strong, nonatomic)UIImageView *typeImageView;
@end
