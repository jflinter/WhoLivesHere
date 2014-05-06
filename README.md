WhoLivesHere
============

An app to help find your friends when you're traveling.

This is a pretty simple app. It uses the Facebook SDK and CLGeocoder to help you find your friends in foreign cities.

It also has a pretty nifty usage of parallel concurrent NSOperations (one operation performs the friend request, one performs the geocoding, and one waits for both to finish before filtering the friend list using the geocoding result). If you're into that kind of thing.
