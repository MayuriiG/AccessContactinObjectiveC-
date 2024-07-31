-(void )fetchAllContact:(void(^)(BOOL granted, NSArray<NSDictionary *> * contacts, NSError * _Nullable error)) completion{
    
    CNContactStore *store = [[CNContactStore alloc]init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (error){
           if (completion) completion(NO,nil, error);    NSLog(@"Error requesting access: %@", error.localizedDescription);
            return;
        }
        
        if (granted){
            
            NSArray *keys = @[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey];
            NSPredicate* predicate  = [CNContact predicateForContactsInContainerWithIdentifier:store.defaultContainerIdentifier];
            NSError* fetchError = nil;
            NSArray<CNContact *>  *cnContacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keys  error:&fetchError];
            
            if (fetchError){
                if (completion) completion(NO, nil ,fetchError); NSLog(@"Error fetching contact:%@", fetchError.localizedDescription);
                return ;
            }
            
            NSMutableArray *contactArray = [NSMutableArray array];
            
                  for (CNContact *contact in cnContacts) {
                      NSMutableArray *phones = [NSMutableArray array];
                      
                      for (CNLabeledValue *lb in contact.phoneNumbers) {
                          CNPhoneNumber *phoneNumber = lb.value;
                          
                          if (phoneNumber.stringValue.length > 0) {
                              [phones addObject:phoneNumber.stringValue];
                          }
                      }
                      
                      if (phones.count > 0) {
                          NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                          NSString *fullName = [NSString stringWithFormat:@"%@ %@", contact.givenName ?: @"", contact.familyName ?: @""];
                          dict[@"fullName"] = fullName;
                          dict[@"phones"] = phones;
                          [contactArray addObject:dict];
//                 dict[@"firstname"] = contact.givenName ?: @""; dict[@"lastname"] = contact.familyName ?: @"";
//                 dict[@"phones"] = phones; [contactArray addObject:dict];
                      }
                  }
            NSLog(@"Total contacts fetched : %lu",(unsigned long)contactArray.count); NSLog(@"Show Contact !!!!%@",contactArray);
            if (completion)completion(YES, contactArray ,nil);
    
        }else{
            if (completion)completion(NO, nil ,nil);   NSLog(@"Access to contacts was denied.");
          }
     }]

@end
