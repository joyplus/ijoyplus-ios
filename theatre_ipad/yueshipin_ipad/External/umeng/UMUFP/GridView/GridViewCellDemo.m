//
//  ImageViewCell.h
//  UFP
//
//  Created by liu yu on 7/23/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "GridViewCellDemo.h"

#define TOPMARGIN  5.0f
#define LEFTMARGIN 20.0f
#define IMAGEWIDTH 56.0f

@implementation GridViewCellDemo

@synthesize titleLabel = _titleLabel;
@synthesize imageView = _imageView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    return self;
}

-(id)initWithIdentifier:(NSString *)indentifier
{
	if(self = [super initWithIdentifier:indentifier])
	{
        self.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UMUFPImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"UMUFP.bundle/um_placeholder.png"]];  
        _imageView.layer.cornerRadius = 9.0;
        _imageView.layer.masksToBounds = YES;
        _imageView.backgroundColor = [UIColor clearColor];
        
        self.imageView.layer.borderWidth = 0.8;
        self.imageView.layer.borderColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5].CGColor;
        
        [self addSubview:_imageView];
        
        if ([self.imageView.layer respondsToSelector:@selector(setShouldRasterize:)]) 
        {
            [self.imageView.layer setShouldRasterize:YES]; 
            self.imageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        }
        
        if ([self.layer respondsToSelector:@selector(setShouldRasterize:)]) 
        {
            self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
            [self.layer setShouldRasterize:YES];        
        }
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:11.0];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        [self addSubview:_titleLabel];        
	}
	
	return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake((self.bounds.size.width-IMAGEWIDTH)/2, TOPMARGIN, IMAGEWIDTH, IMAGEWIDTH);
    self.titleLabel.frame = CGRectMake(LEFTMARGIN, self.imageView.frame.origin.y + self.imageView.frame.size.height + 5, self.bounds.size.width-2*LEFTMARGIN, 12);
}

@end