//
//  QMBFetchedResultsViewController.h
//  Bautagebuch
//
//  Created by Toni Möckel on 21.11.12.
//  Copyright (c) 2012 Toni Möckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMBFetchedResultsViewController : UIViewController<NSFetchedResultsControllerDelegate,  UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObject *managedObject;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

- (NSFetchRequest *) getFetchRequest;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;



//Abstract Mathods
- (NSString *) getSectionKeyPath;

@end
