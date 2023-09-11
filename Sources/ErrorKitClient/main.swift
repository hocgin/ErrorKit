import ErrorKit
import Foundation

final class Database {
   static func loadMovies(byGenre genre: Movie.Genre) throws -> [Movie] {
      let randomInt = (0..<100).randomElement()!
      if randomInt < 33 {
         throw #RichError(code: 54934, message: "Loading movies from database failed!")
      } else if randomInt < 66 {
         return []
      } else {
         return [
            Movie(title: "Harry Potter and the Philosopher's Stone", releaseYear: 2001),
            Movie(title: "Harry Potter and the Chamber of Secrets", releaseYear: 2002),
            Movie(title: "Harry Potter and the Prisoner of Azkaban", releaseYear: 2004),
            Movie(title: "Harry Potter and the Goblet of Fire", releaseYear: 2005),
            Movie(title: "Harry Potter and the Order of the Phoenix", releaseYear: 2007),
            Movie(title: "Harry Potter and the Half-Blood Prince", releaseYear: 2009),
            Movie(title: "Harry Potter and the Deathly Hallows – Part 1", releaseYear: 2010),
            Movie(title: "Harry Potter and the Deathly Hallows – Part 2", releaseYear: 2011),
         ]
      }
   }
}

struct Movie: Equatable {
   let title: String
   let releaseYear: Int

   enum Genre {
      case action, anime, bollywood, comedy, drama
   }

   static func randomMovies(genre: Genre, count: Int) throws -> [Movie] {
      var movies = try Database.loadMovies(byGenre: genre)

      guard !movies.isEmpty else {
         throw #RichError(code: 21693, message: "No movies found matching the genre '\(genre)'.")
      }



      var randomMovies: [Movie] = []
      for _ in 0..<count {
         guard let randomMovie = movies.randomElement() else {
            throw #RichError(code: 89316, message: "Not enough movies matching the genre '\(genre)'.")
         }
         
         movies.removeAll { $0 == randomMovie }
         randomMovies.append(randomMovie)
      }

      return randomMovies
   }
}

// TODO: replace later with custom type-specific auto-generated error type?
extension NSError {
    static func generic(code: Int, message: String) -> NSError {
        NSError(domain: Bundle.main.bundleIdentifier ?? "App", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}


print(try Movie.randomMovies(genre: .action, count: 5).map(\.title))
