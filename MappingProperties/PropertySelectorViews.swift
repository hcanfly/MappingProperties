//
//  PropertySelectorViews.swift
//  TenX
//
//  Created by Gary on 3/12/17.
//  Copyright © 2019 Gary Hanson. All rights reserved.
//

import UIKit


protocol DisplayViewDelegate : NSObjectProtocol {
    func selected(propertyId: Int)
}

fileprivate extension Selector {
    static let viewTapped = #selector(DisplayView.handleTap)
}

enum TitleType {
    case header
    case label
}


class DisplayView : UIView, UIScrollViewDelegate {
    
    var titleView: UIView?
    var titleLabel: UILabel?
    var imagesScrollView: UIScrollView!
    var images = [UIImage]()
    var properties = [Property]()
    var headerHeight: CGFloat = 0.0
    let displayFontName = "HelveticaNeue"
    weak var scrollViewDelegate: UIScrollViewDelegate?
    weak var delegate: DisplayViewDelegate?
    
    
    func initializeDataAndScrollview(properties: [Property]) {

        self.properties = properties
        self.loadImages()
        
        self.imagesScrollView = UIScrollView(frame: CGRect(x: 0, y: self.headerHeight, width: self.frame.size.width, height: self.frame.size.height - self.headerHeight))
        self.imagesScrollView.backgroundColor = .black
        self.imagesScrollView.isPagingEnabled = true
        self.imagesScrollView.delegate = self
        self.imagesScrollView.isDirectionalLockEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: .viewTapped)
        self.imagesScrollView.gestureRecognizers?.append(tapGesture)
        var imageFrame = self.imagesScrollView.frame
        imageFrame.origin.y = 0
        for index in 0..<self.images.count {
            imageFrame.origin.x = self.imagesScrollView.frame.width * CGFloat(index)
            let imageView = UIImageView(frame: imageFrame)
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill        // grabbed images from the website and they're not scaled for iphone and not going to take the time to resize them
            imageView.image = self.images[index]
            
            self.addData(to: imageView, propertyIndex: index)
            self.imagesScrollView.addSubview(imageView)
        }
        self.imagesScrollView.contentSize = CGSize(width: self.frame.width * CGFloat(self.images.count), height: self.frame.height)
        
        self.addSubview(self.imagesScrollView)
    }
    
    @objc func handleTap() {
    }
    
    func loadImages() {
    }
    
    func addData(to imageView: UIImageView, propertyIndex: Int) {
    }
    
    fileprivate var currentPage: Int {
        
        return Int((self.imagesScrollView.contentOffset.x + (0.5 * self.imagesScrollView.frame.size.width))/self.imagesScrollView.frame.width) + 1
    }
    
    //MARK: scrollview delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard self.images.count > 1 else {
            return
        }
        
        self.titleLabel!.text = "\(self.currentPage) of \(self.images.count)"
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
        }
    }
    
    //MARK: other inits
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// images scrollview displayed in map
final class DisplayPropertiesView: DisplayView {
    
    convenience init(frame: CGRect, properties: [Property]) {
        self.init(frame: frame)
        
        self.headerHeight = properties.count > 1 ? 18.0 : 0
        self.initializeDataAndScrollview(properties: properties)
        self.finalizeInit()
    }
    
    func finalizeInit() {
        
        if self.images.count > 1 {
            self.titleView = UIView(frame: CGRect(x: self.frame.origin.x, y: CGFloat(0), width: self.frame.size.width, height: self.headerHeight))

            self.titleView!.backgroundColor = .gray
            self.titleView!.alpha = 0.8
            self.titleLabel = UILabel(frame: self.titleView!.frame)
            self.titleLabel!.backgroundColor = .clear
            self.titleLabel!.textColor = .white
            self.titleLabel!.text = "1 of \(self.images.count)"
            self.titleLabel!.textAlignment = .center
            self.titleLabel!.font = UIFont(name: self.displayFontName, size: 12.0)
            self.titleView!.addSubview(self.titleLabel!)
            self.addSubview(self.titleView!)
        }
    }
    
    
    override func loadImages() {
        for counter in 0..<self.properties.count {
            if self.properties[counter].images.count > 0 {
                self.images.append(self.properties[counter].images[0])
            }
        }
        self.images = images
    }
    
    // user selected a property. display it's info page
    override func handleTap() {
        let currentPage = Int((self.imagesScrollView.contentOffset.x + (0.5 * self.imagesScrollView.frame.size.width))/self.imagesScrollView.frame.width) + 1
        
        self.delegate?.selected(propertyId: self.properties[currentPage - 1].propertyId)
    }
    
    override func addData(to imageView: UIImageView, propertyIndex: Int) {
        let p = self.properties[propertyIndex]
        let halfWidth = imageView.frame.width * 0.5
        
        var fr = CGRect(x: 6.0, y: imageView.frame.height - 60.0, width: halfWidth, height: 16.0)
        let addrLabel = UILabel(frame: fr)
        addrLabel.backgroundColor = .clear
        addrLabel.textColor = .white
        addrLabel.text = p.street.uppercased()
        addrLabel.font = UIFont(name: self.displayFontName, size: 14.0)
        imageView.addSubview(addrLabel)
        
        fr = fr.offsetBy(dx: 0.0, dy: 18.0)
        let cityStateLabel = UILabel(frame: fr)
        cityStateLabel.backgroundColor = .clear
        cityStateLabel.textColor = .white
        cityStateLabel.text = p.city.uppercased() + ", " + (imageView.frame.width > 400.0 ? p.state : "CA")      // hack, because I don't want to measure each time. I don't know what the real data is like. Can measure if necessary
        cityStateLabel.font = UIFont(name: self.displayFontName, size: 14.0)
        imageView.addSubview(cityStateLabel)
        
        let sqFootFormatter = NumberFormatter()
        sqFootFormatter.minimumFractionDigits = 0
        sqFootFormatter.maximumFractionDigits = 0
        sqFootFormatter.numberStyle = .decimal
        fr = fr.offsetBy(dx: 0.0, dy: 18.0)
        let bedsSqFeetLabel = UILabel(frame: fr)
        bedsSqFeetLabel.backgroundColor = .clear
        bedsSqFeetLabel.textColor = .white
        let sqFeetString = sqFootFormatter.string(for: p.sqFeet)!
        bedsSqFeetLabel.text = "\(p.beds) Beds, \(sqFeetString) Sq.Feet"
        bedsSqFeetLabel.font = UIFont(name: self.displayFontName, size: 14.0)
        imageView.addSubview(bedsSqFeetLabel)
        
        var rightColumn = CGRect(x: halfWidth - 6.0, y: imageView.frame.height - 60.0, width: halfWidth, height: 10.0)
        let estOpenLabel = UILabel(frame: rightColumn)
        estOpenLabel.backgroundColor = .clear
        estOpenLabel.textAlignment = .right
        estOpenLabel.textColor = .white
        estOpenLabel.text = "Est. Opening Bid"      //TODO: localize strings
        estOpenLabel.font = UIFont(name: self.displayFontName, size: 8.0)
        imageView.addSubview(estOpenLabel)
        
        rightColumn = rightColumn.offsetBy(dx: 0.0, dy: 36.0)
        let liveAuctionLabel = UILabel(frame: rightColumn)
        liveAuctionLabel.backgroundColor = .clear
        liveAuctionLabel.textAlignment = .right
        liveAuctionLabel.textColor = .white
        liveAuctionLabel.text = "Live Auction: Apr 05"
        liveAuctionLabel.font = UIFont(name: self.displayFontName, size: 8.0)
        imageView.addSubview(liveAuctionLabel)
        
        let priceFormatter = NumberFormatter()
        priceFormatter.minimumFractionDigits = 2
        priceFormatter.maximumFractionDigits = 2
        priceFormatter.numberStyle = .currency
        rightColumn = rightColumn.offsetBy(dx: 0.0, dy: -26.0)
        rightColumn.size.height = 26.0
        let openingBidLabel = UILabel(frame: rightColumn)
        liveAuctionLabel.backgroundColor = .clear
        openingBidLabel.textAlignment = .right
        openingBidLabel.textColor = .white
        let price = p.estimatedOpeningBid > 1.0 ? priceFormatter.string(for: p.estimatedOpeningBid)! : "TBD"
        openingBidLabel.text = "\(price)"
        openingBidLabel.font = UIFont(name: self.displayFontName, size: 20.0)
        imageView.addSubview(openingBidLabel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


// images in stackview
final class DisplayPropertyImagesView: DisplayView {
    
    convenience init(frame: CGRect, properties: [Property]) {
        self.init(frame: frame)
        
        self.initializeDataAndScrollview(properties: properties)
        self.finalizeInit()
    }
    
    func finalizeInit() {
        
        if self.images.count > 1 {
            self.titleView = UIView(frame: CGRect(x: self.frame.width - 70.0, y: 20.0, width: 50.0, height: 18.0))
            self.titleView!.layer.cornerRadius = 3
            self.titleView!.layer.masksToBounds = true
            
            self.titleView!.backgroundColor = .gray
            self.titleView!.alpha = 0.8
            self.titleLabel = UILabel(frame: self.titleView!.bounds)
            self.titleLabel!.backgroundColor = .clear
            self.titleLabel!.textColor = .white
            self.titleLabel!.text = "1 of \(self.images.count)"
            self.titleLabel!.textAlignment = .center
            self.titleLabel!.font = UIFont(name: self.displayFontName, size: 12.0)
            self.titleView!.addSubview(self.titleLabel!)
            self.addSubview(self.titleView!)
        }
    }
    
    // initialize data for views created in storyboard
    func setProperty(property: Property) {
        
        self.initializeDataAndScrollview(properties: [property])
        self.finalizeInit()
    }
    
    override func loadImages() {
        guard self.properties.count > 0 else {
            return
        }
        
        for index in 0..<self.properties[0].images.count {
            self.images.append(self.properties[0].images[index])
        }
        self.images = images
    }
    
    override func handleTap() {
        
        self.delegate?.selected(propertyId: self.properties[0].propertyId)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
