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
@synthesize listArr = listArr_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 320, 130);
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, 15, 68, 100)];
        [self addSubview:self.imageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(105, 24, 169, 15)];
        [self addSubview:self.label];
        
        UILabel *listLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(105, 50, 90, 12)];
        //listLabel1.text = [self.listArr objectAtIndex:0];
        UILabel *listLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(205, 50, 90, 12)];
        //listLabel2.text = [self.listArr objectAtIndex:1];
        UILabel *listLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(105, 58, 90, 12)];
        //listLabel3.text = [self.listArr objectAtIndex:2];
        UILabel *listLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(205, 50, 90, 12)];
        //listLabel4.text = [self.listArr objectAtIndex:3];
        UILabel *listLabel5 = [[UILabel alloc] initWithFrame:CGRectMake(105, 66, 90, 12)];
       // listLabel5.text = [self.listArr objectAtIndex:4];
        UILabel *listLabel6 = [[UILabel alloc] initWithFrame:CGRectMake(205, 50, 90, 12)];
       // listLabel6.text = [self.listArr objectAtIndex:5];
        
        [self addSubview:listLabel1];
        [self addSubview:listLabel2];
        [self addSubview:listLabel3];
        [self addSubview:listLabel4];
        [self addSubview:listLabel5];
        [self addSubview:listLabel6];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
