//
//  SearchFilmViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-10.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SearchFilmViewController.h"
#import "SearchFilmResultViewController.h"
#import "CustomBackButtonHolder.h"
#import "CustomBackButton.h"
#import "CustomTableViewCell.h"
#import "CustomCellBackground.h"
#import "CustomCellBlackBackground.h"


@interface SearchFilmViewController (){
    NSMutableArray *itemsArray;
}

- (void)closeSelf;

@end

@implementation SearchFilmViewController
@synthesize sBar;

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
    self.sBar.delegate = self;
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidUnload
{
    [self setSBar:nil];
    [super viewDidUnload];
    itemsArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    itemsArray = [[NSMutableArray alloc]initWithCapacity:10];
    
    NSMutableArray *items1 = [[NSMutableArray alloc]initWithCapacity:20];
    [items1 addObject:@"北京青年"];
    [items1 addObject:@"中国好声音"];
    NSMutableDictionary *itemDic1 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic1 setValue:items1 forKey:@"search_history"];
    [itemsArray addObject:itemDic1];
    
    NSMutableArray *items2 = [[NSMutableArray alloc]initWithCapacity:20];
    [items2 addObject:@"爱情公寓3"];
    [items2 addObject:@"快乐大本营"];
    [items2 addObject:@"康熙来了"];
    [items2 addObject:@"百变大咖秀"];
    [items2 addObject:@"天天向上"];
    [items2 addObject:@"海贼王"];
    NSMutableDictionary *itemDic2 = [[NSMutableDictionary alloc]initWithCapacity:10];
    [itemDic2 setValue:items2 forKey:@"hot_keys"];
    
    [itemsArray addObject:itemDic2];
}

- (void)closeSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    static NSString *CellIdentifier = @"Cell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[CustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UIView *backgroundView;
    if(indexPath.row % 2 == 0){
        backgroundView = [[CustomCellBlackBackground alloc]init];
    } else {
        backgroundView = [[CustomCellBackground alloc]init];
    }
    [cell setBackgroundView:backgroundView];
    
    NSMutableDictionary *item = [itemsArray objectAtIndex:indexPath.section];
    NSEnumerator *keys = item.keyEnumerator;
    NSMutableArray *items = [item objectForKey:[keys nextObject]];
    cell.textLabel.text = [items objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,24)];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bgwithline"]];
    imageView.frame = customView.frame;
    [customView addSubview:imageView];
        
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    NSMutableDictionary *item = [itemsArray objectAtIndex:section];
    NSEnumerator *keys = item.keyEnumerator;
    NSString *key = [keys nextObject];
    headerLabel.text =  NSLocalizedString(key, nil);
    headerLabel.textColor = [UIColor whiteColor];
    [headerLabel sizeToFit];
    headerLabel.center = CGPointMake(headerLabel.frame.size.width/2 + 10, customView.frame.size.height/2);
    [customView addSubview:headerLabel];
    return customView;
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
    SearchFilmResultViewController *viewController = [[SearchFilmResultViewController alloc] initWithNibName:@"SearchFilmResultViewController" bundle:nil];
    viewController.keyword = self.sBar.text;
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
    SearchFilmResultViewController *viewController = [[SearchFilmResultViewController alloc] initWithNibName:@"SearchFilmResultViewController" bundle:nil];
    viewController.keyword = self.sBar.text;
    [self.navigationController pushViewController:viewController animated:YES];   
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

@end
