//
//  QMBFetchedResultsViewController.h
//  
//
//  Created by Toni Möckel on 21.11.12.
//  Copyright (c) 2012 Toni Möckel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface QMBFetchedResultsViewController : UIViewController<NSFetchedResultsControllerDelegate,  UITableViewDataSource, UITableViewDelegate,UISearchDisplayDelegate, UISearchBarDelegate>

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObject *managedObject;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (void) performFetch;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

- (id) objectAtIndexPath:(NSIndexPath *)indexPath;

//Abstract Mathods
- (NSString *) cellIdentifierForIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCellStyle) cellStyleForIndexPath:(NSIndexPath *) indexPath;

- (NSFetchRequest *) fetchRequest;
- (NSPredicate *) fetchPredicate;
- (NSString *) entityName;
- (NSArray *) sortDescriptors;
- (NSArray *) sortKeys;
- (NSString *) sectionKeyPath;
- (NSUInteger) sectionOffset;
- (NSUInteger) rowOffset;
- (NSString *) cacheName;
- (NSUInteger) fetchBatchSize;

@end
