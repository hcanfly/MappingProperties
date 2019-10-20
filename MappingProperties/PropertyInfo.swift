//
//  PropertyInfo.swift
//  TenX
//
//  Created by Gary on 3/14/17.
//  Copyright © 2019 Gary Hanson. All rights reserved.
//

import UIKit


final class PropertyInfoViewController: UIViewController, DisplayViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var propertyImages: DisplayPropertyImagesView!
    @IBOutlet weak var estimatedOpeningBidLabel: UILabel!
    @IBOutlet weak var estimatedUnpaidBalanceLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var numberOfBedsLabel: UILabel!
    @IBOutlet weak var numberOfBathsLabel: UILabel!
    @IBOutlet weak var sqFeetLabel: UILabel!
    
    var property: Property!
    
    
    override func viewDidLoad() {
        self.propertyImages.images = self.property.images
        
        self.propertyImages.setProperty(property: property)
        self.propertyImages.delegate = self
        
        let priceFormatter = NumberFormatter()
        priceFormatter.minimumFractionDigits = 2
        priceFormatter.maximumFractionDigits = 2
        priceFormatter.numberStyle = .currency
        let price = self.property.estimatedOpeningBid > 1.0 ? priceFormatter.string(for: self.property.estimatedOpeningBid)! : "\nTBD"
        let debt = self.property.totalEstimatedDebt > 1.0 ? priceFormatter.string(for: self.property.totalEstimatedDebt)! : "\nTBD"

        let sqFootFormatter = NumberFormatter()
        sqFootFormatter.minimumFractionDigits = 0
        sqFootFormatter.maximumFractionDigits = 0
        sqFootFormatter.numberStyle = .decimal
        let sqFeetString = sqFootFormatter.string(for: self.property.sqFeet)!

        let bathsFormatter = NumberFormatter()
        bathsFormatter.minimumFractionDigits = 0
        bathsFormatter.maximumFractionDigits = 1
        bathsFormatter.numberStyle = .decimal
        let bathsString = bathsFormatter.string(for: self.property.baths)!

        
        self.estimatedOpeningBidLabel.text = "Est Opening Bid: " + price
        self.estimatedUnpaidBalanceLabel.text = "Total Estimated Debt (Unpaid Balance + Fees): " + debt
        self.numberOfBedsLabel.text = String(self.property.beds)
        self.numberOfBathsLabel.text = bathsString
        self.sqFeetLabel.text = sqFeetString
        self.streetLabel.text = self.property.street
        self.cityStateLabel.text = self.property.city + ", " + self.property.state + "  " + self.property.zip + ", " + self.property.county
        
        if self.numberOfBedsLabel.frame.origin.y + (3 * self.numberOfBedsLabel.frame.size.height) > (self.scrollView.bounds.height - self.navigationController!.navigationBar.frame.height) {
            let extra = self.numberOfBedsLabel.frame.origin.y + (3 * self.numberOfBedsLabel.frame.size.height) - (self.scrollView.bounds.height - self.navigationController!.navigationBar.frame.height)
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.scrollView.bounds.height + extra)   //TODO: size properly. out of time now.
        }
    }
    
    func selected(propertyId: Int) {
        //TODO: display property images full screen
    }
}
