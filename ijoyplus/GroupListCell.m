//
//  GroupListCell.m
//  ijoyplus
//
//  Created by joyplus1 on 12-11-9.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "GroupListCell.h"

@implementation GroupListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    // Layout separator
    self.separatorImageBottom.image = [UIImage imageNamed:@"black_separator"];
    [self.separatorImageBottom setFrame:CGRectMake( 0.0f, self.frame.size.height - 2.0f, self.frame.size.width, 2.0f)];
    
    if(self.showTopImage){
        self.separatorImageTop.image = [UIImage imageNamed:@"black_separator"];
        [self.separatorImageTop setFrame:CGRectMake( 0.0f, 0.0f, self.frame.size.width, 2.0f)];
    }
}

@end
