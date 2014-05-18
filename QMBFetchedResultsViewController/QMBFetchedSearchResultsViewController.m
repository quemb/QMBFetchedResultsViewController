//
//  QMBFetchedSearchResultsViewController.m
//  QMBFetchedResultsViewController Sample
//
//  Created by Toni Möckel on 18.05.14.
//  Copyright (c) 2014 Toni Möckel. All rights reserved.
//

#import "QMBFetchedSearchResultsViewController.h"

@interface QMBFetchedSearchResultsViewController () {
    NSArray *_filteredObjects;
    NSMutableDictionary *_filteredResults;
    UILabel *_noResultsLabel;
}

@end

@implementation QMBFetchedSearchResultsViewController

- (void)viewDidLoad
{
    
    _filteredResults = [NSMutableDictionary new];
    
    [super viewDidLoad];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.tableView)
    {
        return [super tableView:tableView numberOfRowsInSection:section];   
    }
    else
    {
        return [_filteredObjects count];
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:[self cellStyleForIndexPath:indexPath] reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell forTableView:tableView atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
    NSObject *object = [self objectAtIndexPath:indexPath forTableView:tableView];
    cell.textLabel.text = object.description;
    cell.detailTextLabel.text = object.description;
    
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    [self configureCell:cell forTableView:self.tableView atIndexPath:indexPath];
    
}

- (UITableViewCellStyle)cellStyleForIndexPath:(NSIndexPath *)indexPath withTableView:(UITableView *)tableView {
    if (self.tableView == tableView){
        return [super cellStyleForIndexPath:indexPath];
    }else {
        return UITableViewCellStyleDefault;
    }
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath withTableView:(UITableView *)tableView {
    if (self.tableView == tableView){
        return [super cellIdentifierForIndexPath:indexPath];
    }else {
        return @"SearchCell";
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    _filteredObjects = nil;
    _filteredResults = [NSMutableDictionary new];
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [super controllerWillChangeContent:controller];
}

- (id) objectAtIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *) tableView {
    if (self.tableView == tableView){
        return [self objectAtIndexPath:indexPath];
    }else if (self.searchDisplayController.searchResultsTableView == tableView){
        return [_filteredObjects objectAtIndex:indexPath.row];
    }
    return nil;
}

#pragma mark - Content Filtering

- (NSPredicate *)searchPredicateWithSearchText:(NSString *)searchText scope:(NSInteger)scope {
    // Implement in sub class
    return nil;
}

- (NSUInteger)noOfLettersInSearch
{
    return 0;
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSInteger)scope
{
    if ([searchText length] != 0 && [searchText length] >= [self noOfLettersInSearch])
    {
        _filteredObjects = [_filteredResults objectForKey:searchText];
        
        if (!_filteredObjects)
        {
            NSPredicate *predicate = [self searchPredicateWithSearchText:searchText scope:scope];
            
            for (NSString *cachedSearchText in [[_filteredResults allKeys] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"length" ascending:NO]]])
            {
                if ([searchText hasPrefix:cachedSearchText])
                {
                    _filteredObjects = [[_filteredResults objectForKey:cachedSearchText] filteredArrayUsingPredicate:predicate];
                    break;
                }
            }
            
            if (!_filteredObjects)
            {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                
                NSEntityDescription *entity = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:self.managedObjectContext];
                fetchRequest.entity = entity;
                
                fetchRequest.predicate = predicate;
                
                NSMutableArray *sortDescriptors = [NSMutableArray new];
                
                for (NSString *key in [self sortKeys])
                {
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
                    [sortDescriptors addObject:sortDescriptor];
                }
                
                if ([sortDescriptors count] > 0)
                    fetchRequest.sortDescriptors = [NSArray arrayWithArray:sortDescriptors];
                
                _filteredObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
            }
            
            [_filteredResults setObject:_filteredObjects forKey:searchText];
        }
        
        _noResultsLabel.text = @"No Results";
    }
    else
    {
        _filteredObjects = nil;
        
        _noResultsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Enter %d letters or more.", nil), [self noOfLettersInSearch]];
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}


#pragma mark - UISearchDisplayDelegate


- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    
}


- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    _filteredObjects = nil;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (!_noResultsLabel)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.001), dispatch_get_main_queue(), ^(void) {
            for (UIView *v in self.searchDisplayController.searchResultsTableView.subviews)
            {
                if ([v isKindOfClass: [UILabel class]] && [[(UILabel*)v text] isEqualToString:@"No Results"])
                {
                    _noResultsLabel = (UILabel *)v;
                    
                    if ([searchString length] < [self noOfLettersInSearch])
                    {
                        _noResultsLabel.text = [NSString stringWithFormat:@"Enter %d letters or more.", [self noOfLettersInSearch]];
                    }
                    
                    break;
                }
            }
        });
    }
    
    [self filterContentForSearchText:searchString
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]
                               scope:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    return YES;
}




@end
