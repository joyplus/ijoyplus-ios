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
    UILabel *actors_;
    UILabel *date_;
    UIButton *play_;
    UIButton *deleteBtn_;
}
@property (nonatomic, strong)UILabel *titleLab;
@property (nonatomic, strong)UILabel *actors;
@property (nonatomic, strong)UILabel *date;
@property (nonatomic, strong)UIButton *play;
@property (nonatomic, strong)UIButton *deleteBtn;
-(void)addCustomGestureRecognizer;
@end
