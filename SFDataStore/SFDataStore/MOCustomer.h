//
//  MOCustomer.h
//  SFDataStore
//
//  Created by Flavius on 8/13/14.
//  Copyright (c) 2014 SF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MOCustomer : NSManagedObject

@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;

@end
