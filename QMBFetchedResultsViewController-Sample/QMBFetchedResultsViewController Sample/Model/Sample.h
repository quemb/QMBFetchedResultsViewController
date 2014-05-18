//
//  Sample.h
//  QMBFetchedResultsViewController Sample
//
//  Created by Toni Möckel on 13.07.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Sample : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;

@end
