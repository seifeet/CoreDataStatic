//
//  SFViewController.m
//  SFTwoButtonLayout
//
//  Created by Flavius on 7/31/14.
//  Copyright (c) 2014 SF. All rights reserved.
//

#import "SFViewController.h"

#import "../../SFDataStore/SFDataStore/MOCustomer.h"
#import "../../SFDataStore/SFDataStore/DataManager.h"

@interface SFViewController ()

@end

@implementation SFViewController

- (void)viewDidLoad
{
    self.helloButton.backgroundColor = [UIColor lightGrayColor];
    self.thereButton.backgroundColor = [UIColor lightGrayColor];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)helloClicked:(id)sender
{
    // create a new customer
    MOCustomer *customer = (MOCustomer *)[NSEntityDescription insertNewObjectForEntityForName:@"Customer"
                                                                                inManagedObjectContext:defaultManagedObjectContext()];

    customer.first_name = [[NSUUID UUID] UUIDString]; 
    customer.last_name = [[NSUUID UUID] UUIDString];

    // save changes
    commitDefaultMOC();

    // fetch a customer
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"last_name" ascending:YES]];

    MOCustomer *customerFetched = (MOCustomer *)fetchManagedObject(@"Customer", nil, sortDescriptors, defaultManagedObjectContext());

    NSLog(@" first name: %@, last name: %@", customerFetched.first_name, customer.last_name);

}

- (IBAction)thereClicked:(id)sender
{
}

@end
