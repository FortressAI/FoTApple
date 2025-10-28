#!/bin/bash
# Create apps in App Store Connect via API
# Requires: App Store Connect API key with App Manager access

echo "To create apps via API, you need to:"
echo ""
echo "1. Generate JWT token from your API key"
echo "2. Make POST requests to App Store Connect API"
echo ""
echo "Example:"
echo ""
echo 'curl -X POST "https://api.appstoreconnect.apple.com/v1/apps" \'
echo '  -H "Authorization: Bearer YOUR_JWT_TOKEN" \'
echo '  -H "Content-Type: application/json" \'
echo '  -d '"'"'{
    "data": {
      "type": "apps",
      "attributes": {
        "bundleId": "com.fot.PersonalHealth",
        "name": "Personal Health Monitor",
        "primaryLocale": "en-US",
        "sku": "com.fot.PersonalHealth"
      },
      "relationships": {
        "bundleIdRelation": {
          "data": {
            "type": "bundleIds",
            "id": "BUNDLE_ID_RESOURCE_ID"
          }
        }
      }
    }
  }'"'"
echo ""
echo "BUT: Using Xcode GUI is much simpler for initial setup!"
