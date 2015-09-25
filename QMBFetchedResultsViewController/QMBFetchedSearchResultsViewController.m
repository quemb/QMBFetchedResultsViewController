//
//  QMBFetchedSearchResultsViewController.m
//  QMBFetchedResultsViewController Sample
//
//  Created by Toni Möckel on 18.05.14.
//  Copyright (c) 2014 Toni Möckel. All rights reserved.
//

#import "QMBFetchedSearchResultsViewController.h"
#import "QMBResultsViewController.h"

@interface QMBFetchedSearchResultsViewController ()<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>{
    NSArray *_filteredObjects;
    NSMutableDictionary *_filteredResults;
    UILabel *_noResultsLabel;
}

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) QMBResultsViewController *resultsTableController;

@end

@implementation QMBFetchedSearchResultsViewController

- (void)viewDidLoad
{
    
    _filteredResults = [NSMutableDictionary new];
    
    [super viewDidLoad];
    
    _resultsTableController = [[QMBResultsViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    self.resultsTableController.tableView.dataSource = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
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
    }else if (self.resultsTableController.tableView == tableView){
        return [_filteredObjects objectAtIndex:indexPath.row];
    }
    return nil;
}



#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
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
    
    [self.resultsTableController.tableView reloadData];
}



#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    [self filterContentForSearchText:searchText scope:searchController.searchBar.selectedScopeButtonIndex];
}





@end
