//
//  JTTableViewController.m
//  JTTableViewController
//
//  Created by Jonathan Tribouharet
//

#import "JTTableViewController.h"

#import "Masonry.h"

@implementation JTTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    self->_isLoading = NO;
    self->_haveMoreData = NO;
    self->_results = [NSMutableArray new];
    self.nextPageLoaderOffset = 3;

    self.tableView = [UITableView new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // If startFetchingResults was called before the view exist
    if(self.results.count == 0 && self.isLoading){
        [self showNoResultsLoadingView];
    }
}

- (void)resetData
{
    self->_isLoading = NO;
    self->_haveMoreData = NO;
    [self.results removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - TableView

- (void)setTableView:(UITableView *)tableView
{
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:nil];
    
    self->_tableView = tableView;
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.haveMoreData && self.nextPageLoaderCell){
        return [self.results count] + 1;
    }
    
    return [self.results count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == [self.results count]){
        return CGRectGetHeight(self.nextPageLoaderCell.frame);
    }

    return [self jt_tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == [self.results count]){
        return self.nextPageLoaderCell;
    }
    else if(!self.isLoading && indexPath.row >= self.results.count - self.nextPageLoaderOffset && self.haveMoreData){
        [self startFetchingNextResults];
    }
    
    return [self jt_tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - NoResultsView

- (void)setNoResultsView:(UIView *)noResultsView
{
    NSAssert(self.tableView, @"You have to set the tableView first");

    self->_noResultsView = noResultsView;
    [self.tableView.superview addSubview:self.noResultsView];
    
    [self.noResultsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.tableView);
    }];
    
    self.noResultsView.hidden = YES;
    
    // Avoid noResultsView to block touch for the refresh control
    self.noResultsView.userInteractionEnabled = NO;
}

- (void)showNoResultsView
{
    self.noResultsView.hidden = NO;
}

- (void)hideNoResultsView
{
    self.noResultsView.hidden = YES;
}

#pragma mark - NoResultsLoadingView

- (void)setNoResultsLoadingView:(UIView *)noResultsLoadingView
{
    NSAssert(self.tableView, @"You have to set the tableView first");
    
    self->_noResultsLoadingView = noResultsLoadingView;
    [self.tableView.superview addSubview:self.noResultsLoadingView];
    
    [self.noResultsLoadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.tableView);
    }];
    
    self.noResultsLoadingView.hidden = YES;
}

- (void)showNoResultsLoadingView
{
    self.noResultsLoadingView.hidden = NO;
}

- (void)hideNoResultsLoadingView
{
    self.noResultsLoadingView.hidden = YES;
}

#pragma mark - Fetch results

- (void)didFetchResults:(NSArray *)results haveMoreData:(BOOL)haveMoreData
{
    self->_isLoading = NO;
    [self endRefreshing];
    [self hideNoResultsLoadingView];
    
    [self.results removeAllObjects];
    [self.results addObjectsFromArray:results];
        
    self->_haveMoreData = haveMoreData;
    [self.tableView reloadData];
    
    if(self.results.count == 0){
        [self showNoResultsView];
    }
}

- (void)didFetchNextResults:(NSArray *)results haveMoreData:(BOOL)haveMoreData
{
    self->_isLoading = NO;
    [self endRefreshing];
    [self hideNoResultsLoadingView];
    
    [self.results addObjectsFromArray:results];
    self->_haveMoreData = haveMoreData;
    [self.tableView reloadData];
}

- (void)didFailedToFetchResults
{
    self->_isLoading = NO;
    [self endRefreshing];
    [self hideNoResultsLoadingView];
}

- (void)startFetchingResults
{    
    self->_isLoading = YES;
    [self hideNoResultsView];
    
    if(self.results.count == 0){
        [self showNoResultsLoadingView];
    }
}

- (void)startFetchingNextResults
{
    self->_isLoading = YES;
    [self hideNoResultsView];
}

- (void)endRefreshing
{
    
}

#pragma mark - Swift compat

- (CGFloat)jt_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)jt_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
