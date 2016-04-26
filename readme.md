# Location

> The Tracker App

Track your exercise with this magical GPS tracker! Functionality like never before! :]

School assignment for mobile programming course at Tampere University of Applied Sciences.

## Things to expect

- Rock solid GPS tracker that can really be used without crashing
- GPX export for more fun
- Trace on map
- Cool charts of the data

With ❤️,
Samuli

## Installing

Install dependencies (with [Carthage](https://github.com/Carthage/Carthage))

```
carthage update
```

Create ApiKeys.plist file

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>API_BASE_URL</key>
	<string>https://your-api-url</string>
	<key>API_KEY</key>
	<string>your_api_key</string>
</dict>
</plist>
```

I use [mLab](https://mlab.com)'s free MongoDB Sandbox with their [RESTful Data API](http://docs.mlab.com/data-api/)

Then just build and run! 🏃
