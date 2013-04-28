//
//  FilmReviewViewCell.m
//  yueshipin
//
//  Created by 08 on 13-3-29.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "FilmReviewViewCell.h"

#define FILMREVIEW_TITLE_LABEL_FRAME                CGRectMake(10, 0, 110, 25)
#define FILMREVIEW_CONTENT_LABEL_FRAME(height)      CGRectMake(8, 32, 280, height)
#define FILMREVIEW_MORE_REVIEW_BUTTON(x)            CGRectMake(x, 115, 60, 15)

@interface FilmReviewViewCell (private)

@end

@implementation FilmReviewViewCell
@synthesize labTitle = _labTitle;
#pragma mark -
#pragma mark - lifeCycle
- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
            content:(NSString *)content
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        UIButton * bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bgBtn setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        UIImage *bgimage = [[UIImage imageNamed:@"yingping_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(50, 10, 20, 10)];
        [bgBtn setBackgroundImage:bgimage forState:UIControlStateNormal];
        [bgBtn setBackgroundImage:bgimage forState:UIControlStateHighlighted];
        [bgBtn addTarget:self
                  action:@selector(backgroundButtonClick:)
        forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgBtn];
        
        _labTitle   = [[UILabel alloc] initWithFrame:FILMREVIEW_TITLE_LABEL_FRAME];
        _labContent = [[UILabel alloc] init];
        
        //_labTitle.textAlignment = UITextAlignmentCenter;
        _labContent.numberOfLines = 0;
        
        _labTitle.font   = [UIFont boldSystemFontOfSize:13];
        _labContent.font = [UIFont systemFontOfSize:12];
        
        NSString * newContent = [NSString stringWithFormat:@" %@",content];
        
        CGSize size = [newContent sizeWithFont:_labContent.font
                          constrainedToSize:CGSizeMake(280, CGFLOAT_MAX)];
        
        CGFloat height = size.height > 80 ? 80 : size.height;
        _labContent.frame = FILMREVIEW_CONTENT_LABEL_FRAME(height);
        
        _labContent.backgroundColor = [UIColor clearColor];
        _labTitle.backgroundColor   = [UIColor clearColor];
        
        _labTitle.text = title;
        _labContent.text = newContent;
        
        _labTitle.textColor   = [UIColor grayColor];
        _labContent.textColor = [UIColor grayColor];
        
        [self addSubview:_labContent];
        [self addSubview:_labTitle];
        
        UIButton *moreReview = [UIButton buttonWithType:UIButtonTypeCustom];
        moreReview.frame = FILMREVIEW_MORE_REVIEW_BUTTON(230.0f);
        [moreReview setTitle:@"全部 >"
                    forState:UIControlStateNormal];
        [moreReview setTitleColor:[UIColor orangeColor]
                         forState:UIControlStateNormal];
        //        [moreReview setBackgroundImage:[UIImage imageNamed:@"report.png"] forState:UIControlStateNormal];
        //        [moreReview setBackgroundImage:[UIImage imageNamed:@"report_pressed.png"] forState:UIControlStateHighlighted];
//        [moreReview addTarget:self
//                       action:@selector(action:)
//             forControlEvents:UIControlEventTouchUpInside];
        moreReview.titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:moreReview];
        moreReview.userInteractionEnabled = NO;
        
        CGRect selfFrame = self.frame;
        selfFrame.size.height = moreReview.frame.origin.y + moreReview.frame.size.height + 6.0f;
        UIImageView * bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, selfFrame.size.width, selfFrame.size.height)];
        bgView.image = nil;
        bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:bgView];
    }
    return self;
}

- (void)dealloc
{
    _labContent = nil;
    _labTitle   = nil;
}

#pragma mark - 
#pragma mark - Private Method
- (void)backgroundButtonClick:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(filmReviewTaped:content:)])
    {
        [_delegate filmReviewTaped:_labTitle.text content:_labContent.text];
    }
}


#pragma mark -
#pragma mark - 对外接口
- (void)refreshView:(NSString *)title content:(NSString *)content
{
    
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
}

@end
