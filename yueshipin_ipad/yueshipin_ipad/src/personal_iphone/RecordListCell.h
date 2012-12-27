//
//  RecordListCell.h
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordListCell : UITableViewCell{
    UILabel *titleLab_;
    UILabel *infoLab_;
}
@property (nonatomic, strong)UILabel *titleLab;
@property (nonatomic, strong)UILabel *infoLab;
@end
