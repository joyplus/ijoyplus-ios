//
//  RecordListCell.m
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "RecordListCell.h"

@implementation RecordListCell
@synthesize titleLab = titleLab_;
@synthesize infoLab = infoLab_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 296, 60);
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 14, 200, 15)];
        [self addSubview:self.titleLab];
        
        self.infoLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 33, 200, 15)];
        [self addSubview:self.infoLab];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
