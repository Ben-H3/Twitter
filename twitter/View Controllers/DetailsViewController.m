//
//  DetailsViewController.m
//  twitter
//
//  Created by Benjamin Charles Hora on 6/30/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "DetailsViewController.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *handle;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UITextView *bodyText;

@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    User *user = self.tweet.user;
    
    NSString *stringURL = [user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    NSURL *imageURL = [NSURL URLWithString: stringURL];
    [self.profileImage setImageWithURL: imageURL];
    
    self.name.text = user.name;
    self.handle.text = [NSString stringWithFormat:@"@%@", user.screenName];
    self.bodyText.text = self.tweet.text;
    self.date.text = self.tweet.createdAtString;

    [self loadCounts];
}

- (void) loadCounts {
    if(self.tweet.favorited == YES) {
        UIImage *image = [UIImage imageNamed:@"favor-icon-red"];
        [self.favoriteButton setImage:image forState:UIControlStateNormal];
        
    } else {
        UIImage *image = [UIImage imageNamed:@"favor-icon"];
        [self.favoriteButton setImage:image forState:UIControlStateNormal];
    }
    if(self.tweet.retweeted == YES) {
        UIImage *image = [UIImage imageNamed:@"retweet-icon-green"];
        [self.retweetButton setImage:image forState:UIControlStateNormal];
    } else {
        UIImage *image = [UIImage imageNamed:@"retweet-icon"];
        [self.retweetButton setImage:image forState:UIControlStateNormal];
    }
    [self.retweetButton setTitle:([NSString stringWithFormat:@"%d", self.tweet.retweetCount]) forState:UIControlStateNormal];
    [self.favoriteButton setTitle:([NSString stringWithFormat:@"%d", self.tweet.favoriteCount]) forState:UIControlStateNormal];
}

- (IBAction)didTapFavorite:(id)sender {
    if (self.tweet.favorited == NO) {
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                 NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            }
            else{
                [self.tweet updateFavorite];
                [self loadCounts];
            }
        }];
    }
    else {
        [[APIManager shared] unfavorite:self.tweet completion:^(Tweet * tweet, NSError * error) {
            if(error){
                NSLog(@"Error unfavoriting tweet: %@", error.localizedDescription);
            }
            else {
                [self.tweet updateFavorite];
                [self loadCounts];
            }
        }];
    }
}

- (IBAction)didTapRetweet:(id)sender {
    if (self.tweet.retweeted == NO){
        [[APIManager shared] retweet:self.tweet completion:^(Tweet * tweet, NSError * error) {
            if(error){
                NSLog(@"Error retweeting tweet: %@", error.localizedDescription);
            }
            else {
                [self.tweet updateRetweet];
                [self loadCounts];
            }
        }];
    }
    else {
        [[APIManager shared] unretweet:self.tweet completion:^(Tweet * tweet, NSError * error) {
            if(error){
                NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
            }
            else {
                [self.tweet updateRetweet];
                [self loadCounts];
            }
        }];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
