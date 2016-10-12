//
//  CurrentViewController.swift
//  FlixSwift
//
//  Created by Suraya Shivji on 10/10/16.
//  Copyright © 2016 Suraya Shivji. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import iTunesSearchAPI

class CurrentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    @IBOutlet weak var networkError: UIView!
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var filteredMovies: [NSDictionary]!
    var movies : [NSDictionary]?
    
    override func   viewDidLoad() {
        super.viewDidLoad()

        self.title = "Current"
        // Do any additional setup after loading the view.
        self.networkError.isHidden = true
        self.moviesTableView.dataSource = self
        self.moviesTableView.delegate = self
        self.searchBar.delegate = self
        
        self.moviesTableView.isHidden = true
        
        self.barButtonItem.image = UIImage(named: "tableViewImg.png")
        
        // collection view
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        filteredMovies = movies
        loadCurrentMovies(refreshing: false, refreshControl: nil)
        
        // refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        self.moviesTableView.insertSubview(refreshControl, at: 0)
        self.collectionView.insertSubview(refreshControl, at: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.size.width
        let numberOfCellsPerRow = 2
        let dimensions = CGFloat(Int(totalWidth) / numberOfCellsPerRow)
        return CGSize(width: dimensions, height: dimensions)
    }
    
    @IBAction func toggleView(_ sender: UIBarButtonItem) {
        if(self.moviesTableView.isHidden) {
            self.moviesTableView.isHidden = false
            self.collectionView.isHidden = true
            self.barButtonItem.image = UIImage(named: "collectionViewImg.png")
        } else {
            self.moviesTableView.isHidden = true
            self.collectionView.isHidden = false
            self.barButtonItem.image = UIImage(named: "tableViewImg.png")
        }
    }
    
    func configureiTunes() {
        let itunes = iTunes()
        itunes.search(for: "Dance Moms", ofType: .tvShow(Entity.tvEpisode)) { result in
            // handle the Result<AnyObject, SearchError>
        }
    }
    
    // refresh control action
    func loadCurrentMovies(refreshing: Bool, refreshControl: UIRefreshControl?) {
    
        // access now playing endpoint of movie database
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        // display loading before request
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with:request, completionHandler: {
            (dataOrNil, response, error) in
            
            print(error)
            // hide loading once response comes back -- main thread
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let data = dataOrNil { // data not nil
                // parse json into a dictionary
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    // load response dictionary into movies
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.filteredMovies = self.movies
                    self.moviesTableView.reloadData()
                    self.collectionView.reloadData()
                    if refreshing {
                        refreshControl?.endRefreshing()
                    }
                }
            }
            else { // no data
                self.networkError.isHidden = false
            }
        })
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        loadCurrentMovies(refreshing: true, refreshControl: refreshControl)
    }
    
    
    // MARK: - Table View Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.filteredMovies != nil { // check for nil
            return self.filteredMovies!.count
        }
        else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = moviesTableView.dequeueReusableCell(withIdentifier: "currentMovieCell", for: indexPath) as! MovieCell
        let movie = self.filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        // image url
        let baseURL = "https://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        let imageURL = URL(string: baseURL + posterPath)
        
        let imageRequest = URLRequest(url: imageURL!)
        cell.movieImage.setImageWith(imageRequest,
                                     placeholderImage: nil,
                                     success: { (imageRequest, imageResponse, image) in
            // imageresponse nil -- image is cached
            if imageResponse != nil {
                // image not cached, fade image
                cell.movieImage.alpha = 0.3
                cell.movieImage.image = image
                UIView.animate(withDuration: 0.4, animations: {
                    cell.movieImage.alpha = 1.0
                })
            } else {
                cell.movieImage.image = image
            }
            
            },
                                     failure: { (imageRequest, imageResponse, error) -> Void in
                                        // failure -- couldn't download image
                                        print(error)
                
        })
        
        cell.titleText.text = title
        cell.descriptionText.text = overview
        
        return cell
    }
    
    // MARK: - Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // search bar text changed
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            // user has typed in search box
            // iterate over items in movie array w filter method -- return true if it should be included
            filteredMovies = movies?.filter({ (movie: NSDictionary) -> Bool in
                let movieTitle = movie["title"] as! String
                if movieTitle.range(of: searchText, options: .caseInsensitive ) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        self.moviesTableView.reloadData()
        self.collectionView.reloadData()
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.filteredMovies != nil { // check for nil
            return self.filteredMovies!.count
        }
        else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "currentCollectionCell", for: indexPath) as! CurrentCollectionViewCell
        
        let movie = self.filteredMovies![indexPath.row]
        
        // image url
        let baseURL = "https://image.tmdb.org/t/p/w500"
        let posterPath = movie["poster_path"] as! String
        let imageURL = URL(string: baseURL + posterPath)
        
        let imageRequest = URLRequest(url: imageURL!)
        cell.cellTitle.text = movie["title"] as? String
        cell.cellImage.setImageWith(imageRequest,
                                     placeholderImage: nil,
                                     success: { (imageRequest, imageResponse, image) in
                                        // imageresponse nil -- image is cached
                                        if imageResponse != nil {
                                            // image not cached, fade image
                                            cell.cellImage.alpha = 0.2
                                            cell.cellImage.image = image
                                            UIView.animate(withDuration: 0.4, animations: {
                                                cell.cellImage.alpha = 0.9
                                            })
                                        } else {
                                            cell.cellImage.image = image
                                        }
                                        
            },
                                     failure: { (imageRequest, imageResponse, error) -> Void in
                                        // failure -- couldn't download image
                                        print(error)
                                        
        })

        
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MoviesDetailViewController
        let indexPath = self.moviesTableView.isHidden ?  self.collectionView.indexPath(for: sender as! UICollectionViewCell) :
                                                            self.moviesTableView.indexPath(for: sender as! UITableViewCell)
        destinationVC.movie = filteredMovies[(indexPath?.row)!]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
