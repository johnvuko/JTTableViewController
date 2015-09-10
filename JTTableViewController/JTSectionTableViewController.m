//
//  JTSectionTableViewController.m
//  JTTableViewController
//
//  Created by Sergey Demchenko on 9/10/15.
//

#import "JTSectionTableViewController.h"

@implementation JTSectionTableViewController

#pragma mark - JTTableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.haveMoreData && self.nextPageLoaderCell && self.results.count == section + 1) {
        return [self.results[section] count] + 1;
    }
    
    return [self.results[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.results.count != indexPath.section + 1) { return nil; }
    
    if (indexPath.row == [self.results[indexPath.section] count]) {
        return self.nextPageLoaderCell;
    } else if (!self.isLoading && indexPath.row >= [self.results[indexPath.section] count] - self.nextPageLoaderOffset && self.haveMoreData) {
        [self startFetchingNextResults];
    }
    
    return nil;
}

@end
