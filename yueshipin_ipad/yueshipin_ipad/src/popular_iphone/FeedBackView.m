//
//  FeedBackView.m
//  yueshipin
//
//  Created by 08 on 13-4-1.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "FeedBackView.h"

#define FEEDBACK_REASON_OTHER   (6)
#define SPACE                   (@" ")
#define FEEDBACK_VEWI_TAG       (11123)
#define one @"1"
#define two @"2"
#define three @"3"
#define four @"4"
#define five @"5"
#define six @"6"
#define seven @"7"

@interface FeedBackView ()

@property (nonatomic, strong) UIButton  *_lastSelected;
- (void)customView;

@end

@implementation FeedBackView
@synthesize delegate;
@synthesize _lastSelected;
@synthesize selectArr = selectArr_;
#pragma mark -
#pragma mark - lifeCycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {  
        // Initialization code
        
        _arrFeedBackOption = [[NSArray alloc] initWithObjects:@"影片无法播放",@"影片播放不流畅",@"影片加载比较慢",@"影片不能加载",@"观看影片时出现闪退",@"画质不清晰",@"音画不同步", nil];
        
        UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25f];
        [self addSubview:bgView];
        
        UIButton *bgButton =[UIButton buttonWithType:UIButtonTypeCustom];
        bgButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [bgButton addTarget:self
                     action:@selector(backgroundClicked:)
           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgButton];
        
        [self customView];
    }
    return self;
}

- (void)dealloc
{
    _arrFeedBackOption = nil;
    _lastSelected = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -
#pragma mark - private

- (void)customView
{
    UIView * feedback = [[UIView alloc] initWithFrame:CGRectMake(10, 85, 295, 376)];
    feedback.backgroundColor = [UIColor clearColor];
    [self addSubview:feedback];
    feedback.tag = FEEDBACK_VEWI_TAG;
    
    UIImageView * feedbackImage = [[UIImageView alloc] initWithFrame:CGRectMake(-2, -2, 299, 376)];//kFullWindowHeight * 0.685
    feedbackImage.image = [[UIImage imageNamed:@"popview_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    feedbackImage.backgroundColor = [UIColor clearColor];
    feedbackImage.userInteractionEnabled = YES;
    [feedback addSubview:feedbackImage];
    
    UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(251, 6, 38, 38);
    [closeBtn addTarget:self
                 action:@selector(backgroundClicked:)
       forControlEvents:UIControlEventTouchUpInside];
    [feedback addSubview:closeBtn];
    closeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 19, 19, 0);
    [closeBtn setImage:[UIImage imageNamed:@"download_shut.png"]
              forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"download_shut_pressed.png"]
              forState:UIControlStateHighlighted];
    closeBtn.backgroundColor = [UIColor clearColor];
    
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(17, 18, 252, 30)];
    title.numberOfLines = 0;
    title.font   = [UIFont boldSystemFontOfSize:13];
    title.text = @"亲，请您告知我们您在看片过程中遇到哪些问题,我们一定尽快改进 : )";
    title.backgroundColor   = [UIColor clearColor];
    title.textColor   = [UIColor grayColor];
    [feedback addSubview:title];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(7, \
                                                                        title.frame.origin.y + title.frame.size.height + 10.0f,\
                                                                        280, 210)
                                                       style:UITableViewStylePlain];
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    [feedback addSubview:_tableView];
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = [UIColor clearColor];
    
    
    UILabel * other = [[UILabel alloc] initWithFrame:CGRectMake(17, \
                                                                _tableView.frame.origin.y + _tableView.frame.size.height + 5.0f,\
                                                                60, 30)];
    other.numberOfLines = 2;
    //other.textAlignment = UITextAlignmentCenter;
    other.font   = [UIFont boldSystemFontOfSize:15];
    other.text = @"其它";
    other.backgroundColor   = [UIColor clearColor];
    other.textColor   = [UIColor grayColor];
    [feedback addSubview:other];
    
    
    UIImageView * bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(50, other.frame.origin.y + 4, 228.5, 24)];
    bgImage.image = [UIImage imageNamed:@"otherTextBG.png"];
    [feedback addSubview:bgImage];
    
    _textViewOther = [[UITextField alloc] initWithFrame:bgImage.frame];
    _textViewOther.backgroundColor = [UIColor clearColor];
    [feedback addSubview:_textViewOther];
    _textViewOther.delegate = self;
    _textViewOther.returnKeyType = UIReturnKeyDone;
    
    UIButton * commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commitBtn.frame = CGRectMake(90, \
                                 _textViewOther.frame.size.height + _textViewOther.frame.origin.y + 20,\
                                 104, 39);
    [commitBtn addTarget:self
                 action:@selector(commitButtonClick:)
       forControlEvents:UIControlEventTouchUpInside];
    //[feedback addSubview:commitBtn];
    [commitBtn setImage:[UIImage imageNamed:@"ti_jiao_s.png"]
               forState:UIControlStateHighlighted];
    [commitBtn setImage:[UIImage imageNamed:@"ti_jiao.png"]
               forState:UIControlStateNormal];
    [feedback addSubview:commitBtn];
    
    selectArr_ = [NSMutableArray arrayWithCapacity:5];
}

- (void)commitButtonClick:(id)sender
{
//    NSInteger selectedIndex = NSNotFound;
//    
//    if (_lastSelected.selected)
//    {
//        selectedIndex = _lastSelected.tag + 1;
//    }
//    else
//    {
//        selectedIndex = 8;
//    }
    if (0 == _textViewOther.text.length && [selectArr_ count] == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                         message:@"亲，您还没有告诉我们问题哟！"
                                                        delegate:nil
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (delegate && [delegate respondsToSelector:@selector(feedBackType:detailReason:)])
    {
        NSMutableString *typeStr = [[NSMutableString alloc] initWithCapacity:5];
        NSArray *tempArr = [selectArr_ sortedArrayUsingSelector:@selector(compare:)];
        for (int i = 0; i<[tempArr count];i++) {
            NSString *tempstr = [tempArr objectAtIndex:i];
            if (i == [tempArr count]-1) {
                [typeStr appendString:tempstr];
            }
            else{
                [typeStr appendString:[NSString stringWithFormat:@"%@%@",tempstr,@","]];
            }
            
        }
        [delegate feedBackType:typeStr detailReason:_textViewOther.text];
    }
    [self backgroundClicked:nil];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"问题提交成功，我们会尽快处理，谢谢！"
                                                   delegate:nil
                                          cancelButtonTitle:@"我知道了"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void)selectBtnClicked:(id)sender
{
    UIButton * select = (UIButton *)sender;
    select.selected = !select.selected;
    
    switch (select.tag) {
        case 0:
            if ([selectArr_ containsObject:one]) {
                [selectArr_ removeObject:one];
            }
            else{
                [selectArr_ addObject:one];
            }
            break;
        case 1:
            if ([selectArr_ containsObject:two]) {
                [selectArr_ removeObject:two];
            }
            else{
                [selectArr_ addObject:two];
            }
            break;
        case 2:
            if ([selectArr_ containsObject:three]) {
                [selectArr_ removeObject:three];
            }
            else{
                [selectArr_ addObject:three];
            }
            break;
        case 3:
            if ([selectArr_ containsObject:four]) {
                [selectArr_ removeObject:four];
            }
            else{
                [selectArr_ addObject:four];
            }
            break;
        case 4:
            if ([selectArr_ containsObject:five]) {
                [selectArr_ removeObject:five];
            }
            else{
                [selectArr_ addObject:five];
            }
            break;
        case 5:
            if ([selectArr_ containsObject:six]) {
                [selectArr_ removeObject:six];
            }
            else{
                [selectArr_ addObject:six];
            }
            break;
        case 6:
            if ([selectArr_ containsObject:seven]) {
                [selectArr_ removeObject:seven];
            }
            else{
                [selectArr_ addObject:seven];
            }
            break;
        default:
            break;
    }
    
    return;
    if (select != _lastSelected)
    {
        if (_lastSelected.selected)
            _lastSelected.selected = NO;
        select.selected = !select.selected;
        _lastSelected = select;
    }
    else
    {
        select.selected = !select.selected;
    }
    
}

- (void)backgroundClicked:(id)sender
{
    [self removeFromSuperview];
}

#pragma mark -
#pragma mark - 对外接口

#pragma mark -
#pragma mark - UITextFielDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textViewOther resignFirstResponder];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.3f];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    CGRect rect = [self viewWithTag:FEEDBACK_VEWI_TAG].frame;
    rect.origin.y = 0;
    [self viewWithTag:FEEDBACK_VEWI_TAG].frame = rect;
    [UIView commitAnimations];

}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.3f];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    CGRect rect = [self viewWithTag:FEEDBACK_VEWI_TAG].frame;
    rect.origin.y = 85;
    [self viewWithTag:FEEDBACK_VEWI_TAG].frame = rect;
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark - TableViewDelegate & TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrFeedBackOption.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"feedBackCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIButton * selectBtn = nil;
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectBtn.frame = CGRectMake(217, 0, 58, 29);
        selectBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 29, 0, 0);
        [cell addSubview:selectBtn];
        [selectBtn addTarget:self
                      action:@selector(selectBtnClicked:)
            forControlEvents:UIControlEventTouchUpInside];
        [selectBtn setImage:[UIImage imageNamed:@"xuan_ze_s.png"]
                   forState:UIControlStateSelected];
        [selectBtn setImage:[UIImage imageNamed:@"xuan_ze.png"]
                   forState:UIControlStateNormal];
        selectBtn.adjustsImageWhenHighlighted = NO;
    }
     selectBtn.tag = indexPath.row;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [_arrFeedBackOption objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"ArialMT" size:12];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 29.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
