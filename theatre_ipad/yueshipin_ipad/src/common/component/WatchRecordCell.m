//
//  WatchRecordCell.m
//  yueshipin_ipad
//
//  Created by joyplus1 on 12-11-30.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "WatchRecordCell.h"

@interface WatchRecordCell (){
    UIImageView *separatorImageBottom;
}


@end

@implementation WatchRecordCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        separatorImageBottom = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dividing"]];
    }
    return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//    
//    // Configure the view for the selected state
//}

- (void)layoutSubviews {
    [separatorImageBottom setFrame:CGRectMake( 0.0f, self.frame.size.height - 2.0f, self.frame.size.width, 2.0f)];
    [self addSubview:separatorImageBottom];
}

@end
