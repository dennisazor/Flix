//
//  MoviesDetailViewController.swift
//  FlixSwift
//
//  Created by Suraya Shivji on 10/10/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import ComplimentaryGradientView

class MoviesDetailViewController: UIViewController {

    
    @IBOutlet weak var backdropImg: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iTunesImage: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var gradientBG: ComplimentaryGradientView!
    @IBOutlet weak var detailsScroll: UIScrollView!
    @IBOutlet weak var movieImage: UIImageView!
    var movie : NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

        overviewLabel.numberOfLines = 0
        titleLabel.numberOfLines = 0
        
        
        setupUI()
        
        detailsScroll.contentSize = CGSize(width: detailsScroll.frame.size.width, height: contentView.frame.origin.y + contentView.frame.size.height)
        
        iTunesImage.alpha = 0.4

        
    }

    
    func setupUI() {
        
        
//        self.backdropImg.image = movie[]
        // image url
//        let baseURL = "https://image.tmdb.org/t/p/w500"
//        let backdropPath = movie["backdrop_path"] as! String
//        let imageURL = URL(string: baseURL + backdropPath)
//        self.backdropImg.setImageWith(imageURL!)
//        self.backdropImg.alpha = 0.5
        
        // IMAGE -- refactor this later with the small image if it's already cached
        overviewLabel.text = movie["overview"] as? String
        overviewLabel.sizeToFit()
        overviewLabel.layoutIfNeeded()
        titleLabel.text = movie["title"] as? String
                titleLabel.sizeToFit()
                titleLabel.layoutIfNeeded()
        self.title = movie["title"] as? String
        let posterPath = movie["poster_path"] as! String
        let smallImageURL = URL(string: "https://image.tmdb.org/t/p/w45\(posterPath)")
        let largeImageURL = URL(string: "https://image.tmdb.org/t/p/original\(posterPath)")
        
        let smallImageRequest = URLRequest(url: smallImageURL!)
        let largeImageRequest = URLRequest(url: largeImageURL!)
        

        
        
        self.movieImage.setImageWith(smallImageRequest,
                                     placeholderImage: nil,
                                     success: { (smallImageRequest, smallImageResponse, smallImage) in
            
            // smallImageResponse nil if its already cached
                                        self.movieImage.alpha = 0.0
                                        self.movieImage.image = smallImage
                                        
                                        
                                        UIView.animate(withDuration: 0.1, animations: {
                                            self.movieImage.alpha = 1.0
                                            
                                            }, completion: { (success) in
                                                self.movieImage.setImageWith(largeImageRequest,
                                                                             placeholderImage: smallImage,
                                                                             success: { (largeImageRequest, largeResponse, largeImage) in
                                                                                self.movieImage.image = largeImage
                                                                                let bg : UIImage = largeImage
                                                                                self.gradientBG.image = bg
                                                                                self.gradientBG.gradientTpye = .backgroundPrimary
                                                                                self.gradientBG.gradientStartPoint = .left
                                                                                
                                                                
                                                    }, failure: { (largeRequest, largeResponse, largeError) in
                                                        print(largeError)
                                                        // refactor -- make it default image
                                                })
                                        })
            
            
            }) { (smallRequest, smallResponse, smallError) in
                // small image error
                print(smallError)
                
                
//                let bg : UIImage = largeImage
                self.gradientBG.image = self.movieImage.image
                self.gradientBG.gradientTpye = .backgroundPrimary
                self.gradientBG.gradientStartPoint = .left
                
        }
        
        
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
