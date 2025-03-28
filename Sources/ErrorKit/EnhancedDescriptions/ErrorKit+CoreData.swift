#if canImport(CoreData)
import CoreData
#endif

extension ErrorKit {
   static func userFriendlyCoreDataMessage(for error: Error) -> String? {
      #if canImport(CoreData)
      let nsError = error as NSError

      if nsError.domain == NSCocoaErrorDomain {
         switch nsError.code {

         case NSPersistentStoreSaveError:
            return String.localized(
               key: "EnhancedDescriptions.CoreData.NSPersistentStoreSaveError",
               defaultValue: "Failed to save the data. Please try again."
            )
         case NSValidationMultipleErrorsError:
            return String.localized(
               key: "EnhancedDescriptions.CoreData.NSValidationMultipleErrorsError",
               defaultValue: "Multiple validation errors occurred while saving."
            )
         case NSValidationMissingMandatoryPropertyError:
            return String.localized(
               key: "EnhancedDescriptions.CoreData.NSValidationMissingMandatoryPropertyError",
               defaultValue: "A mandatory property is missing. Please fill all required fields."
            )
         case NSValidationRelationshipLacksMinimumCountError:
            return String.localized(
               key: "EnhancedDescriptions.CoreData.NSValidationRelationshipLacksMinimumCountError",
               defaultValue: "A relationship is missing required related objects."
            )
         case NSPersistentStoreIncompatibleVersionHashError:
            return String.localized(
               key: "EnhancedDescriptions.CoreData.NSPersistentStoreIncompatibleVersionHashError",
               defaultValue: "The data store is incompatible with the current model version."
            )
         case NSPersistentStoreOpenError:
            return String.localized(
               key: "EnhancedDescriptions.CoreData.NSPersistentStoreOpenError",
               defaultValue: "Unable to open the persistent store. Please check your storage or permissions."
            )
         case NSManagedObjectValidationError:
            return String.localized(
               key: "EnhancedDescriptions.CoreData.NSManagedObjectValidationError",
               defaultValue: "An object validation error occurred."
            )
         default:
            return nil
         }
      }
      #endif

      return nil
   }
}
