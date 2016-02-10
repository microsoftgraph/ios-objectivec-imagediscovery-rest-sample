/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "ImageFilterViewController.h"
#import "ImageResult.h"
#import "ImageSearchManager.h"
#import "ImageSearchViewController.h"
#import <UIImageView+AFNetworking.h>


@interface ImageSearchViewController () <UISearchBarDelegate>

@property (nonatomic, strong) NSArray *searchResult;
@property (nonatomic,strong) UISearchBar *searchBar;

@end

@implementation ImageSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchResult = [NSMutableArray new];

    [self addSearchBar];

    self.collectionView.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dismissKeyboard {
    [self.searchBar resignFirstResponder];
}

#pragma mark - setup
- (void)addSearchBar {

    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 44)];
    self.searchBar.searchBarStyle       = UISearchBarStyleMinimal;
    self.searchBar.tintColor            = [UIColor whiteColor];
    self.searchBar.barTintColor         = [UIColor whiteColor];
    self.searchBar.delegate             = self;
    self.searchBar.placeholder          = @"Search images from web";
    [self.view addSubview:self.searchBar];
    
}


#pragma mark - search delegates

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float length = (self.view.frame.size.width / 3) - 1;
    return CGSizeMake(length, length);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [ImageSearchManager searchForImage:searchBar.text completion:^(NSArray *result, NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:error.localizedDescription
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:true completion:nil];
            return;
        }
        
        self.searchResult = result;
        [self.collectionView reloadData];
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar endEditing:YES];
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    
    return YES;
}


#pragma mark - collection view
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //defaultCollectionView
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"defaultCollectionView" forIndexPath:indexPath];
    
    ImageResult *image = self.searchResult[indexPath.row];
    
    [((UIImageView*)[cell viewWithTag:101]) setImageWithURL:[NSURL URLWithString:image.thumbnailURLString]
                                           placeholderImage:[UIImage imageNamed:@"PlaceHolder"]];
    
    return cell;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.searchResult.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *thumbnail = ((UIImageView*)[[self.collectionView cellForItemAtIndexPath:indexPath] viewWithTag:101]).image;
    self.selectedImage = thumbnail;
    self.fullImageURLString = ((ImageResult*)self.searchResult[indexPath.row]).imageURLString;
    
    [self.parentViewController performSegueWithIdentifier:@"searchImageFilter" sender:nil];
    
    
}

@end
