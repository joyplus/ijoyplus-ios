//
//  SearchFilmResultViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-10.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SearchFilmResultViewController.h"
#import "SearchFilmCell.h"
#import "UIImageView+WebCache.h"
#import "SearchVideoCell.h"
#import "PlayRootViewController.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "CustomCellBlackBackground.h"
#import "CustomCellBackground.h"
#import "CMConstants.h"

@interface SearchFilmResultViewController (){
     NSMutableArray *itemsArray;
}
- (void)closeSelf;
@end

@implementation SearchFilmResultViewController

@synthesize keyword;
@synthesize sBar;

- (void)viewDidUnload
{
    [self setSBar:nil];
    [super viewDidUnload];
    self.keyword = nil;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"search", nil);
    CustomBackButtonHolder *backButtonHolder = [[CustomBackButtonHolder alloc]initWithViewController:self];
    CustomBackButton* backButton = [backButtonHolder getBackButton:NSLocalizedString(@"go_back", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	
    [self.sBar setText:self.keyword];
    self.sBar.delegate = self;
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}

- (void)closeSelf
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    itemsArray = [[NSMutableArray alloc]initWithCapacity:10];
    
    NSMutableArray *items1 = [[NSMutableArray alloc]initWithCapacity:20];
    [items1 addObject:@"北京青年"];
    NSMutableDictionary *itemDic1 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic1 setValue:items1 forKey:@"related_film"];
    [itemsArray addObject:itemDic1];
    
    NSMutableArray *items2 = [[NSMutableArray alloc]initWithCapacity:20];
    [items2 addObject:@"爱情公寓3"];
    [items2 addObject:@"快乐大本营"];
    [items2 addObject:@"康熙来了"];
    [items2 addObject:@"百变大咖秀"];
    [items2 addObject:@"天天向上"];
    [items2 addObject:@"海贼王"];
    NSMutableDictionary *itemDic2 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic2 setValue:items2 forKey:@"related_video"];
    
    [itemsArray addObject:itemDic2];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return itemsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableDictionary *item = [itemsArray objectAtIndex:section];
    NSEnumerator *keys = item.keyEnumerator;
    NSString *key = [keys nextObject];
    NSMutableArray *array = [item objectForKey:key];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            SearchFilmCell *cell = (SearchFilmCell*) [tableView dequeueReusableCellWithIdentifier:@"searchFilmCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
                cell = (SearchFilmCell *)[nib objectAtIndex:0];
            }
            [cell.filmImageView setImageWithURL:[NSURL URLWithString:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            cell.filmTitleLabel.text = @"《银光之森》";
            cell.filmThirdTitleLabel.text = @"时长：1小时06分钟";
            
            NSString *intro = @"电影真好看电影真好看电影真好看电影真好看电影真好看电影真好看电影真好看电影真好看电影真好看电影真好看电影真好看电影真好看";
            CGSize constraint = CGSizeMake(182, 70);
            CGSize size = [intro sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeTailTruncation];
            cell.filmSubitleLabel.frame = CGRectMake(cell.filmSubitleLabel.frame.origin.x, cell.filmSubitleLabel.frame.origin.y, size.width, size.height);
            cell.filmSubitleLabel.text = intro;
            
            
            UIView *backgroundView;
            if(indexPath.row % 2 == 0){
                backgroundView = [[CustomCellBlackBackground alloc]init];
            } else {
                backgroundView = [[CustomCellBackground alloc]init];
            }
            [cell setBackgroundView:backgroundView];
            
            return cell;
        }
        case 1:
        {
            SearchVideoCell *cell = (SearchVideoCell*) [tableView dequeueReusableCellWithIdentifier:@"searchVideoCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PopularCellFactory" owner:self options:nil];
                cell = (SearchVideoCell *)[nib objectAtIndex:1];
            }
            [cell.videoImageView setImageWithURL:[NSURL URLWithString:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg"] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            cell.videoTitleLabel.text = @"《银光之森》";
            cell.videoSubtitleLabel.text = @"时长：1小时06分钟";
            cell.videoImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            cell.videoImageView.layer.borderWidth = 1;
            
            UIView *backgroundView;
            if(indexPath.row % 2 == 0){
                backgroundView = [[CustomCellBlackBackground alloc]init];
            } else {
                backgroundView = [[CustomCellBackground alloc]init];
            }
            [cell setBackgroundView:backgroundView];
            return cell;
        }
    }
    return nil;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(10,0,self.view.bounds.size.width,24)];
    customView.backgroundColor = [UIColor blackColor];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bgwithline"]];
    imageView.frame = customView.frame;
    [customView addSubview:imageView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    NSMutableDictionary *item = [itemsArray objectAtIndex:section];
    NSEnumerator *keys = item.keyEnumerator;
    NSString *key = [keys nextObject];
    headerLabel.text =  [NSString stringWithFormat:NSLocalizedString(key, nil), self.keyword, nil];
    headerLabel.textColor = [UIColor lightGrayColor];
    [headerLabel sizeToFit];
    headerLabel.center = CGPointMake(headerLabel.frame.size.width/2 + 10, customView.frame.size.height/2);
    [customView addSubview:headerLabel];
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section ==0){
        return 140;
    } else {
        return 120;
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.sBar resignFirstResponder];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    PlayRootViewController *viewController = [[PlayRootViewController alloc]init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

@end
