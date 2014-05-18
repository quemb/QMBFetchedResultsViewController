//
//  QMBFetchedSearchResultsViewController.h
//  QMBFetchedResultsViewController Sample
//
//  Created by Toni Möckel on 18.05.14.
//  Copyright (c) 2014 Toni Möckel. All rights reserved.
//

#import "QMBFetchedResultsViewController.h"

@interface QMBFetchedSearchResultsViewController : QMBFetchedResultsViewController

- (id) objectAtIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *) tableView;
- (NSString *) cellIdentifierForIndexPath:(NSIndexPath *)indexPath withTableView:(UITableView *) tableView;
- (UITableViewCellStyle) cellStyleForIndexPath:(NSIndexPath *) indexPath withTableView:(UITableView *) tableView;
- (void)filterContentForSearchText:(NSString *)searchText scope:(NSInteger)scope;
- (void)configureCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;


- (NSPredicate *)searchPredicateWithSearchText:(NSString *)searchText scope:(NSInteger)scope;
- (NSUInteger)noOfLettersInSearch;

@end
