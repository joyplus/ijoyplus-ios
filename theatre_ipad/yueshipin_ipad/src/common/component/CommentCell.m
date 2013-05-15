//
//  CommentCell.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-11.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CommentCell.h"

@interface CommentCell (){
    UIImageView *separatorImageBottom;
}


@end

@implementation CommentCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        separatorImageBottom = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dividing"]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [separatorImageBottom setFrame:CGRectMake( 0.0f, self.frame.size.height - 2.0f, self.frame.size.width, 2.0f)];
    [self addSubview:separatorImageBottom];
}

@end
