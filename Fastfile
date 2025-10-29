default_platform(:ios)

platform :ios do
  desc "Create apps in App Store Connect"
  lane :create_apps do
    
    # App 1: Personal Health
    produce(
      username: CredentialsManager::AppfileConfig.try_fetch_value(:apple_id),
      app_identifier: "com.fot.PersonalHealth",
      app_name: "Personal Health Monitor",
      language: "English",
      sku: "FOTH-001",
      team_id: "WWQQB728U5"
    )
    
    # App 2: Clinician
    produce(
      username: CredentialsManager::AppfileConfig.try_fetch_value(:apple_id),
      app_identifier: "com.fot.ClinicianApp",
      app_name: "Field of Truth Clinician",
      language: "English",
      sku: "FOTC-002",
      team_id: "WWQQB728U5"
    )
    
    # App 3: Parent
    produce(
      username: CredentialsManager::AppfileConfig.try_fetch_value(:apple_id),
      app_identifier: "com.fot.ParentApp",
      app_name: "Field of Truth Parent",
      language: "English",
      sku: "FOTP-003",
      team_id: "WWQQB728U5"
    )
    
    # App 4: Education
    produce(
      username: CredentialsManager::AppfileConfig.try_fetch_value(:apple_id),
      app_identifier: "com.fot.EducationApp",
      app_name: "Field of Truth Education",
      language: "English",
      sku: "FOTE-004",
      team_id: "WWQQB728U5"
    )
    
    # App 5: Legal
    produce(
      username: CredentialsManager::AppfileConfig.try_fetch_value(:apple_id),
      app_identifier: "com.fot.LegalApp",
      app_name: "Field of Truth Legal",
      language: "English",
      sku: "FOTL-005",
      team_id: "WWQQB728U5"
    )
  end
end
