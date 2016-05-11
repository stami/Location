# Location

> The Tracker App

School assignment for mobile programming course at Tampere University of Applied Sciences.

Track your exercise with this magical GPS tracker! Functionality like never before! :]

## Things to expect

- Rock solid GPS tracker that can really be used without crashing (maybe some day)
- Trace on map
- Cool speed chart

## Maybe in future

- GPX export for good fun
- External sensor support via BLE (bike cadence or something)

With ❤️,
Samuli

## Installing

Install dependencies (with [Carthage](https://github.com/Carthage/Carthage))

```
carthage update --platform iOS
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
