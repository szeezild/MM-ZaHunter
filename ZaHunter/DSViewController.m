//
//  DSViewController.m
//  ZaHunter
//
//  Created by Dan Szeezil on 3/28/14.
//  Copyright (c) 2014 Dan Szeezil. All rights reserved.
//

#import "DSViewController.h"

@interface DSViewController () <MKMapViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>

@property CLLocationManager *locationMgr;


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *myLabel;

@property BOOL userLocationUpdated;


@end


@implementation DSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationMgr = [CLLocationManager new];
    self.locationMgr.delegate = self;
    
    [self.locationMgr startUpdatingLocation];

    self.mapView.showsUserLocation = YES;

//    907 n winchester
    double lat = 41.898446;
    double lng = -87.675831;

//    Mobile Makers
//    double lat = 41.9937;
//    double lng = -87.6353;
    
    CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake(lat, lng);
    
    MKCoordinateSpan coordSpan = MKCoordinateSpanMake(.2, .2);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoord, coordSpan);
    self.mapView.region = region;
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            
            self.myLabel.text = @"Location Found.  Reverse Geocoding...";
            
            [self startReverseGeocoding:location];
            
            [self.locationMgr stopUpdatingLocation];
            break;
            
        }
    }
}


-(void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
 
    if (!self.userLocationUpdated) {
        [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
        self.userLocationUpdated = YES;
        
    }
    
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    
    pin.image = [UIImage imageNamed:@"pizzaIcon"];
    
    pin.canShowCallout = YES;
    
    return pin;
}


-(void)startReverseGeocoding:(CLLocation *)location {

    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        self.myLabel.text = [NSString stringWithFormat:@"%@", placemarks.firstObject];
        [self findPizza:placemarks.firstObject];
    }];

}


-(void)findPizza:(CLPlacemark *)placemark {
    
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"pizza";
    request.region = MKCoordinateRegionMake(placemark.location.coordinate, MKCoordinateSpanMake(0.3, 0.3));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        NSArray *mapItems = response.mapItems;
        MKMapItem *mapItem = mapItems.firstObject;
        self.myLabel.text = [NSString stringWithFormat:@"You should go to %@", mapItem.name];
        
        CLPlacemark *placemark = mapItem.placemark;
        
        MKPointAnnotation *annot = [MKPointAnnotation new];
        annot.coordinate = placemark.location.coordinate;
        annot.title = placemark.name;
        annot.subtitle = placemark.locality;
        [self.mapView addAnnotation:annot];
        
        
//        [self showDirections:mapItem];
        
    }];
    
}


//-(void)showDirections:(MKMapItem *)destinationMapItem {
//    
//    MKDirectionsRequest *request = [MKDirectionsRequest new];
//    request.source = [MKMapItem mapItemForCurrentLocation];
//    request.destination = destinationMapItem;
//    
//    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
//    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
//        MKRoute *route = response.routes.firstObject;
//        
////        self.myLabel.text = @"";
////        
////        for (MKRouteStep *step in route.steps) {
////            self.myLabel.text = [NSString stringWithFormat:@"%@\n%@", self.myLabel.text, step.instructions];
////        }
//        
//    }];
//}





//    CLGeocoder *geocoder = [CLGeocoder new];
//    [geocoder geocodeAddressString:@"willis tower" completionHandler:^(NSArray *placemarks, NSError *error) {
//        for (CLPlacemark *place in placemarks) {
//            MKPointAnnotation *annotation = [MKPointAnnotation new];
//            annotation.coordinate = place.location.coordinate;
//            [self.mapView addAnnotation:annotation];
//        }
//    }];


@end














