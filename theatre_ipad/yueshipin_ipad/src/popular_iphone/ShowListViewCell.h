//
//  ShowListViewCell.h
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowListViewCell : UITableViewCell{
    UIImageView *imageView_;
    UILabel *nameLabel_;
    UILabel *latest_;
}
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UILabel *latest;

@end
