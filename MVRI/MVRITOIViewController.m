//
//  MVRITOIViewController.m
//  MVRI
//
//  Created by Murali Gorantla on 02/10/15.
//  Copyright (c) 2015 mac. All rights reserved.
//

#import "MVRITOIViewController.h"
#import "SWRevealViewController.h"

@interface MVRITOIViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation MVRITOIViewController

#pragma mark - Life cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    UIImage *img = [UIImage imageNamed:@"focus"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    [imgView setImage:img];
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imgView;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)performMenuButtonAction:(id)sender {
    [self.revealViewController revealToggle:sender];
}


#pragma mark - Helper Methods

- (void)loadWebView {
    NSString *urlString = @"http://qa.focusvri.com/tos.html";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    [self.webView loadRequest:request];

}

#pragma mark - WebView Delegate Methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
