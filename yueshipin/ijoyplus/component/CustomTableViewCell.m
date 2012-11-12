//
//  GradientTableViewCell.m
//  GoHappy
//
//  Created by zhipeng zhang on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "CustomCellBackground.h"
#import "SelectedCellBackground.h"



@implementation CustomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = [[CustomCellBackground alloc] init];
        self.selectedBackgroundView = [[SelectedCellBackground alloc] init];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
}

@end
