//
//  SearchFilmViewController.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-10.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SearchFilmViewController.h"
#import "SearchFilmResultViewController.h"
#import "CustomBackButton.h"
#import "CustomTableViewCell.h"
#import "CustomCellBackground.h"
#import "CustomCellBlackBackground.h"
#import "StringUtility.h"
#import "AFServiceAPIClient.h"
#import "ServiceConstants.h"
#import "ContainerUtility.h"
#import "DateUtility.h"
#import "NSDate-Utilities.h"
#import "CMConstants.h"
#import "UIUtility.h"

@interface SearchFilmViewController (){
    NSMutableArray *historyArray;
    NSMutableArray *hotKeyArray;
    CustomBackButton *backButton;
}

- (void)closeSelf;

@end

@implementation SearchFilmViewController
@synthesize sBar;

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setSBar:nil];
    [historyArray removeAllObjects];
    historyArray = nil;
    [hotKeyArray removeAllObjects];
    hotKeyArray = nil;
    backButton = nil;
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
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    backButton = [[CustomBackButton alloc] initWith:[UIImage imageNamed:@"back-button"] highlight:[UIImage imageNamed:@"back-button"] leftCapWidth:14.0 text:NSLocalizedString(@"back", nil)];
    [backButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.sBar.delegate = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    historyArray = (NSMutableArray *)[[ContainerUtility sharedInstance] attributeForKey:@"search_history"];
    if(historyArray == nil){
        historyArray = [[NSMutableArray alloc]initWithCapacity:LOCAL_KEYS_NUMBER];
    }
    hotKeyArray = [[NSMutableArray alloc]initWithCapacity:10];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *sortedArray = [historyArray sortedArrayUsingComparator:^(id a, id b) {
        NSDate *first = [DateUtility dateFromFormatString:[(NSMutableDictionary*)a objectForKey:@"last_search_date"] formatString: @"yyyy-MM-dd HH:mm:ss"] ;
        NSDate *second = [DateUtility dateFromFormatString:[(NSMutableDictionary*)b objectForKey:@"last_search_date"] formatString: @"yyyy-MM-dd HH:mm:ss"];
        return [second compare:first];
    }];
    historyArray = [[NSMutableArray alloc]initWithCapacity:LOCAL_KEYS_NUMBER];
    for(NSDictionary *item in sortedArray){
        NSMutableDictionary *cloneItem = [[NSMutableDictionary alloc]initWithDictionary:item];
        [historyArray addObject:cloneItem];
    }
    
    if(hotKeyArray.count == 0){
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:10], @"num", nil];
        [[AFServiceAPIClient sharedClient] getPath:kPathSearchTopKeywords parameters:parameters success:^(AFHTTPRequestOperation *operation, id result) {
            NSString *responseCode = [result objectForKey:@"res_code"];
            if(responseCode == nil){
                NSArray *keyArray = (NSArray *)[result objectForKey:@"topKeywords"];
                if(keyArray != nil && keyArray.count > 0){
                    [hotKeyArray addObjectsFromArray:keyArray];
                }
                [self.tableView reloadData];
            } else {
                
            }
        } failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    [self.tableView reloadData];
}

- (void)closeSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(historyArray.count > 0){
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(historyArray.count > 0){
        if(section == 0){
            return historyArray.count;
        } else {
            return hotKeyArray.count;
        }
    } else {
        return hotKeyArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[CustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UIView *backgroundView;
        if(indexPath.row % 2 == 0){
            backgroundView = [[CustomCellBlackBackground alloc]init];
        } else {
            backgroundView = [[CustomCellBackground alloc]init];
        }
        [cell setBackgroundView:backgroundView];
    }

    
    if(historyArray.count > 0){
        if(indexPath.section == 0){
            cell.textLabel.text = [[historyArray objectAtIndex:indexPath.row]valueForKey:@"content"];
        } else {
            if(hotKeyArray.count > 0){
                cell.textLabel.text = [[hotKeyArray objectAtIndex:indexPath.row] valueForKey:@"content"];
            }
        }
    } else {
        if(hotKeyArray.count > 0){
            cell.textLabel.text = [[hotKeyArray objectAtIndex:indexPath.row] valueForKey:@"content"];
        }
    }
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
    if(historyArray.count > 0){
        if(section == 0){
            headerLabel.text = NSLocalizedString(@"search_history", nil);
        } else {
            headerLabel.text = NSLocalizedString(@"hot_keys", nil);
        }
    } else {
        headerLabel.text = NSLocalizedString(@"hot_keys", nil);
    }
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
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    NSInteger sectionNum = [self numberOfSectionsInTableView:tableView];
    NSString *key;
    if(sectionNum > 1 && indexPath.section == 0){
        key = [[historyArray objectAtIndex:indexPath.row] valueForKey:@"content"];
        [self addKeyToLocalHistory:key];
    } else {
        key = [[hotKeyArray objectAtIndex:indexPath.row] valueForKey:@"content"];
    }
    self.sBar.text = key;
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
    if(![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]){
        [UIUtility showNetWorkError:self.view];
        return;
    }
    [self addKeyToLocalHistory:self.sBar.text];
    SearchFilmResultViewController *viewController = [[SearchFilmResultViewController alloc] initWithNibName:@"SearchFilmResultViewController" bundle:nil];
    viewController.keyword = self.sBar.text;
    [self.navigationController pushViewController:viewController animated:YES];   
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
}

- (void)addKeyToLocalHistory:(NSString *)key
{
    NSMutableDictionary *newItem;
    for(NSMutableDictionary *item in historyArray){
        NSString *content = [item objectForKey:@"content"];
        if([content isEqualToString:key]){
            newItem = item;
            break;
        }
    }
    NSString *currentDateString = [DateUtility formatDateWithString:[NSDate date] formatString: @"yyyy-MM-dd HH:mm:ss"];
    if(newItem != nil){
        [newItem setValue:currentDateString forKey:@"last_search_date"];
    } else {
        newItem = [[NSMutableDictionary alloc]initWithCapacity:2];
        [newItem setValue:key forKey:@"content"];
        [newItem setValue:currentDateString forKey:@"last_search_date"];
        if(historyArray.count >= LOCAL_KEYS_NUMBER){
            NSDate *minDate = [NSDate date];
            NSMutableDictionary *minItem;
            for(NSMutableDictionary *item in historyArray){
                NSString *dateString = [item objectForKey:@"last_search_date"];
                NSDate *date = [DateUtility dateFromFormatString:dateString formatString: @"yyyy-MM-dd HH:mm:ss"];
                if([date isEarlierThanDate:minDate]){
                    minDate = date;
                    minItem = item;
                }
            }
            [historyArray removeObject:minItem];
        }
        [historyArray addObject:newItem];
    }
    [[ContainerUtility sharedInstance]setAttribute:historyArray forKey:@"search_history"];
}

@end
