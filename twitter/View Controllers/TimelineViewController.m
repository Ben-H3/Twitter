//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "ComposeViewController.h"
#import "DetailsViewController.h"
#import "APIManager.h"
#import "TweetCell.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "InfiniteScrollActivityView.h"

@interface TimelineViewController () <ComposeViewControllerDelegate, TweetDetailViewControllerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (strong, nonatomic) InfiniteScrollActivityView *activityIndicator;

@end

@implementation TimelineViewController

bool isMoreDataLoading = NO;
InfiniteScrollActivityView* loadingMoreView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Set up refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    
    // Set up Infinite Scroll loading indicator
    CGRect frame = CGRectMake(0,
                                self.tableView.contentSize.height,
                                self.tableView.bounds.size.width,
                                [InfiniteScrollActivityView defaultHeight]);
    self.activityIndicator = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.activityIndicator.hidden = YES;
    [self.tableView addSubview:self.activityIndicator];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.tableView.contentInset = insets;
    
    // Set up tweet array
    self.tweets = [[NSMutableArray alloc] init];
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            self.tweets = tweets;
            [self.tableView reloadData];
            
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
}

-(void) beginRefresh: (UIRefreshControl *) refreshControl {
    // Reload tweets when refresh
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            self.tweets = tweets;
            [self.tableView reloadData];
            
            [refreshControl endRefreshing];
            
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
    
}


- (IBAction)logout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    [[APIManager shared] logout];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    Tweet *tweet = self.tweets[indexPath.row];
    cell.tweet = tweet;
    [cell loadTweet];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isMoreDataLoading) {
        int totalContentHeight = self.tableView.contentSize.height;
        int oneScreenHeight = self.tableView.bounds.size.height;
        int scrollViewOffsetThreshold = totalContentHeight - oneScreenHeight;
        if (scrollView.contentOffset.y > scrollViewOffsetThreshold && self.tableView.isDragging) {
            
            // update position of loading wheel and animate
            CGRect frame = CGRectMake(0,
                                      self.tableView.contentSize.height,
                                      self.tableView.bounds.size.width,
                                      [InfiniteScrollActivityView defaultHeight]);
            self.activityIndicator.frame = frame;
            [self.activityIndicator startAnimating];
            
            self.isMoreDataLoading = YES;
            Tweet *lastTweet = self.tweets[self.tweets.count - 1];
            NSString *lastTweetID = lastTweet.idStr;
            [[APIManager shared] getHomeTimelineTweetsOlderThan:lastTweetID
                                                 withCompletion:^(NSArray *newTweets, NSError *error) {
                if (error) {
                    NSLog(@"Error getting older home timeline: %@", error.localizedDescription);
                }
                else {
                    self.tweets = [self.tweets arrayByAddingObjectsFromArray:newTweets];
                    [self.activityIndicator stopAnimating];
                    self.isMoreDataLoading = NO;
                    [self.tableView reloadData];
                }
            }];
        }
    }
}

-(void)didTweet:(Tweet *)tweet{
    [self.tweets insertObject:tweet atIndex:0];
    [self.tableView reloadData];
}

- (void) updateCell:(TweetCell *)cell{
    [cell loadTweet];
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[DetailsViewController class]]) {
        TweetCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        DetailsViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.tweet = self.tweets[indexPath.row];
        detailsViewController.cell = tappedCell;
        detailsViewController.delegate = self;
    }
    else {
        UINavigationController *navController = [segue destinationViewController];
        ComposeViewController *composeViewController = (ComposeViewController*)navController.topViewController;
        composeViewController.delegate = self;
        if ([segue.identifier isEqualToString:@"reply"]) {
            composeViewController.reply = YES;
            for (Tweet* tweet in self.tweets) {
                if (tweet.replyClicked == YES) {
                    composeViewController.tweet = tweet;
                }
            }
        }
        else {
            composeViewController.reply = NO;
        }
    }
}

@end
