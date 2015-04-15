//
//  ViewController.m
//  Example
//
//  Created by Jonathan Tribouharet
//

#import "ViewController.h"

#import "FakeService.h"

@interface ViewController (){
    FakeService *service;
    UIRefreshControl *refreshControl;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    service = [FakeService new];
    
    // Optional
    // Don't display empty cells
    self.tableView.tableFooterView = [UIView new];
    
    // One of the many way to determine the cell for a tableView
    // The tableView is bind to the controller directly in the storyboard, no need to set the delegate and the dataSource
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    
    // Optional
    // Add a refresh control
    refreshControl = [UIRefreshControl new];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(startFetchingResults) forControlEvents:UIControlEventValueChanged];
    
    // Optional
    // Load nextPageLoaderCell, this view is bind to the controller directly in the nib
    [[NSBundle mainBundle] loadNibNamed:@"NextPageLoaderCell" owner:self options:nil];
    
    // Optional
    // Load noResultsView, this view is bind to the controller directly in the nib
    [[NSBundle mainBundle] loadNibNamed:@"NoResultsView" owner:self options:nil];
    
    // Optional
    // Load noResultsLoadingView, this view is bind to the controller directly in the nib
    [[NSBundle mainBundle] loadNibNamed:@"NoResultsLoadingView" owner:self options:nil];
}

- (void)viewDidAppear:(BOOL)animated
{    
    [super viewDidAppear:animated];
    
    // Start fetching data when the viewController appear
    [self startFetchingResults];
}

// If you don't implement this method UITableViewAutomaticDimension will return by default
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Automatically return the height of nextPageLoaderCell, by default use UITableViewAutomaticDimension
    JTTABLEVIEW_heightForRowAtIndexPath
    
    return 44.;
}

// Must be implemented
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Automatically return nextPageLoaderCell and call startFetchingNextResults if needed
    JTTABLEVIEW_cellForRowAtIndexPath
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Do whatever you want to use the data
    cell.textLabel.text = self.results[indexPath.row];
    
    return cell;
}

// Must be implemented
- (void)startFetchingResults
{
    [super startFetchingResults];
    
    [service retrieveDataWithOffset:0 success:^(NSArray *results, BOOL haveMoreData) {
        [self didFetchResults:results haveMoreData:haveMoreData];
    } failure:^{
        [self didFailedToFetchResults];
    }];
    
// Use this to test noResultsView
//
//    [service retrieveNoDataWithOffset:0 success:^(NSArray *results, BOOL haveMoreData) {
//        [self didFetchResults:results haveMoreData:haveMoreData];
//    } failure:^{
//        [self didFailedToFetchResults];
//    }];
}

// Must be implemented
- (void)startFetchingNextResults
{
    [super startFetchingNextResults];
    
    [service retrieveDataWithOffset:self.results.count success:^(NSArray *results, BOOL haveMoreData) {
        [self didFetchNextResults:results haveMoreData:haveMoreData];
    } failure:^{
        [self didFailedToFetchResults];
    }];
}

// Optional to implement, only if you use a refresh control
- (void)endRefreshing
{
    [refreshControl endRefreshing];
}

@end
