import Foundation

// シングルトン

class iTunesRSSGenerator
{
    private init() {
        
    }
    static let instance = iTunesRSSGenerator();
    
    let baseURL = "https://itunes.apple.com";
    enum Country: String {
        case us = "us"
        case jp = "jp"
    }
    
    enum FeedType: String {
        case newapp = "newapplications"
        case newfreeapp = "newfreeapplications"
        case newpaidapp = "newpaidapplications"
    }
    
    enum OutputFormat: String {
        case xml = "xml"
        case json = "json"
    }
    
    enum Genre: String {
        case all = ""
        case game = "genre=6014/"
    }
    
    func makeURLfromXML(country: Country = Country.us
        , feedtype: FeedType = FeedType.newapp
        , limit: UInt = 50
        , outputformat: OutputFormat = OutputFormat.json
        , genre: Genre = Genre.all) -> NSURL!
    {
        return NSURL(string: "\(baseURL)/\(country)/rss/\(feedtype)/\(limit)/\(genre)\(outputformat)");
    }
}