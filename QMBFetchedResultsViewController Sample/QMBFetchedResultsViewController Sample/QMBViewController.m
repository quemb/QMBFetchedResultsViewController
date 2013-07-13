//
//  QMBViewController.m
//  QMBFetchedResultsViewController Sample
//
//  Created by Toni Möckel on 13.07.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "QMBViewController.h"

#import "Sample.h"
#import "QMBAppDelegate.h"

@interface QMBViewController ()

@end

@implementation QMBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Sample Data Import
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"SampleData" ofType:@"plist"];
    NSArray *contentArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    for (NSDictionary *dict in contentArray) {
        Sample *sample = [NSEntityDescription insertNewObjectForEntityForName:@"Sample" inManagedObjectContext:self.managedObjectContext];
        [sample setValuesForKeysWithDictionary:dict];
        
    }
    
}

#pragma mark - QMBFetchedResultController Overrides

- (NSManagedObjectContext *)managedObjectContext
{
    return [((QMBAppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContext];
}

- (NSFetchRequest *)getFetchRequest
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Sample" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:
                                      [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES],
                                      nil]];
    
    return fetchRequest;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Sample *sample = (Sample *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = sample.title;
    cell.detailTextLabel.text = sample.subtitle;
}

@end
