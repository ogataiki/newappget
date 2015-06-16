import Foundation

// シングルトン

class SearchAPICtrl
{
    private init() {
        
    }
    static let instance = SearchAPICtrl();
    
    static let baseSearchURL = "https://itunes.apple.com/search?";
    static let baseLookupURL = "https://itunes.apple.com/lookup?";
    
    func makeSearchURL(term: String = "yelp"
        , country: String = "jp"
        , entity: String = "software") -> NSURL!
    {
        // URLエンコーディング
        let encodedTerm = term.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
        let encodedCountry = country.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
        let encodedEntity = entity.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
        
        return NSURL(string: "\(SearchAPICtrl.baseSearchURL)term=\(encodedTerm)&country=\(encodedCountry)&entity=\(entity)");
    }
    
    func makeLookupURL(bundleid: String = ""
        , country: String = "jp") -> NSURL!
    {
        return NSURL(string: "\(SearchAPICtrl.baseSearchURL)country=\(country)&bundleId=\(bundleid)");
    }
}

extension SearchAPICtrl
{
    
}