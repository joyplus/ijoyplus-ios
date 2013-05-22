//
//  SortedViewCell.h
//  yueshipin
//
//  Created by 08 on 12-12-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SortedViewCell : UITableViewCell{

    UIImageView *imageview_;
    UILabel *title_;
    UILabel *labelOne_;
    UILabel *labelTwo_;
    UILabel *labelThree_;

}

@property (strong, nonatomic)UIImageView *imageview;
@property (strong, nonatomic)UILabel *title;
@property (strong, nonatomic)UILabel *labelOne;
@property (strong, nonatomic)UILabel *labelTwo;
@property (strong, nonatomic)UILabel *labelThree;
@end
