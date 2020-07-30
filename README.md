# Calendar Redirects

Serve a key, value store of IDs to redirects.
This was built as a simple solution to serving video conferencing invites behind an existing OAuth middleware

## Usage

Required environment variables are:

### LINKS

Will first assume this containes a base64 encoded csv and attempt to load it into a dictionary.
If this fails it is assumed to be the path to the csv.

### DEFAULT_REDIRECT

URL to redirect to if the provided key does not exist.
