# Wallet-Api Server

## How it works

* API server accepts json payload for the pass information.
* Upon receiving the payload:
  1. Google TicketClass/TicketObject are created and URL that can be saved by the user in Google Pay app is provided.
  2. Apple .pkpass file is created and is uploaded to the google drive (associated with the auth credentials of google service).
* 2 URLs are returned as response payload `apple_pass_url` and `google_pass_url`. `apple_pass_url` is the url to the `.pkpass` file uploaded to google drive.

## Available EndPoints
* Requires authentication header `x-api-key` which must match `API_KEY` ENV VAR

### POST /

#### BODY
 ```json
 {
    "event_name": "My event", // required
    "ticket_holder_name": "John Smith", // required
    "location":           {"lat": 37.424299996, "lon": -122.0925956000001, "name": "Sydney International Convention Centre", "address": "ICC Sydney"}, // required
    "date_time":          {"start": "2023-04-12T11:20:50.52Z", "end": "2023-04-12T16:20:50.52Z"}, // required
    "qr_code":            {
      "value":    "http://example.com/best_url",
      "alt_text": "1234567890",
    }, // required
    "logo":               {"image_uri": "https://example.com/logo.png", "description": "Logo Desc"},
    "icon":               {"image_uri": "https://example.com/icon.png"},
    "event_details": {"header": "My header", "body": "BODY of the event"},
 }
```

#### RESPONSE
 ```json
 {
    "apple_pass_url": "https://wallet-api-server.example.com/apple_pass_file_google_drive_file_id",
    "google_pass_url": "https://pay.google.com/gp/v/save/SIGNED_ENCODED_PASS_INFORMATION",
 }
```

### GET /:apple_pass_file_google_drive_file_id

* Doesn't require authentication.

#### Response
Serves `apple_pass_file_google_drive_file_id.pkpass` file


## ENV Variables

```
# Needed to be passed in headers for authentication with API server
API_KEY=SECURE_KEY

# APPLE PASS
# Data needed to create/sign pass
SIGNING_CERT=cert.pem
PRIVATE_KEY=pkey.pem
WWDR_CERT=wwdr.pem
PRIVATE_KEY_PASSWORD=12345
APPLE_TEAM_IDENTIFIER=8EZ6J123456
APPLE_PASS_TYPE_IDENTIFIER=pass.technology.place.dev
APPLE_ORGANIZATION_NAME='ACA Projects Australia Pty Ltd'

# Default data for pass, can be customized per request as well
APPLE_LOGO_PATH='/resources/logo.png'
APPLE_ICON_PATH='/resources/icon.png'
APPLE_LOGO_DESCRIPTION='PlaceOS Wallet'

# Customize pass design
APPLE_DESIGN_FOREGROUND_COLOR='rgb(255, 255, 255)'
APPLE_DESIGN_BACKGROUND_COLOR='rgb(66, 80, 112)'
APPLE_DESIGN_LABEL_COLOR='rgb(255, 255, 255)'

# GOOGLE PASS
GOOGLE_WALLET_ISSUER_ID=12345678890
GOOGLE_WALLET_ISSUER_NAME=PlaceOS
GOOGLE_AUTH_FILE=direct-builder-1234567890.json
# Default data for pass, can be customized per request as well
GOOGLE_LOGO_IMAGE_URL='https://example.com/logo.png'
GOOGLE_LOGO_DESCRIPTION='PlaceOS Wallet'
```

## Testing

`crystal spec`

* to run in development mode `crystal ./src/app.cr`

## Compiling

`crystal build ./src/app.cr`

### Deploying

Once compiled you are left with a binary `./app`

* for help `./app --help`
* viewing routes `./app --routes`
* run on a different port or host `./app -b 0.0.0.0 -p 80`
