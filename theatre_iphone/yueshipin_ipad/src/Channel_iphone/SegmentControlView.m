//
//  SegmentControlView.m
//  theatreiphone
//
//  Created by Rong on 13-5-13.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SegmentControlView.h"

#define MOVIE_ALL_TYPE  [NSArray arrayWithObjects:@"全部",@"动作",@"恐怖",@"惊悚",@"爱情",@"悬疑",@"伦理",@"剧情",@"喜剧",@"科幻",@"战争",@"冒险",@"音乐",@"动画",@"运动",@"奇幻",@"传记",@"古装",@"犯罪",@"武侠",@"其他", nil]
#define  MOVIE_ALL_AREA  [NSArray arrayWithObjects:@"全部",@"美国",@"内地",@"香港",@"台湾",@"日本",@"韩国",@"欧洲",@"东南亚",@"其他",nil]

#define  TV_ALL_TYPE  [NSArray arrayWithObjects:@"全部",@"剧情",@"情感",@"青春偶像",@"家庭伦理",@"喜剧",@"犯罪",@"战争",@"古装",@"动作",@"奇幻",@"经典",@"乡村",@"商战",@"历史",@"情景",@"TVB",@"其他", nil]
#define  TV_ALL_AREA   [NSArray arrayWithObjects:@"全部",@"美国",@"香港",@"台湾",@"韩国",@"日本",@"内地",@"其他",nil]

#define  COMIC_ALL_TYPE  [NSArray arrayWithObjects:@"全部",@"情感",@"科幻",@"热血",@"推理",@"搞笑",@"冒险",@"萝莉",@"校园",@"动作",@"机战",@"运动",@"耽美",@"战争",@"少年",@"少女",@"社会",@"原创",@"亲子",@"益智",@"励志" ,@"百合",@"其他",nil]
#define  COMIC_ALL_AREA  [NSArray arrayWithObjects:@"全部",@"日本",@"欧美",@"国产",@"其他",nil]

#define  SHOW_ALL_TYPE  [NSArray arrayWithObjects:@"全部",@"综艺",@"选秀",@"情感",@"访谈",@"播报",@"旅游",@"音乐",@"美食",@"纪实",@"曲艺",@"生活",@"游戏",@"互动",@"财经",@"求职",@"其他", nil]
#define  SHOW_ALL_AREA  [NSArray arrayWithObjects:@"全部",@"港台",@"内地",@"日韩",@"欧美",@"其他",nil]

#define  MOVIE_YEAR  [NSArray arrayWithObjects:@"全部",@"2013",@"2012",@"2011",@"2010",@"2009",@"2008",@"2007",@"2006",@"2005",nil]

@implementation SegmentControlView
@synthesize seg = _seg;
@synthesize movieLabelArr = _movieLabelArr;
@synthesize tvLabelArr = _tvLabelArr;
@synthesize comicLabelArr = _comicLabelArr;
@synthesize showLabelArr = _showLabelArr;
@synthesize delegate = _delegate;
@synthesize segControlBg = _segControlBg;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _movieLabelArr = [NSArray arrayWithObjects:@"全部",@"美国",@"动作",@"科幻",@"爱情",@"更多",nil];
        _tvLabelArr = [NSArray arrayWithObjects:@"全部",@"美国",@"韩国",@"日本",@"香港",@"更多",nil];
        _comicLabelArr = [NSArray arrayWithObjects:@"全部",@"日本",@"欧美",@"国产",@"热血",@"更多",nil];
        _showLabelArr = [NSArray arrayWithObjects:@"全部",@"综艺",@"选秀",@"情感",@"访谈",@"更多",nil];
        PreKey_ = @"全部";
        UIView *segmentBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 42)];
        segmentBg.backgroundColor = [UIColor colorWithRed:43/255.0 green:43/255.0 blue:43/255.0 alpha:1];
        [self addSubview:segmentBg];
        
        [self setSegmentControl:TYPE_MOVIE];

    }
    return self;
}
-(void)setSegmentControl:(int)type{
    if (_seg) {
        [_seg removeFromSuperview];
         _seg = nil;
    }
    switch (type) {
        case TYPE_MOVIE:
            videoType_ = TYPE_MOVIE;
            [self setSegmentViewWithItems:_movieLabelArr];
            break;
        case TYPE_TV:
            videoType_ = TYPE_TV;
            [self setSegmentViewWithItems:_tvLabelArr];
            break;
        case TYPE_COMIC:
            videoType_ = TYPE_COMIC;
            [self setSegmentViewWithItems:_comicLabelArr];
            break;
        case TYPE_SHOW:
            videoType_ = TYPE_SHOW;
            [self setSegmentViewWithItems:_showLabelArr];
            break;
        default:
            break;
    }
}
-(void)setSegmentViewWithItems:(NSArray *)arr{
    if (_segControlBg  != nil) {
        _segControlBg = nil;
    }
    _segControlBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 306, 30)];
    _segControlBg.center = CGPointMake(160, 21);
    _segControlBg.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnSelf)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.delegate = self;
    tapRecognizer.cancelsTouchesInView = NO;
    [_segControlBg addGestureRecognizer:tapRecognizer];
    
    for (int i = 0; i < [arr count]; i++) {
        NSString *str = arr[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            btn.enabled = NO;
            [btn setBackgroundImage:[UIImage imageNamed:@"segment1.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"segment1_s.png"] forState:UIControlStateHighlighted];
            [btn setBackgroundImage:[UIImage imageNamed:@"segment1_s.png"] forState:UIControlStateDisabled];
        }
        else if (i == [arr count]-1){
            [btn setBackgroundImage:[UIImage imageNamed:@"segment3.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"segment3_s.png"] forState:UIControlStateHighlighted];
            [btn setBackgroundImage:[UIImage imageNamed:@"segment3_s.png"] forState:UIControlStateDisabled];
        }
        else{
            [btn setBackgroundImage:[UIImage imageNamed:@"segment2.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"segment2_s.png"] forState:UIControlStateHighlighted];
            [btn setBackgroundImage:[UIImage imageNamed:@"segment2_s.png"] forState:UIControlStateDisabled];
        }
        
        btn.frame = CGRectMake(50*i, 0, 51, 30);
        btn.tag = 100+i;
        [btn setTitle:str forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        [_segControlBg addSubview:btn];
    }
    [self addSubview:_segControlBg];
}
-(void)selectButton:(UIButton *)btn{
    for (int i = 0; i < 6; i++) {
        UIButton *oneBtn = (UIButton *)[_segControlBg viewWithTag:100+i];
        if (100+i == btn.tag) {
            oneBtn.enabled = NO;
        }
        else{
            oneBtn.enabled = YES;
        
        }
    }
    
    NSArray *arr = nil;
    switch (videoType_) {
        case TYPE_MOVIE:
            arr = [NSArray arrayWithArray:_movieLabelArr];
            break;
        case TYPE_TV:
            arr = [NSArray arrayWithArray:_tvLabelArr];
            break;
        case TYPE_COMIC:
            arr = [NSArray arrayWithArray:_comicLabelArr];
            break;
        case TYPE_SHOW:
            arr = [NSArray arrayWithArray:_showLabelArr];
            break;
            
        default:
            break;
    }
    
    if (btn.tag < 105) {
        NSString *selectedStr = [arr objectAtIndex:(btn.tag-100)];
        NSString *key = [SegmentControlView getKeyByString:selectedStr];
        PreKey_ = selectedStr;
        if ([selectedStr isEqualToString:@"全部"]) {
            selectedStr = @"";
        }
        [_delegate segmentDidSelectedLabelStr:selectedStr withKey:key];
    }
    else{
        
        [_delegate moreSelectWithType:videoType_ withCurrentKey:PreKey_];
    }
    
}

-(void)tapOnSelf{
    [_delegate didTapOnSegmentView];
}

+(NSString *)getKeyByString:(NSString *)str{
    NSMutableArray *typeArr = [NSMutableArray arrayWithCapacity:5];
    [typeArr addObjectsFromArray:MOVIE_ALL_TYPE];
    [typeArr addObjectsFromArray:TV_ALL_TYPE];
    [typeArr addObjectsFromArray:COMIC_ALL_TYPE];
    [typeArr addObjectsFromArray:SHOW_ALL_TYPE];
    int index = [typeArr indexOfObject:str];
    if (index != NSNotFound) {
        return @"sub_type";
    }
    else{
        return @"area";
    
    }
}
@end




@implementation FiltrateView

@synthesize parametersDic = _parametersDic;
@synthesize delegate = _delegate;
@synthesize currentKey = _currentKey;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -5, 320, self.frame.size.height+5)];
        bgView.image = [[UIImage imageNamed:@"gengduo_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 40)];
        [self addSubview:bgView];
        
        UILabel *typelabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 8, 50, 20)];
        typelabel.text = @"类型:";
        typelabel.font = [UIFont systemFontOfSize:15];
        typelabel.textColor = [UIColor whiteColor];
        typelabel.backgroundColor = [UIColor clearColor];
        [self addSubview:typelabel];
        
        UILabel *arealabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 44, 50, 20)];
        arealabel.text = @"地区:";
        arealabel.font = [UIFont systemFontOfSize:15];
        arealabel.textColor = [UIColor whiteColor];
        arealabel.backgroundColor = [UIColor clearColor];
        [self addSubview:arealabel];
        
        UILabel *yearlabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 50, 20)];
        yearlabel.text = @"年份:";
        yearlabel.font = [UIFont systemFontOfSize:15];
        yearlabel.textColor = [UIColor whiteColor];
        yearlabel.backgroundColor = [UIColor clearColor];
        [self addSubview:yearlabel];

        for ( int i = 0; i < 3; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(302, 12+36*i, 9, 14);
            [btn setBackgroundImage:[UIImage imageNamed:@"jiantou_gengduo.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"jiantou_gengduo.png"] forState:UIControlStateHighlighted];
            [self addSubview:btn];
        }
    
        _parametersDic = [NSMutableDictionary dictionaryWithCapacity:5];
        [_parametersDic setObject:@"" forKey:@"sub_type"];
        [_parametersDic setObject:@"" forKey:@"area"];
        [_parametersDic setObject:@"" forKey:@"year"];
    }
    return self;
}

-(void)setViewWithType:(int)type{
    _videoType = type;
    
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [view removeFromSuperview];
        }
    }
    switch (type) {
        case TYPE_MOVIE:{
            [self setScrollViewWithItems:MOVIE_ALL_TYPE atPosition:0];
            [self setScrollViewWithItems:MOVIE_ALL_AREA atPosition:1];

            break;
        }
        case TYPE_TV:
        {
            [self setScrollViewWithItems:TV_ALL_TYPE atPosition:0];
            [self setScrollViewWithItems:TV_ALL_AREA atPosition:1];
            break;
        }
        case TYPE_COMIC:
        {
            [self setScrollViewWithItems:COMIC_ALL_TYPE atPosition:0];
            [self setScrollViewWithItems:COMIC_ALL_AREA atPosition:1];
            break;
        }
        case TYPE_SHOW:
        {
            [self setScrollViewWithItems:SHOW_ALL_TYPE atPosition:0];
            [self setScrollViewWithItems:SHOW_ALL_AREA atPosition:1];
            
            break;
        }
            
        default:
            break;
    }
    [self setScrollViewWithItems:MOVIE_YEAR atPosition:2];

}
-(void)setFiltrateViewCurrentKey:(NSString *)currentKey{
    //_currentKey = currentKey;
    if ([currentKey isEqualToString:@"全部"]) {
        return;
    }
  
    NSString *key = [SegmentControlView getKeyByString:currentKey];
    [_parametersDic setObject:currentKey forKey:key];
    if ([key isEqualToString:@"sub_type"]) {
        UIScrollView *firstScroll = (UIScrollView *)[self viewWithTag:90];
        for (UIView *view in [firstScroll subviews]) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)view;
                if (btn.tag == 0) {
                    btn.selected = NO;
                }
                if ([btn.titleLabel.text isEqualToString:currentKey]) {
                    btn.selected = YES;
                    return;
                }
            }
        }

    }
    else if([key isEqualToString:@"area"]){
        UIScrollView *secondScroll = (UIScrollView *)[self viewWithTag:91];
        for (UIView *view in [secondScroll subviews]) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton *)view;
                if (btn.tag == 100) {
                    btn.selected = NO;
                }
                if ([btn.titleLabel.text isEqualToString:currentKey]) {
                    btn.selected = YES;
                    return;
                }
            }
        }

    
    }

}
-(void)setScrollViewWithItems:(NSArray *)items atPosition:(int)position{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(50, 36*position, 245, 36)];
    scrollView.tag = 90+position;
    int all = [items count];
    int pageCount = (all%5 == 0) ? (all/5) : (all/5+1);
    scrollView.contentSize = CGSizeMake(245*pageCount, 36);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    for (int i = 0; i < all; i++) {
        NSString *str = [items objectAtIndex:i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            btn.selected = YES;
        }
        btn.tag = position*100+i;
        btn.frame = CGRectMake(49*i, 0, 49, 36);
        [btn setTitle:str forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:247/255.0 green:122/255.0 blue:151/255.0 alpha:1] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor colorWithRed:247/255.0 green:122/255.0 blue:151/255.0 alpha:1] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(didSelect:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:btn];
    }
    [self addSubview:scrollView];
   
    if (position == 0 || position == 1) {
        UIImageView *fengexian = [[UIImageView alloc] initWithFrame:CGRectMake(0, 36*position+35, 320, 1)];
        fengexian.image = [[UIImage imageNamed:@"fengexian_gengduo.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
        [self addSubview:fengexian];
    }
}

-(void)didSelect:(UIButton *)btn{
    btn.selected = YES;
    NSString *str = btn.titleLabel.text;
    if ([str isEqualToString:@"全部"]) {
        str = @"";
    }
    
    if (btn.tag < 100) {
        [_parametersDic setObject:str forKey:@"sub_type"];
        [self resetButtonStateInPosition:0];
    }
    else if(btn.tag >100 && btn.tag <200){
        [_parametersDic setObject:str forKey:@"area"];
        [self resetButtonStateInPosition:1];
    }
    else if(btn.tag >200 && btn.tag <300){
        [_parametersDic setObject:str forKey:@"year"];
        [self resetButtonStateInPosition:2];
    }
    btn.selected = YES;
    [_delegate filtrateWithVideoType:_videoType parameters:_parametersDic];
}
-(void)resetButtonStateInPosition:(int)position{
    UIScrollView *scrollView = nil;
    switch (position) {
        case 0:{
             scrollView = (UIScrollView *)[self viewWithTag:90];
            
            break;
        }
        case 1:{
             scrollView = (UIScrollView *)[self viewWithTag:91];
            break;
        }
        case 2:{
             scrollView = (UIScrollView *)[self viewWithTag:92];
            break;
        }
        default:
            break;
    }
    for (UIView *view in [scrollView subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            btn.selected = NO;
        }
        
    }

}
@end
