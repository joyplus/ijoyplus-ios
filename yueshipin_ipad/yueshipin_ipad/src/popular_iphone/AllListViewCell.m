//
//  AllListViewCell.m
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "AllListViewCell.h"

@implementation AllListViewCell
@synthesize imageView = imageView_;
@synthesize label = label_;
@synthesize label1 = label1_;
@synthesize label2 = label2_;
@synthesize label3 = label3_;
@synthesize label4 = label4_;
@synthesize label5 = label5_;
@synthesize listArr = listArr_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.frame = CGRectMake(0, 0, 320, 130);
        
//        UIImageView *iconBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_list_moviecard.png"]];
//        iconBgView.frame = CGRectMake(7, 13, 82, 111);
//        [self addSubview:iconBgView];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, 15, 68, 100)];
        [self addSubview:self.imageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(105, 24, 169, 15)];
        [self addSubview:self.label];
        
        label1_ = [[UILabel alloc] initWithFrame:CGRectMake(105, 50, 90, 12)];
        label1_.font = [UIFont systemFontOfSize:12];
        label1_.textColor = [UIColor grayColor];
        label2_= [[UILabel alloc] initWithFrame:CGRectMake(205, 50, 90, 12)];
        label2_.font = [UIFont systemFontOfSize:12];
        label2_.textColor = [UIColor grayColor];
        label3_ = [[UILabel alloc] initWithFrame:CGRectMake(105, 70, 90, 12)];
        label3_.font = [UIFont systemFontOfSize:12];
        label3_.textColor = [UIColor grayColor];
        label4_ = [[UILabel alloc] initWithFrame:CGRectMake(205, 70, 90, 12)];
        label4_.font = [UIFont systemFontOfSize:12];
        label4_.textColor = [UIColor grayColor];
        label5_ = [[UILabel alloc] initWithFrame:CGRectMake(105, 90, 90, 12)];
        label5_.font = [UIFont systemFontOfSize:12];
        label5_.textColor = [UIColor grayColor];
        UILabel *listLabel6 = [[UILabel alloc] initWithFrame:CGRectMake(205, 90, 90, 12)];
        listLabel6.text = @"...";
        listLabel6.textColor = [UIColor grayColor];
        [self addSubview:label1_];
        [self addSubview:label2_];
        [self addSubview:label3_];
        [self addSubview:label4_];
        [self addSubview:label5_];
        [self addSubview:listLabel6];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_fen_ge_xian.png"]];
        line.frame = CGRectMake(0, 129, 320, 1);
        [self addSubview:line];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
