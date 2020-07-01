//
//  TweetCell.m
//  twitter
//
//  Created by Benjamin Charles Hora on 6/29/20.
//  Copyright © 2020 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"
#import "Tweet.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) loadTweet {
    User *user = self.tweet.user;
    // Set image
    NSString *stringURL = [user.profileImageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
    NSURL *imageURL = [NSURL URLWithString: stringURL];
    [self.profileImage setImageWithURL: imageURL];
    // Set labels
    self.name.text = user.name;
    self.bodyText.text = self.tweet.text;
    self.handle.text = [NSString stringWithFormat:@"@%@", user.screenName];
    self.date.text = self.tweet.createdAtString;
    self.retweetCount.text = [NSString stringWithFormat:@"%d", self.tweet.retweetCount];
    self.favoriteCount.text = [NSString stringWithFormat:@"%d", self.tweet.favoriteCount];
    // Set buttons
    if(self.tweet.favorited) {
        UIImage *image = [UIImage imageNamed:@"favor-icon-red"];
        [self.favoriteButton setImage:image forState:UIControlStateNormal];
        
    } else {
        UIImage *image = [UIImage imageNamed:@"favor-icon"];
        [self.favoriteButton setImage:image forState:UIControlStateNormal];
    }
    if(self.tweet.retweeted) {
        UIImage *image = [UIImage imageNamed:@"retweet-icon-green"];
        [self.retweetButton setImage:image forState:UIControlStateNormal];
    } else {
        UIImage *image = [UIImage imageNamed:@"retweet-icon"];
        [self.retweetButton setImage:image forState:UIControlStateNormal];
    }
    
}

- (IBAction)didTapFavorite:(id)sender {
    // Update the local tweet model
    [self.tweet updateFavorite];
    // Update cell UI
    [self loadTweet];
    // Send a POST request to the POST favorites/create endpoint
    if (self.tweet.favorited) {
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                 NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            }
            else{
                NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
            }
        }];
    }
    else {
        [[APIManager shared] unfavorite:self.tweet completion:^(Tweet * tweet, NSError * error) {
            if(error){
                NSLog(@"Error unfavoriting tweet: %@", error.localizedDescription);
            }
            else {
                NSLog(@"Successfully unfavorited the following Tweet: %@", tweet.text);
            }
        }];
    }
}

- (IBAction)didTapRetweet:(id)sender {
    // Update the local tweet model
    [self.tweet updateRetweet];
    // Update cell UI
    [self loadTweet];
    // Send a POST request to the POST favorites/create endpoint
    if (self.tweet.retweeted){
        [[APIManager shared] retweet:self.tweet completion:^(Tweet * tweet, NSError * error) {
            if(error){
                NSLog(@"Error retweeting tweet: %@", error.localizedDescription);
            }
            else {
                NSLog(@"Successfully retweeted the following Tweet: %@", tweet.text);
            }
        }];
    }
    else {
        [[APIManager shared] unretweet:self.tweet completion:^(Tweet * tweet, NSError * error) {
            if(error){
                NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
            }
            else {
                NSLog(@"Successfully unretweeting the following Tweet: %@", tweet.text);
            }
        }];
    }
}

@end
