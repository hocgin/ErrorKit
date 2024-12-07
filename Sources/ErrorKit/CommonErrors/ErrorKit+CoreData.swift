#if canImport(CoreData)
import CoreData
#endif

extension ErrorKit {
   static func enhancedCoreDataDescription(for error: Error) -> String? {
      #if canImport(CoreData)
      let nsError = error as NSError

      if nsError.domain == NSCocoaErrorDomain {
         switch nsError.code {

         case NSPersistentStoreSaveError:
            return String(
               localized: "CommonErrors.CoreData.NSPersistentStoreSaveError",
               defaultValue: "Failed to save the data. Please try again.",
               bundle: .module
            )
         case NSValidationMultipleErrorsError:
            return String(
               localized: "CommonErrors.CoreData.NSValidationMultipleErrorsError",
               defaultValue: "Multiple validation errors occurred while saving.",
               bundle: .module
            )
         case NSValidationMissingMandatoryPropertyError:
            return String(
               localized: "CommonErrors.CoreData.NSValidationMissingMandatoryPropertyError",
               defaultValue: "A mandatory property is missing. Please fill all required fields.",
               bundle: .module
            )
         case NSValidationRelationshipLacksMinimumCountError:
            return String(
               localized: "CommonErrors.CoreData.NSValidationRelationshipLacksMinimumCountError",
               defaultValue: "A relationship is missing required related objects.",
               bundle: .module
            )
         case NSPersistentStoreIncompatibleVersionHashError:
            return String(
               localized: "CommonErrors.CoreData.NSPersistentStoreIncompatibleVersionHashError",
               defaultValue: "The data store is incompatible with the current model version.",
               bundle: .module
            )
         case NSPersistentStoreOpenError:
            return String(
               localized: "CommonErrors.CoreData.NSPersistentStoreOpenError",
               defaultValue: "Unable to open the persistent store. Please check your storage or permissions.",
               bundle: .module
            )
         case NSManagedObjectValidationError:
            return String(
               localized: "CommonErrors.CoreData.NSManagedObjectValidationError",
               defaultValue: "An object validation error occurred.",
               bundle: .module
            )
         default:
            return nil
         }
      }
      #endif

      return nil
   }
}
