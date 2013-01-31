//
//  AmberWavesViewController.m
//  AmberWaves

//  Description: demonstrate reading the content of a single Amber Waves article on the iPad
//  Notes: difficult to extract a sub-set of the content; authors not returned correctly

//  Created by Dina Li on 1/30/13.
//  Copyright (c) 2013 USDA ERS. All rights reserved.
//

#import "AmberWavesViewController.h"

@interface AmberWavesViewController ()

@end

@implementation AmberWavesViewController

@synthesize headerImageView = _headerImageView;
@synthesize titleLabel = _titleLabel;
@synthesize contentWebView = _contentWebView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_queue_t kBgQueue = dispatch_get_global_queue(
                                                          DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSURL *url = [NSURL URLWithString:@"http://api.ers.usda.gov/REST/v1/amberwaves/details/33942"]; // hard coded!!
    // NSURL *url = [NSURL URLWithString:@"http://api.ers.usda.gov/REST/v1/charts/mostrecent/3/"];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        url];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
}

/* Description:
// there is a top level Dictionary each item in the array represents one article below that, there is a Properties Array
 */

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    
    NSDictionary *jsonDictionary = [NSJSONSerialization
                                    JSONObjectWithData:responseData
                                    options:kNilOptions
                                    error:&error];

    NSUInteger i = 0;
    NSUInteger records = [jsonDictionary count];
    NSString *item, *title, *url, *description, *content, *authors = nil;
    
    @try {
     NSArray *propertiesArray;
        
        // array of dictionaries within the big json array
        for (i = 0; i < records; i++)
        {
                for (item in jsonDictionary)
                {
                    title = [jsonDictionary objectForKey: @"Title"];
                    url = [jsonDictionary objectForKey: @"Url"];
                    //releaseDate = [jsonDictionary objectForKey: @"ReleaseDate"];
                    
                    if([item isEqualToString:@"Properties"])
                    {
                        propertiesArray = [jsonDictionary objectForKey:@"Properties"];
                        
                        if(propertiesArray.count > 0) // get the sub-dictionary that contains the description
                        {
                            // loop thru the Array and find the dictionary with the description keyField
                            NSUInteger g = 0;
                            
                            for(g =0; g<propertiesArray.count; g++)
                            {
                                NSDictionary *descriptionDictionary = [propertiesArray objectAtIndex:g];
                                
                                // ALERT: !! strange format: keyfield:description; propertyValueField: the text description
                                if([[descriptionDictionary objectForKey:@"keyField"] isEqualToString:@"contents"])
                                {
                                    content = [descriptionDictionary objectForKey:@"propertyValueField"];
                                    //NSLog(@"contents = %@", content);
                                }
                                else if([[descriptionDictionary objectForKey:@"keyField"] isEqualToString:@"description"])
                                {
                                    description = [descriptionDictionary objectForKey:@"propertyValueField"];
                                    //NSLog(@"contents = %@", description);
                                }
                                
                                // authors is formatted HTML
                                else if([[descriptionDictionary objectForKey:@"keyField"] isEqualToString:@"authors"])
                                {
                                    authors = [descriptionDictionary objectForKey:@"propertyValueField"];
                                   // NSLog(@"contents = %@", authors);
                                }
                                
                            } // end for g
                        } // if arraycount > 0
                    } // if Properties
                } // for items
        } // end for
    }
    @catch (NSException *exception) {
        NSLog(@"error loading objects %@", exception);
    }
    @finally {
        // how to terminate here?
    }
    
    //////////////////////////////////
    /* display variables on UIView */
    /////////////////////////////////
    
    // NOTE: the formatting of the Authors in the API doesn't appear to work; <relations><relation id="304570" typeId="21" parentId="33942" createDate="05/12/2012 14:11:03" comment="Relating Concentration of Poverty to Poverty & Income Volatility." />
    // append the authors to the content so that the HTML formatting is preserved
  
    NSString *contentFinal = [NSString stringWithFormat:@"%@/%@", authors, content];
   // NSLog(@"final content %@ = ", contentFinal);
    
    _titleLabel.text = title;
    
    // create the HTML for the webView
    
    NSString *myDescriptionHTML = [NSString stringWithFormat:@"<html> \n"
                                   "<head> \n"
                                   "<style type=\"text/css\"> \n"
                                   "body {font-family: \"%@\"; font-size: %@; margin: %@%@ %@%@ %@%@ %@%@;}\n"
                                   "</style> \n"
                                   "</head> \n"
                                   "<body>%@</body> \n"
                                   "</html>", @"helvetica", [NSNumber numberWithInt:17],  [NSNumber numberWithInt:10], @"px", [NSNumber numberWithInt:10], @"px", [NSNumber numberWithInt:10], @"px", [NSNumber numberWithInt:10], @"px", contentFinal ];
    
    // NSLog(@"descriptionHTML = %@", myDescriptionHTML);
    NSString *urlAddress = @"http://www.ers.usda.gov/"; // need a url to get the webview to display!
    NSURL *urlBase = [NSURL URLWithString:urlAddress];
    
    [_contentWebView loadHTMLString:myDescriptionHTML baseURL:urlBase];
}

#pragma mark - date formatter

// not currently used, but it works
/* incoming date is the one that needs formatting */
- (NSString*) formatDate:(NSString*)unformattedDateString
{
    NSString *outputDateString = nil;
    
    if(unformattedDateString !=nil)
    {
        NSString *dateString = unformattedDateString;
        
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        [inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateStyle:NSDateFormatterMediumStyle];
        [outputFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        NSDate *date = [inputFormatter dateFromString:dateString];
        
        //this will set date's time components to 00:00
        [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
                                        startDate:&date
                                         interval:NULL
                                          forDate:date];
        
        outputDateString = [outputFormatter stringFromDate:date];
    }
    else
    {
        NSLog(@"incoming date was nil");
    }
    return outputDateString;
}

- (void)viewDidUnload
{
    [self setContentWebView:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

 #pragma mark - retrieve image
 /* TODO: this should be done on a background thread in case the image is slow or bombs */
//- (UIImage*) loadImage:(NSString*)urlForImageString
//{
//    NSData * imageData = nil;
//    UIImage * image = nil;
//
//    NSString *urlPath = @"http://www.ers.usda.gov";
//
//    NSMutableString *fullURL;
//
//    if (fullURL == nil){
//        fullURL = [[NSMutableString alloc] init];
//    }
//
//    [ fullURL appendString: urlPath];
//    [ fullURL appendString: urlForImageString];
//
//    NSURL *imageURL = [NSURL URLWithString:fullURL];
//
//    @try {
//        imageData = [NSData dataWithContentsOfURL:imageURL];
//        image = [UIImage imageWithData:imageData];
//    }
//    @catch (NSException *exception) {
//        NSLog(@"crashed loading the image = %@", exception);
//    }
//    @finally {
//        //<#statements#>
//    }
//
//    return image;
//}

// debugging code
/*
 id key = nil;
 NSString *value = nil;
 
 for (key in jsonDictionary) //WORKS IF ITS A DICTIONARY
 {
 value = [jsonDictionary objectForKey: key];
 NSLog(@"json dictionary value = %@", value); // value is NULL
 NSLog(@"json dictionary key = %@", key);
 }
 */

@end
